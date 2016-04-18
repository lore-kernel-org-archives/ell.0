Content-Type: multipart/mixed; boundary="===============0016696687832161155=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/5] dbus: Use the name cache API in _dbus_filter
Date: Mon, 18 Apr 2016 16:31:14 +0200
Message-ID: <1460989877-20113-7-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1460989877-20113-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0016696687832161155==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-filter.c  | 122 +++++++++----------------------------------------=
----
 ell/dbus-private.h |   6 +--
 ell/dbus.c         |  13 +-----
 3 files changed, 24 insertions(+), 117 deletions(-)

diff --git a/ell/dbus-filter.c b/ell/dbus-filter.c
index 59059cb..42755a9 100644
--- a/ell/dbus-filter.c
+++ b/ell/dbus-filter.c
@@ -62,12 +62,7 @@ struct _dbus_filter {
 	unsigned int signal_id;
 	unsigned int last_id;
 	const struct _dbus_filter_ops *driver;
-	struct l_hashmap *unique_names;
-};
-
-struct unique_name_record {
-	int ref_count;
-	char *unique_name;
+	struct _dbus_name_cache *name_cache;
 };
 =

 static void filter_subtree_free(struct filter_node *node)
@@ -92,14 +87,6 @@ static void filter_subtree_free(struct filter_node *node)
 	}
 }
 =

-static void unique_name_record_free(void *data)
-{
-	struct unique_name_record *name_rec =3D data;
-
-	l_free(name_rec->unique_name);
-	l_free(name_rec);
-}
-
 static void dbus_filter_destroy(void *data)
 {
 	struct _dbus_filter *filter =3D data;
@@ -107,10 +94,6 @@ static void dbus_filter_destroy(void *data)
 	if (filter->root)
 		filter_subtree_free(filter->root);
 =

-	if (filter->unique_names)
-		l_hashmap_destroy(filter->unique_names,
-					unique_name_record_free);
-
 	l_free(filter);
 }
 =

@@ -120,7 +103,6 @@ static void filter_dispatch_match_recurse(struct _dbus_=
filter *filter,
 {
 	const char *value =3D NULL;
 	const char *alt_value =3D NULL;
-	const struct unique_name_record *name_rec;
 	struct filter_node *child;
 =

 	switch ((int) node->type) {
@@ -157,13 +139,9 @@ static void filter_dispatch_match_recurse(struct _dbus=
_filter *filter,
 	if (!value)
 		return;
 =

-	if (node->type =3D=3D L_DBUS_MATCH_SENDER && filter->unique_names) {
-		name_rec =3D l_hashmap_lookup(filter->unique_names,
-						node->match.value);
-
-		if (name_rec)
-			alt_value =3D name_rec->unique_name;
-	}
+	if (node->type =3D=3D L_DBUS_MATCH_SENDER && filter->name_cache)
+		alt_value =3D _dbus_name_cache_lookup(filter->name_cache,
+							node->match.value);
 =

 	if (strcmp(value, node->match.value) &&
 			(!alt_value || strcmp(value, alt_value)))
@@ -180,28 +158,9 @@ void _dbus_filter_dispatch(struct l_dbus_message *mess=
age, void *user_data)
 	filter_dispatch_match_recurse(filter, filter->root, message);
 }
 =

-void _dbus_filter_name_owner_notify(struct _dbus_filter *filter,
-					const char *name, const char *owner)
-{
-	struct unique_name_record *name_rec;
-
-	if (!filter)
-		return;
-
-	if (_dbus_parse_unique_name(name, NULL))
-		return;
-
-	name_rec =3D l_hashmap_lookup(filter->unique_names, name);
-	if (!name_rec)
-		return;
-
-	l_free(name_rec->unique_name);
-
-	name_rec->unique_name =3D (owner && *owner) ? l_strdup(owner) : NULL;
-}
-
 struct _dbus_filter *_dbus_filter_new(struct l_dbus *dbus,
-					const struct _dbus_filter_ops *driver)
+					const struct _dbus_filter_ops *driver,
+					struct _dbus_name_cache *name_cache)
 {
 	struct _dbus_filter *filter;
 =

@@ -209,15 +168,13 @@ struct _dbus_filter *_dbus_filter_new(struct l_dbus *=
dbus,
 =

 	filter->dbus =3D dbus;
 	filter->driver =3D driver;
+	filter->name_cache =3D name_cache;
 =

 	if (!filter->driver->skip_register)
 		filter->signal_id =3D l_dbus_register(dbus, _dbus_filter_dispatch,
 							filter,
 							dbus_filter_destroy);
 =

-	if (filter->driver->get_name_owner)
-		filter->unique_names =3D l_hashmap_string_new();
-
 	return filter;
 }
 =

@@ -232,54 +189,6 @@ void _dbus_filter_free(struct _dbus_filter *filter)
 		dbus_filter_destroy(filter);
 }
 =

-static bool filter_add_bus_name(struct _dbus_filter *filter, const char *n=
ame)
-{
-	struct unique_name_record *name_rec;
-
-	if (!filter->unique_names)
-		return true;
-
-	if (_dbus_parse_unique_name(name, NULL))
-		return true;
-
-	if (!_dbus_valid_bus_name(name))
-		return false;
-
-	name_rec =3D l_hashmap_lookup(filter->unique_names, name);
-	if (!name_rec) {
-		name_rec =3D l_new(struct unique_name_record, 1);
-
-		l_hashmap_insert(filter->unique_names, name, name_rec);
-
-		filter->driver->get_name_owner(filter->dbus, name);
-	}
-
-	name_rec->ref_count++;
-
-	return true;
-}
-
-static void filter_remove_bus_name(struct _dbus_filter *filter,
-					const char *name)
-{
-	struct unique_name_record *name_rec;
-
-	if (!filter->unique_names)
-		return;
-
-	if (_dbus_parse_unique_name(name, NULL))
-		return;
-
-	name_rec =3D l_hashmap_lookup(filter->unique_names, name);
-
-	if (--name_rec->ref_count)
-		return;
-
-	l_hashmap_remove(filter->unique_names, name);
-
-	unique_name_record_free(name_rec);
-}
-
 static int condition_compare(const void *a, const void *b)
 {
 	const struct _dbus_filter_condition *condition_a =3D a, *condition_b =3D =
b;
@@ -312,8 +221,11 @@ static bool remove_recurse(struct _dbus_filter *filter,
 		if (tmp->match.remote_rule)
 			filter->driver->remove_match(filter->dbus, tmp->id);
 =

-		if (tmp->type =3D=3D L_DBUS_MATCH_SENDER)
-			filter_remove_bus_name(filter, tmp->match.value);
+		if (tmp->type =3D=3D L_DBUS_MATCH_SENDER && filter->name_cache &&
+				!_dbus_parse_unique_name(tmp->match.value,
+								NULL))
+			_dbus_name_cache_remove(filter->name_cache,
+						tmp->match.value);
 =

 		filter_subtree_free(tmp);
 	}
@@ -356,8 +268,14 @@ unsigned int _dbus_filter_add_rule(struct _dbus_filter=
 *filter,
 =

 			*node_ptr =3D node;
 =

-			if (node->type =3D=3D L_DBUS_MATCH_SENDER)
-				filter_add_bus_name(filter, node->match.value);
+			if (node->type =3D=3D L_DBUS_MATCH_SENDER &&
+					filter->name_cache &&
+					!_dbus_parse_unique_name(
+							node->match.value,
+							NULL))
+				_dbus_name_cache_add(filter->name_cache,
+							node->match.value);
+
 		}
 =

 		node_ptr =3D &node->match.children;
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 327f0e3..1ade3e0 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -302,11 +302,11 @@ struct _dbus_filter_ops {
 				const struct _dbus_filter_condition *rule,
 				int rule_len);
 	bool (*remove_match)(struct l_dbus *bus, unsigned int id);
-	bool (*get_name_owner)(struct l_dbus *bus, const char *name);
 };
 =

 struct _dbus_filter *_dbus_filter_new(struct l_dbus *dbus,
-					const struct _dbus_filter_ops *driver);
+					const struct _dbus_filter_ops *driver,
+					struct _dbus_name_cache *name_cache);
 void _dbus_filter_free(struct _dbus_filter *filter);
 =

 unsigned int _dbus_filter_add_rule(struct _dbus_filter *filter,
@@ -320,8 +320,6 @@ char *_dbus_filter_rule_to_str(const struct _dbus_filte=
r_condition *rule,
 				int rule_len);
 =

 void _dbus_filter_dispatch(struct l_dbus_message *message, void *user_data=
);
-void _dbus_filter_name_owner_notify(struct _dbus_filter *filter,
-					const char *name, const char *owner);
 =

 struct dbus1_filter_data;
 =

diff --git a/ell/dbus.c b/ell/dbus.c
index 529a26a..bc6aaed 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -575,7 +575,8 @@ static void dbus_init(struct l_dbus *dbus, int fd)
 =

 	dbus->name_cache =3D _dbus_name_cache_new(dbus, &dbus->driver->name_ops);
 =

-	dbus->filter =3D _dbus_filter_new(dbus, &dbus->driver->filter_ops);
+	dbus->filter =3D _dbus_filter_new(dbus, &dbus->driver->filter_ops,
+					dbus->name_cache);
 }
 =

 static void classic_free(struct l_dbus *dbus)
@@ -771,8 +772,6 @@ static void get_name_owner_reply_cb(struct l_dbus_messa=
ge *reply,
 	if (!l_dbus_message_get_arguments(req->message, "s", &name))
 		return;
 =

-	_dbus_filter_name_owner_notify(req->dbus->filter, name, owner);
-
 	_dbus_name_cache_notify(req->dbus->name_cache, name, owner);
 }
 =

@@ -891,7 +890,6 @@ static const struct l_dbus_ops classic_ops =3D {
 	.filter_ops =3D {
 		.add_match =3D classic_add_match,
 		.remove_match =3D classic_remove_match,
-		.get_name_owner =3D classic_get_name_owner,
 	},
 	.name_acquire =3D classic_name_acquire,
 };
@@ -905,8 +903,6 @@ static void name_owner_changed_cb(struct l_dbus_message=
 *message,
 	if (!l_dbus_message_get_arguments(message, "sss", &name, &old, &new))
 		return;
 =

-	_dbus_filter_name_owner_notify(dbus->filter, name, new);
-
 	_dbus_name_cache_notify(dbus->name_cache, name, new);
 }
 =

@@ -1118,8 +1114,6 @@ static void kdbus_name_owner_change_func(const char *=
name, uint64_t old_owner,
 	else
 		owner[0] =3D '\0';
 =

-	_dbus_filter_name_owner_notify(recv_data->dbus->filter, name, owner);
-
 	_dbus_name_cache_notify(recv_data->dbus->name_cache, name, owner);
 }
 =

@@ -1188,8 +1182,6 @@ static bool kdbus_get_name_owner(struct l_dbus *dbus,=
 const char *name)
 	else
 		owner[0] =3D '\0';
 =

-	_dbus_filter_name_owner_notify(dbus->filter, name, owner);
-
 	_dbus_name_cache_notify(dbus->name_cache, name, owner);
 =

 	return true;
@@ -1232,7 +1224,6 @@ static const struct l_dbus_ops kdbus_ops =3D {
 	.filter_ops =3D {
 		.add_match =3D kdbus_add_match,
 		.remove_match =3D kdbus_remove_match,
-		.get_name_owner =3D kdbus_get_name_owner,
 	},
 	.name_acquire =3D kdbus_name_acquire,
 };
-- =

2.5.0


--===============0016696687832161155==--

