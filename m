Content-Type: multipart/mixed; boundary="===============0970712850942658666=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/15] dbus-filter: Name owner change tracking support.
Date: Mon, 21 Mar 2016 23:10:17 +0100
Message-ID: <1458598224-29325-8-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0970712850942658666==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is needed because incoming message callbacks normally care what
Well-known Bus Name the message comes from but the sender field of the
message normally stores unique bus names in classic dbus.  The
Well-known names may be re-assigned to different unique names while the
rule is in place.
---
 ell/dbus-filter.c  | 183 ++++++++++++++++++++++++++++++++++++++++++-------=
----
 ell/dbus-private.h |   4 ++
 2 files changed, 151 insertions(+), 36 deletions(-)

diff --git a/ell/dbus-filter.c b/ell/dbus-filter.c
index 048f59a..59059cb 100644
--- a/ell/dbus-filter.c
+++ b/ell/dbus-filter.c
@@ -62,6 +62,12 @@ struct _dbus_filter {
 	unsigned int signal_id;
 	unsigned int last_id;
 	const struct _dbus_filter_ops *driver;
+	struct l_hashmap *unique_names;
+};
+
+struct unique_name_record {
+	int ref_count;
+	char *unique_name;
 };
 =

 static void filter_subtree_free(struct filter_node *node)
@@ -86,6 +92,14 @@ static void filter_subtree_free(struct filter_node *node)
 	}
 }
 =

+static void unique_name_record_free(void *data)
+{
+	struct unique_name_record *name_rec =3D data;
+
+	l_free(name_rec->unique_name);
+	l_free(name_rec);
+}
+
 static void dbus_filter_destroy(void *data)
 {
 	struct _dbus_filter *filter =3D data;
@@ -93,6 +107,10 @@ static void dbus_filter_destroy(void *data)
 	if (filter->root)
 		filter_subtree_free(filter->root);
 =

+	if (filter->unique_names)
+		l_hashmap_destroy(filter->unique_names,
+					unique_name_record_free);
+
 	l_free(filter);
 }
 =

@@ -101,6 +119,8 @@ static void filter_dispatch_match_recurse(struct _dbus_=
filter *filter,
 						struct l_dbus_message *message)
 {
 	const char *value =3D NULL;
+	const char *alt_value =3D NULL;
+	const struct unique_name_record *name_rec;
 	struct filter_node *child;
 =

 	switch ((int) node->type) {
@@ -137,7 +157,16 @@ static void filter_dispatch_match_recurse(struct _dbus=
_filter *filter,
 	if (!value)
 		return;
 =

-	if (strcmp(value, node->match.value))
+	if (node->type =3D=3D L_DBUS_MATCH_SENDER && filter->unique_names) {
+		name_rec =3D l_hashmap_lookup(filter->unique_names,
+						node->match.value);
+
+		if (name_rec)
+			alt_value =3D name_rec->unique_name;
+	}
+
+	if (strcmp(value, node->match.value) &&
+			(!alt_value || strcmp(value, alt_value)))
 		return;
 =

 	for (child =3D node->match.children; child; child =3D child->next)
@@ -151,6 +180,26 @@ void _dbus_filter_dispatch(struct l_dbus_message *mess=
age, void *user_data)
 	filter_dispatch_match_recurse(filter, filter->root, message);
 }
 =

+void _dbus_filter_name_owner_notify(struct _dbus_filter *filter,
+					const char *name, const char *owner)
+{
+	struct unique_name_record *name_rec;
+
+	if (!filter)
+		return;
+
+	if (_dbus_parse_unique_name(name, NULL))
+		return;
+
+	name_rec =3D l_hashmap_lookup(filter->unique_names, name);
+	if (!name_rec)
+		return;
+
+	l_free(name_rec->unique_name);
+
+	name_rec->unique_name =3D (owner && *owner) ? l_strdup(owner) : NULL;
+}
+
 struct _dbus_filter *_dbus_filter_new(struct l_dbus *dbus,
 					const struct _dbus_filter_ops *driver)
 {
@@ -166,6 +215,9 @@ struct _dbus_filter *_dbus_filter_new(struct l_dbus *db=
us,
 							filter,
 							dbus_filter_destroy);
 =

+	if (filter->driver->get_name_owner)
+		filter->unique_names =3D l_hashmap_string_new();
+
 	return filter;
 }
 =

@@ -180,6 +232,54 @@ void _dbus_filter_free(struct _dbus_filter *filter)
 		dbus_filter_destroy(filter);
 }
 =

+static bool filter_add_bus_name(struct _dbus_filter *filter, const char *n=
ame)
+{
+	struct unique_name_record *name_rec;
+
+	if (!filter->unique_names)
+		return true;
+
+	if (_dbus_parse_unique_name(name, NULL))
+		return true;
+
+	if (!_dbus_valid_bus_name(name))
+		return false;
+
+	name_rec =3D l_hashmap_lookup(filter->unique_names, name);
+	if (!name_rec) {
+		name_rec =3D l_new(struct unique_name_record, 1);
+
+		l_hashmap_insert(filter->unique_names, name, name_rec);
+
+		filter->driver->get_name_owner(filter->dbus, name);
+	}
+
+	name_rec->ref_count++;
+
+	return true;
+}
+
+static void filter_remove_bus_name(struct _dbus_filter *filter,
+					const char *name)
+{
+	struct unique_name_record *name_rec;
+
+	if (!filter->unique_names)
+		return;
+
+	if (_dbus_parse_unique_name(name, NULL))
+		return;
+
+	name_rec =3D l_hashmap_lookup(filter->unique_names, name);
+
+	if (--name_rec->ref_count)
+		return;
+
+	l_hashmap_remove(filter->unique_names, name);
+
+	unique_name_record_free(name_rec);
+}
+
 static int condition_compare(const void *a, const void *b)
 {
 	const struct _dbus_filter_condition *condition_a =3D a, *condition_b =3D =
b;
@@ -187,6 +287,40 @@ static int condition_compare(const void *a, const void=
 *b)
 	return condition_a->type - condition_b->type;
 }
 =

+static bool remove_recurse(struct _dbus_filter *filter,
+				struct filter_node **node, unsigned int id)
+{
+	struct filter_node *tmp;
+
+	for (; *node; node =3D &(*node)->next) {
+		if ((*node)->type =3D=3D NODE_TYPE_CALLBACK && (*node)->id =3D=3D id)
+			break;
+
+		if ((*node)->type !=3D NODE_TYPE_CALLBACK &&
+				remove_recurse(filter, &(*node)->match.children,
+						id))
+			break;
+	}
+
+	if (!*node)
+		return false;
+
+	if ((*node)->type =3D=3D NODE_TYPE_CALLBACK || !(*node)->match.children) {
+		tmp =3D *node;
+		*node =3D tmp->next;
+
+		if (tmp->match.remote_rule)
+			filter->driver->remove_match(filter->dbus, tmp->id);
+
+		if (tmp->type =3D=3D L_DBUS_MATCH_SENDER)
+			filter_remove_bus_name(filter, tmp->match.value);
+
+		filter_subtree_free(tmp);
+	}
+
+	return true;
+}
+
 unsigned int _dbus_filter_add_rule(struct _dbus_filter *filter,
 					struct _dbus_filter_condition *rule,
 					int rule_len,
@@ -221,6 +355,9 @@ unsigned int _dbus_filter_add_rule(struct _dbus_filter =
*filter,
 			node->match.value =3D l_strdup(condition->value);
 =

 			*node_ptr =3D node;
+
+			if (node->type =3D=3D L_DBUS_MATCH_SENDER)
+				filter_add_bus_name(filter, node->match.value);
 		}
 =

 		node_ptr =3D &node->match.children;
@@ -241,51 +378,25 @@ unsigned int _dbus_filter_add_rule(struct _dbus_filte=
r *filter,
 	node->id =3D ++filter->last_id;
 	node->next =3D *node_ptr;
 =

+	*node_ptr =3D node;
+
 	if (!remote_rule) {
 		if (!filter->driver->add_match(filter->dbus, node->id,
-						rule, rule_len)) {
-			l_free(node);
-			return 0;
-		}
+						rule, rule_len))
+			goto err;
 =

 		parent->id =3D node->id;
 		parent->match.remote_rule =3D true;
 	}
 =

-	*node_ptr =3D node;
-
 	return node->id;
-}
-
-static bool remove_recurse(struct _dbus_filter *filter,
-				struct filter_node **node, unsigned int id)
-{
-	struct filter_node *tmp;
 =

-	for (; *node; node =3D &(*node)->next) {
-		if ((*node)->type =3D=3D NODE_TYPE_CALLBACK && (*node)->id =3D=3D id)
-			break;
-
-		if ((*node)->type !=3D NODE_TYPE_CALLBACK &&
-				remove_recurse(filter, &(*node)->match.children,
-						id))
-			break;
-	}
+err:
+	/* Remove all the nodes we may have added */
+	node->id =3D (unsigned int) -1;
+	remove_recurse(filter, &filter->root, node->id);
 =

-	if (!*node)
-		return false;
-
-	if ((*node)->type =3D=3D NODE_TYPE_CALLBACK || !(*node)->match.children) {
-		tmp =3D *node;
-		*node =3D tmp->next;
-
-		if (tmp->match.remote_rule)
-			filter->driver->remove_match(filter->dbus, tmp->id);
-
-		filter_subtree_free(tmp);
-	}
-
-	return true;
+	return 0;
 }
 =

 bool _dbus_filter_remove_rule(struct _dbus_filter *filter, unsigned int id)
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index d4a4782..d635cc0 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -255,6 +255,7 @@ struct _dbus_filter_ops {
 				const struct _dbus_filter_condition *rule,
 				int rule_len);
 	bool (*remove_match)(struct l_dbus *bus, unsigned int id);
+	bool (*get_name_owner)(struct l_dbus *bus, const char *name);
 };
 =

 struct _dbus_filter *_dbus_filter_new(struct l_dbus *dbus,
@@ -270,7 +271,10 @@ bool _dbus_filter_remove_rule(struct _dbus_filter *fil=
ter, unsigned int id);
 =

 char *_dbus_filter_rule_to_str(const struct _dbus_filter_condition *rule,
 				int rule_len);
+
 void _dbus_filter_dispatch(struct l_dbus_message *message, void *user_data=
);
+void _dbus_filter_name_owner_notify(struct _dbus_filter *filter,
+					const char *name, const char *owner);
 =

 struct dbus1_filter_data;
 =

-- =

2.5.0


--===============0970712850942658666==--

