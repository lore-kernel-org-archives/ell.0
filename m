Content-Type: multipart/mixed; boundary="===============4371231476605624643=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/15] dbus: Add _dbus1_message_iter_skip_entry.
Date: Mon, 21 Mar 2016 23:10:10 +0100
Message-ID: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4371231476605624643==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This will be used for the get_nth_string_argument function in
dbus-message.c.  There seems to be no other way to skip over an iterator
entry without knowing the data type.
---
 ell/dbus-private.h |  1 +
 ell/dbus-util.c    | 16 ++++++++++++++++
 2 files changed, 17 insertions(+)

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
-- =

2.5.0


--===============4371231476605624643==--

