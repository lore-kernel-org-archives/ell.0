Content-Type: multipart/mixed; boundary="===============7630931096052227783=="
MIME-Version: 1.0
From: Ravi kumar Veeramally <ravikumar.veeramally@linux.intel.com>
Subject: [PATCH] genl: Introduce new api
Date: Thu, 26 Feb 2015 15:21:25 +0200
Message-ID: <1424956885-14271-1-git-send-email-ravikumar.veeramally@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7630931096052227783==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Introducing l_genl_family_send_and_unref, l_genl_family_dump_and_unref
wrapper functions for l_genl_family_send and l_genl_family_dump
but it unref the message no matter of what the result is.
---
 ell/genl.c | 30 ++++++++++++++++++++++++++++++
 ell/genl.h | 10 ++++++++++
 2 files changed, 40 insertions(+)

diff --git a/ell/genl.c b/ell/genl.c
index 2ef6a34..97eac85 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1091,6 +1091,21 @@ unsigned int l_genl_family_send(struct l_genl_family=
 *family,
 						user_data, destroy);
 }
 =

+unsigned int l_genl_family_send_and_unref(struct l_genl_family *family,
+						struct l_genl_msg *msg,
+						l_genl_msg_func_t callback,
+						void *user_data,
+						l_genl_destroy_func_t destroy)
+{
+	unsigned int id;
+
+	id =3D l_genl_family_send(family, msg, callback, user_data, destroy);
+	l_genl_msg_unref(msg);
+	msg =3D NULL;
+
+	return id;
+}
+
 unsigned int l_genl_family_dump(struct l_genl_family *family,
 				struct l_genl_msg *msg, l_genl_msg_func_t callback,
 				void *user_data, l_genl_destroy_func_t destroy)
@@ -1099,6 +1114,21 @@ unsigned int l_genl_family_dump(struct l_genl_family=
 *family,
 							user_data, destroy);
 }
 =

+unsigned int l_genl_family_dump_and_unref(struct l_genl_family *family,
+						struct l_genl_msg *msg,
+						l_genl_msg_func_t callback,
+						void *user_data,
+						l_genl_destroy_func_t destroy)
+{
+	unsigned int id;
+
+	id =3D l_genl_family_dump(family, msg, callback, user_data, destroy);
+	l_genl_msg_unref(msg);
+	msg =3D NULL;
+
+	return id;
+}
+
 static bool match_request_id(const void *a, const void *b)
 {
 	const struct genl_request *request =3D a;
diff --git a/ell/genl.h b/ell/genl.h
index c628b8c..1f58a94 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -101,9 +101,19 @@ bool l_genl_family_can_dump(struct l_genl_family *fami=
ly, uint8_t cmd);
 unsigned int l_genl_family_send(struct l_genl_family *family,
 				struct l_genl_msg *msg, l_genl_msg_func_t callback,
 				void *user_data, l_genl_destroy_func_t destroy);
+unsigned int l_genl_family_send_and_unref(struct l_genl_family *family,
+						struct l_genl_msg *msg,
+						l_genl_msg_func_t callback,
+						void *user_data,
+						l_genl_destroy_func_t destroy);
 unsigned int l_genl_family_dump(struct l_genl_family *family,
 				struct l_genl_msg *msg, l_genl_msg_func_t callback,
 				void *user_data, l_genl_destroy_func_t destroy);
+unsigned int l_genl_family_dump_and_unref(struct l_genl_family *family,
+						struct l_genl_msg *msg,
+						l_genl_msg_func_t callback,
+						void *user_data,
+						l_genl_destroy_func_t destroy);
 bool l_genl_family_cancel(struct l_genl_family *family, unsigned int id);
 =

 bool l_genl_family_has_group(struct l_genl_family *family, const char *gro=
up);
-- =

2.1.0


--===============7630931096052227783==--

