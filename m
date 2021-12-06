Content-Type: multipart/mixed; boundary="===============6813648613830913565=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] genl: add l_genl_family_request_sent
Date: Mon, 06 Dec 2021 10:17:45 -0800
Message-ID: <20211206181745.1161158-1-prestwoj@gmail.com>

--===============6813648613830913565==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Returns true if a request has been sent to genl. This is useful
for knowning if a l_genl_family_cancel call will have any effect
besides NULLing out the callback.
---
 ell/ell.sym |  1 +
 ell/genl.c  | 16 ++++++++++++++++
 ell/genl.h  |  1 +
 3 files changed, 18 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index febb855..51db458 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -342,6 +342,7 @@ global:
 	l_genl_family_send;
 	l_genl_family_dump;
 	l_genl_family_cancel;
+	l_genl_family_request_sent;
 	l_genl_family_register;
 	l_genl_family_unregister;
 	/* hwdb */
diff --git a/ell/genl.c b/ell/genl.c
index 7d79ef5..9a52be4 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1960,6 +1960,22 @@ done:
 	return true;
 }
 =

+LIB_EXPORT bool l_genl_family_request_sent(struct l_genl_family *family,
+						unsigned int id)
+{
+	struct l_genl *genl;
+
+	if (unlikely(!family) || unlikely(!id))
+		return false;
+
+	genl =3D family->genl;
+	if (!genl)
+		return false;
+
+	return l_queue_find(genl->pending_list, match_request_id,
+				L_UINT_TO_PTR(id)) !=3D NULL;
+}
+
 static void add_membership(struct l_genl *genl, struct genl_mcast *mcast)
 {
 	int group =3D mcast->id;
diff --git a/ell/genl.h b/ell/genl.h
index 7550bf8..7e5b7bb 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -141,6 +141,7 @@ unsigned int l_genl_family_dump(struct l_genl_family *f=
amily,
 				void *user_data,
 				l_genl_destroy_func_t destroy);
 bool l_genl_family_cancel(struct l_genl_family *family, unsigned int id);
+bool l_genl_family_request_sent(struct l_genl_family *family, unsigned int=
 id);
 =

 unsigned int l_genl_family_register(struct l_genl_family *family,
 				const char *group, l_genl_msg_func_t callback,
-- =

2.31.1

--===============6813648613830913565==--

