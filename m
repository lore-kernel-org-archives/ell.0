Content-Type: multipart/mixed; boundary="===============2559303401742015396=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/20] dbus: Add _dbus1_message_iter_skip_entry and gvariant
 variant
Date: Mon, 14 Mar 2016 04:41:17 +0100
Message-ID: <1457926896-9843-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2559303401742015396==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This will be used for the get_nth_string_argument function in
dbus-message.c.  There seems to be no other way to skip over an iterator
entry without knowing the data type.
---
 ell/dbus-private.h     |  1 +
 ell/dbus-util.c        | 16 ++++++++++++++++
 ell/gvariant-private.h |  1 +
 ell/gvariant-util.c    | 10 ++++++++++
 4 files changed, 28 insertions(+)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index 8322475..cfed4f7 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -77,6 +77,7 @@ bool _dbus1_iter_enter_variant(struct l_dbus_message_iter=
 *iter,
 					struct l_dbus_message_iter *variant);
 bool _dbus1_iter_enter_array(struct l_dbus_message_iter *iter,
 					struct l_dbus_message_iter *array);
+bool _dbus1_iter_skip_entry(struct l_dbus_message_iter *iter);
 =

 struct dbus_builder *_dbus1_builder_new(void *body, size_t body_size);
 void _dbus1_builder_free(struct dbus_builder *builder);
diff --git a/ell/dbus-util.c b/ell/dbus-util.c
index 5ab4298..9d5b5af 100644
--- a/ell/dbus-util.c
+++ b/ell/dbus-util.c
@@ -805,6 +805,22 @@ bool _dbus1_iter_enter_array(struct l_dbus_message_ite=
r *iter,
 	return true;
 }
 =

+bool _dbus1_iter_skip_entry(struct l_dbus_message_iter *iter)
+{
+	size_t len;
+	const char *sig_end;
+
+	sig_end =3D calc_len_next_item(iter->sig_start + iter->sig_pos,
+					iter->data, iter->pos, iter->len, &len);
+	if (!sig_end)
+		return false;
+
+	iter->pos +=3D len;
+	iter->sig_pos =3D sig_end - iter->sig_start;
+
+	return true;
+}
+
 struct dbus_builder {
 	struct l_string *signature;
 	void *body;
diff --git a/ell/gvariant-private.h b/ell/gvariant-private.h
index 1acac74..2a20feb 100644
--- a/ell/gvariant-private.h
+++ b/ell/gvariant-private.h
@@ -35,6 +35,7 @@ bool _gvariant_iter_enter_variant(struct l_dbus_message_i=
ter *iter,
 					struct l_dbus_message_iter *variant);
 bool _gvariant_iter_enter_array(struct l_dbus_message_iter *iter,
 					struct l_dbus_message_iter *array);
+bool _gvariant_iter_skip_entry(struct l_dbus_message_iter *iter);
 =

 bool _gvariant_valid_signature(const char *sig);
 int _gvariant_get_alignment(const char *signature);
diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 7534509..1aaddc3 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -731,6 +731,16 @@ bool _gvariant_iter_enter_array(struct l_dbus_message_=
iter *iter,
 						start, item_size);
 }
 =

+bool _gvariant_iter_skip_entry(struct l_dbus_message_iter *iter)
+{
+	size_t size;
+
+	if (!next_item(iter, &size))
+		return false;
+
+	return true;
+}
+
 struct dbus_builder {
 	struct l_string *signature;
 	void *body;
-- =

2.5.0


--===============2559303401742015396==--

