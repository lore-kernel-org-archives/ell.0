Content-Type: multipart/mixed; boundary="===============0919306225356912609=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/15] dbus: Add message filter logic in dbus-filter.c
Date: Mon, 21 Mar 2016 23:10:15 +0100
Message-ID: <1458598224-29325-6-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0919306225356912609==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This will be used for the public API for adding and removing signal
callbacks.
---
 Makefile.am        |   1 +
 ell/dbus-filter.c  | 351 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus-private.h |  31 +++++
 ell/dbus.h         |  12 ++
 4 files changed, 395 insertions(+)
 create mode 100644 ell/dbus-filter.c

diff --git a/Makefile.am b/Makefile.am
index 256b163..7283a7e 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -75,6 +75,7 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/dbus-message.c \
 			ell/dbus-util.c \
 			ell/dbus-service.c \
+			ell/dbus-filter.c \
 			ell/gvariant-private.h \
 			ell/gvariant-util.c \
 			ell/siphash-private.h \
diff --git a/ell/dbus-filter.c b/ell/dbus-filter.c
new file mode 100644
index 0000000..048f59a
--- /dev/null
+++ b/ell/dbus-filter.c
@@ -0,0 +1,351 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2016  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#define _GNU_SOURCE
+#include <stdlib.h>
+#include <stdio.h>
+
+#include "util.h"
+#include "queue.h"
+#include "hashmap.h"
+#include "string.h"
+#include "dbus.h"
+#include "dbus-private.h"
+#include "gvariant-private.h"
+#include "private.h"
+
+#define NODE_TYPE_CALLBACK	L_DBUS_MATCH_NONE
+
+struct filter_node {
+	enum l_dbus_match_type type;
+	union {
+		struct {
+			char *value;
+			struct filter_node *children;
+			bool remote_rule;
+		} match;
+		struct {
+			l_dbus_message_func_t func;
+			void *user_data;
+		} callback;
+	};
+	unsigned int id;
+	struct filter_node *next;
+};
+
+struct _dbus_filter {
+	struct l_dbus *dbus;
+	struct filter_node *root;
+	unsigned int signal_id;
+	unsigned int last_id;
+	const struct _dbus_filter_ops *driver;
+};
+
+static void filter_subtree_free(struct filter_node *node)
+{
+	struct filter_node *child, *next;
+
+	if (node->type =3D=3D NODE_TYPE_CALLBACK) {
+		l_free(node);
+		return;
+	}
+
+	next =3D node->match.children;
+
+	l_free(node->match.value);
+	l_free(node);
+
+	while (next) {
+		child =3D next;
+		next =3D child->next;
+
+		filter_subtree_free(child);
+	}
+}
+
+static void dbus_filter_destroy(void *data)
+{
+	struct _dbus_filter *filter =3D data;
+
+	if (filter->root)
+		filter_subtree_free(filter->root);
+
+	l_free(filter);
+}
+
+static void filter_dispatch_match_recurse(struct _dbus_filter *filter,
+						struct filter_node *node,
+						struct l_dbus_message *message)
+{
+	const char *value =3D NULL;
+	struct filter_node *child;
+
+	switch ((int) node->type) {
+	case NODE_TYPE_CALLBACK:
+		node->callback.func(message, node->callback.user_data);
+		return;
+
+	case L_DBUS_MATCH_SENDER:
+		value =3D l_dbus_message_get_sender(message);
+		break;
+
+	case L_DBUS_MATCH_TYPE:
+		value =3D _dbus_message_get_type_as_string(message);
+		break;
+
+	case L_DBUS_MATCH_PATH:
+		value =3D l_dbus_message_get_path(message);
+		break;
+
+	case L_DBUS_MATCH_INTERFACE:
+		value =3D l_dbus_message_get_interface(message);
+		break;
+
+	case L_DBUS_MATCH_MEMBER:
+		value =3D l_dbus_message_get_member(message);
+		break;
+
+	case L_DBUS_MATCH_ARG0...(L_DBUS_MATCH_ARG0 + 63):
+		value =3D _dbus_message_get_nth_string_argument(message,
+						node->type - L_DBUS_MATCH_ARG0);
+		break;
+	}
+
+	if (!value)
+		return;
+
+	if (strcmp(value, node->match.value))
+		return;
+
+	for (child =3D node->match.children; child; child =3D child->next)
+		filter_dispatch_match_recurse(filter, child, message);
+}
+
+void _dbus_filter_dispatch(struct l_dbus_message *message, void *user_data)
+{
+	struct _dbus_filter *filter =3D user_data;
+
+	filter_dispatch_match_recurse(filter, filter->root, message);
+}
+
+struct _dbus_filter *_dbus_filter_new(struct l_dbus *dbus,
+					const struct _dbus_filter_ops *driver)
+{
+	struct _dbus_filter *filter;
+
+	filter =3D l_new(struct _dbus_filter, 1);
+
+	filter->dbus =3D dbus;
+	filter->driver =3D driver;
+
+	if (!filter->driver->skip_register)
+		filter->signal_id =3D l_dbus_register(dbus, _dbus_filter_dispatch,
+							filter,
+							dbus_filter_destroy);
+
+	return filter;
+}
+
+void _dbus_filter_free(struct _dbus_filter *filter)
+{
+	if (!filter)
+		return;
+
+	if (!filter->driver->skip_register)
+		l_dbus_unregister(filter->dbus, filter->signal_id);
+	else
+		dbus_filter_destroy(filter);
+}
+
+static int condition_compare(const void *a, const void *b)
+{
+	const struct _dbus_filter_condition *condition_a =3D a, *condition_b =3D =
b;
+
+	return condition_a->type - condition_b->type;
+}
+
+unsigned int _dbus_filter_add_rule(struct _dbus_filter *filter,
+					struct _dbus_filter_condition *rule,
+					int rule_len,
+					l_dbus_message_func_t signal_func,
+					void *user_data)
+{
+	struct filter_node **node_ptr =3D &filter->root;
+	struct filter_node *node;
+	struct filter_node *parent =3D filter->root;
+	bool remote_rule =3D false;
+	struct _dbus_filter_condition *condition, *end =3D rule + rule_len;
+
+	qsort(rule, rule_len, sizeof(*rule), condition_compare);
+
+	for (condition =3D rule; condition < end; condition++) {
+		/* See if this condition is already a child of the node */
+		while (*node_ptr) {
+			node =3D *node_ptr;
+
+			if (node->type =3D=3D condition->type &&
+					!strcmp(node->match.value,
+						condition->value))
+				break;
+
+			node_ptr =3D &node->next;
+		}
+
+		/* Add one */
+		if (!*node_ptr) {
+			node =3D l_new(struct filter_node, 1);
+			node->type =3D condition->type;
+			node->match.value =3D l_strdup(condition->value);
+
+			*node_ptr =3D node;
+		}
+
+		node_ptr =3D &node->match.children;
+
+		parent =3D node;
+
+		/*
+		 * Only have to call AddMatch if none of the parent nodes
+		 * have yet created an AddMatch rule on the server.
+		 */
+		remote_rule |=3D node->match.remote_rule;
+	}
+
+	node =3D l_new(struct filter_node, 1);
+	node->type =3D NODE_TYPE_CALLBACK;
+	node->callback.func =3D signal_func;
+	node->callback.user_data =3D user_data;
+	node->id =3D ++filter->last_id;
+	node->next =3D *node_ptr;
+
+	if (!remote_rule) {
+		if (!filter->driver->add_match(filter->dbus, node->id,
+						rule, rule_len)) {
+			l_free(node);
+			return 0;
+		}
+
+		parent->id =3D node->id;
+		parent->match.remote_rule =3D true;
+	}
+
+	*node_ptr =3D node;
+
+	return node->id;
+}
+
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
+		filter_subtree_free(tmp);
+	}
+
+	return true;
+}
+
+bool _dbus_filter_remove_rule(struct _dbus_filter *filter, unsigned int id)
+{
+	return remove_recurse(filter, &filter->root, id);
+}
+
+char *_dbus_filter_rule_to_str(const struct _dbus_filter_condition *rule,
+				int rule_len)
+{
+	struct l_string *str =3D l_string_new(63);
+	char *key, arg_buf[6];
+	const char *value, *endp;
+
+	for (; rule_len; rule++, rule_len--) {
+		switch ((int) rule->type) {
+		case L_DBUS_MATCH_SENDER:
+			key =3D "sender";
+			break;
+		case L_DBUS_MATCH_TYPE:
+			key =3D "type";
+			break;
+		case L_DBUS_MATCH_PATH:
+			key =3D "path";
+			break;
+		case L_DBUS_MATCH_INTERFACE:
+			key =3D "interface";
+			break;
+		case L_DBUS_MATCH_MEMBER:
+			key =3D "member";
+			break;
+		case L_DBUS_MATCH_ARG0...(L_DBUS_MATCH_ARG0 + 63):
+			key =3D arg_buf;
+			snprintf(arg_buf, sizeof(arg_buf), "arg%i",
+					rule->type - L_DBUS_MATCH_ARG0);
+			break;
+		default:
+			l_string_free(str, true);
+			return NULL;
+		}
+
+		l_string_append(str, key);
+		l_string_append(str, "=3D'");
+
+		/* We only need to escape single-quotes in the values */
+		value =3D rule->value;
+
+		while ((endp =3D strchr(value, '\''))) {
+			l_string_append_fixed(str, value, endp - value);
+			l_string_append(str, "'\\''");
+
+			value =3D endp + 1;
+		}
+
+		l_string_append(str, value);
+		l_string_append_c(str, '\'');
+
+		if (rule_len > 1)
+			l_string_append_c(str, ',');
+	}
+
+	return l_string_free(str, false);
+}
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 607fdf4..d4a4782 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -64,6 +64,9 @@ struct _dbus_property;
 struct l_dbus_message_iter;
 struct l_dbus_message;
 struct l_dbus;
+struct _dbus_filter;
+struct _dbus_filter_condition;
+struct _dbus_filter_ops;
 =

 void _dbus1_iter_init(struct l_dbus_message_iter *iter,
 			struct l_dbus_message *message,
@@ -241,6 +244,34 @@ uint8_t _dbus_get_version(struct l_dbus *dbus);
 int _dbus_get_fd(struct l_dbus *dbus);
 struct _dbus_object_tree *_dbus_get_tree(struct l_dbus *dbus);
 =

+struct _dbus_filter_condition {
+	enum l_dbus_match_type type;
+	const char *value;
+};
+
+struct _dbus_filter_ops {
+	bool skip_register;
+	bool (*add_match)(struct l_dbus *bus, unsigned int id,
+				const struct _dbus_filter_condition *rule,
+				int rule_len);
+	bool (*remove_match)(struct l_dbus *bus, unsigned int id);
+};
+
+struct _dbus_filter *_dbus_filter_new(struct l_dbus *dbus,
+					const struct _dbus_filter_ops *driver);
+void _dbus_filter_free(struct _dbus_filter *filter);
+
+unsigned int _dbus_filter_add_rule(struct _dbus_filter *filter,
+					struct _dbus_filter_condition *rule,
+					int rule_len,
+					l_dbus_message_func_t signal_func,
+					void *user_data);
+bool _dbus_filter_remove_rule(struct _dbus_filter *filter, unsigned int id=
);
+
+char *_dbus_filter_rule_to_str(const struct _dbus_filter_condition *rule,
+				int rule_len);
+void _dbus_filter_dispatch(struct l_dbus_message *message, void *user_data=
);
+
 struct dbus1_filter_data;
 =

 void _dbus1_filter_format_match(struct dbus1_filter_data *data, char *rule,
diff --git a/ell/dbus.h b/ell/dbus.h
index c8fdec1..083f2ff 100644
--- a/ell/dbus.h
+++ b/ell/dbus.h
@@ -42,6 +42,18 @@ enum l_dbus_bus {
 	L_DBUS_SESSION_BUS,
 };
 =

+enum l_dbus_match_type {
+	L_DBUS_MATCH_NONE =3D 0,
+	L_DBUS_MATCH_TYPE,
+	L_DBUS_MATCH_SENDER,
+	L_DBUS_MATCH_PATH,
+	L_DBUS_MATCH_INTERFACE,
+	L_DBUS_MATCH_MEMBER,
+	L_DBUS_MATCH_ARG0,
+};
+
+#define L_DBUS_MATCH_ARGUMENT(i)	(L_DBUS_MATCH_ARG0 + (i))
+
 struct l_dbus;
 struct l_dbus_interface;
 struct l_dbus_message_builder;
-- =

2.5.0


--===============0919306225356912609==--

