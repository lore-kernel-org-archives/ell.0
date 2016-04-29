Content-Type: multipart/mixed; boundary="===============3594291514386716441=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Better search for matching rules in the filter tree
Date: Fri, 29 Apr 2016 05:31:53 +0200
Message-ID: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3594291514386716441==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When adding new filter rules, perform a more complete search for
existing rules that already cover the rule being added by removing the
requierement that levels in the tree are ordered by the match type.
This may add overhead to adding new rules in some situations but will
reduce the number of server-side rules being used and the number of
requests.  This covers a scenario where first a watch is added for:

type=3Dsignal, path=3D/

followed by

type=3Dsignal, sender=3Dorg.test, path=3D/

I believe there are some more tricky scenarios which are not covered
specifically when more than one child of an existing node matches some
condition of the rule being added.
---
 ell/dbus-filter.c  | 67 +++++++++++++++++++++++++++++++++++++++++++-------=
----
 ell/dbus-private.h |  8 +++----
 2 files changed, 58 insertions(+), 17 deletions(-)

diff --git a/ell/dbus-filter.c b/ell/dbus-filter.c
index 42755a9..9e3cad5 100644
--- a/ell/dbus-filter.c
+++ b/ell/dbus-filter.c
@@ -234,34 +234,63 @@ static bool remove_recurse(struct _dbus_filter *filte=
r,
 }
 =

 unsigned int _dbus_filter_add_rule(struct _dbus_filter *filter,
-					struct _dbus_filter_condition *rule,
-					int rule_len,
-					l_dbus_message_func_t signal_func,
-					void *user_data)
+				const struct _dbus_filter_condition *rule,
+				int rule_len,
+				l_dbus_message_func_t signal_func,
+				void *user_data)
 {
 	struct filter_node **node_ptr =3D &filter->root;
 	struct filter_node *node;
 	struct filter_node *parent =3D filter->root;
 	bool remote_rule =3D false;
-	struct _dbus_filter_condition *condition, *end =3D rule + rule_len;
-
-	qsort(rule, rule_len, sizeof(*rule), condition_compare);
-
-	for (condition =3D rule; condition < end; condition++) {
-		/* See if this condition is already a child of the node */
+	struct _dbus_filter_condition sorted[rule_len];
+	struct _dbus_filter_condition *unused, *condition;
+	struct _dbus_filter_condition *end =3D sorted + rule_len;
+
+	memcpy(sorted, rule, sizeof(sorted));
+	qsort(sorted, rule_len, sizeof(*condition), condition_compare);
+
+	/*
+	 * Find or create a path in the tree with a node for each
+	 * condition in the rule, loop until all conditions have been
+	 * used.
+	 */
+	unused =3D sorted;
+	while (unused < end) {
+		/*
+		 * Find a child of the node that matches any unused
+		 * condition.  Note there could be multiple matches, we're
+		 * happy with the first we can find.
+		 */
 		while (*node_ptr) {
 			node =3D *node_ptr;
 =

-			if (node->type =3D=3D condition->type &&
-					!strcmp(node->match.value,
+			for (condition =3D unused; condition < end; condition++) {
+				if (condition->type > node->type) {
+					condition =3D end;
+					break;
+				}
+
+				if (condition->type < node->type ||
+						condition->type =3D=3D
+						L_DBUS_MATCH_NONE)
+					continue;
+
+				if (!strcmp(node->match.value,
 						condition->value))
+					break;
+			}
+
+			if (condition < end)
 				break;
 =

 			node_ptr =3D &node->next;
 		}
 =

-		/* Add one */
+		/* Add a node */
 		if (!*node_ptr) {
+			condition =3D unused;
+
 			node =3D l_new(struct filter_node, 1);
 			node->type =3D condition->type;
 			node->match.value =3D l_strdup(condition->value);
@@ -278,6 +307,18 @@ unsigned int _dbus_filter_add_rule(struct _dbus_filter=
 *filter,
 =

 		}
 =

+		/*
+		 * Mark the condition used.  We do this by setting
+		 * condition->type to an invalid value unless it is the
+		 * first condition left in which case we can push the
+		 * rule start.  Another option is to always push the rule
+		 * start and memmove the still unused conditions by one
+		 * if necessary.
+		 */
+		condition->type =3D L_DBUS_MATCH_NONE;
+		while (unused < end && unused[0].type =3D=3D L_DBUS_MATCH_NONE)
+			unused++;
+
 		node_ptr =3D &node->match.children;
 =

 		parent =3D node;
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index ab52895..f4209b8 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -320,10 +320,10 @@ struct _dbus_filter *_dbus_filter_new(struct l_dbus *=
dbus,
 void _dbus_filter_free(struct _dbus_filter *filter);
 =

 unsigned int _dbus_filter_add_rule(struct _dbus_filter *filter,
-					struct _dbus_filter_condition *rule,
-					int rule_len,
-					l_dbus_message_func_t signal_func,
-					void *user_data);
+				const struct _dbus_filter_condition *rule,
+				int rule_len,
+				l_dbus_message_func_t signal_func,
+				void *user_data);
 bool _dbus_filter_remove_rule(struct _dbus_filter *filter, unsigned int id=
);
 =

 char *_dbus_filter_rule_to_str(const struct _dbus_filter_condition *rule,
-- =

2.5.0


--===============3594291514386716441==--

