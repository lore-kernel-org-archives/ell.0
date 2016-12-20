Content-Type: multipart/mixed; boundary="===============4876060134762110202=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] genl: Add a genl_family getter for genl
Date: Tue, 20 Dec 2016 17:37:06 -0500
Message-ID: <20161220223706.30876-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4876060134762110202==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add l_genl_family_get_genl function (redundant but accurate name)
---
 ell/genl.c | 8 ++++++++
 ell/genl.h | 1 +
 2 files changed, 9 insertions(+)

diff --git a/ell/genl.c b/ell/genl.c
index c522ae7..cff3a9a 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1173,6 +1173,14 @@ LIB_EXPORT uint32_t l_genl_family_get_version(struct=
 l_genl_family *family)
 	return family->version;
 }
 =

+LIB_EXPORT struct l_genl *l_genl_family_get_genl(struct l_genl_family *fam=
ily)
+{
+	if (unlikely(!family))
+		return 0;
+
+	return family->genl;
+}
+
 static bool match_op_id(const void *a, const void *b)
 {
 	const struct genl_op *op =3D a;
diff --git a/ell/genl.h b/ell/genl.h
index fe188d9..8597c8f 100644
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -104,6 +104,7 @@ bool l_genl_set_unicast_handler(struct l_genl *genl,
 						l_genl_destroy_func_t destroy);
 =

 uint32_t l_genl_family_get_version(struct l_genl_family *family);
+struct l_genl *l_genl_family_get_genl(struct l_genl_family *family);
 =

 bool l_genl_family_can_send(struct l_genl_family *family, uint8_t cmd);
 bool l_genl_family_can_dump(struct l_genl_family *family, uint8_t cmd);
-- =

2.9.3


--===============4876060134762110202==--

