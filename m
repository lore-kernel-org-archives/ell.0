Content-Type: multipart/mixed; boundary="===============6954815944464159992=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v3 2/4] checksum: Add L_CHECKSUM_NONE, needed for key crypto
Date: Mon, 01 Aug 2016 14:25:47 -0700
Message-ID: <20160801212549.6526-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160801212549.6526-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6954815944464159992==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/checksum.c | 8 ++++++--
 ell/checksum.h | 1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/ell/checksum.c b/ell/checksum.c
index 7b0e3ee..68be73f 100644
--- a/ell/checksum.c
+++ b/ell/checksum.c
@@ -124,9 +124,9 @@ LIB_EXPORT struct l_checksum *l_checksum_new(enum l_che=
cksum_type type)
 	if (!is_valid_type(type))
 		return NULL;
 =

-	checksum =3D l_new(struct l_checksum, 1);
-
 	switch (type) {
+	case L_CHECKSUM_NONE:
+		return NULL;
 	case L_CHECKSUM_MD5:
 		name =3D "md5";
 		break;
@@ -144,6 +144,8 @@ LIB_EXPORT struct l_checksum *l_checksum_new(enum l_che=
cksum_type type)
 		break;
 	}
 =

+	checksum =3D l_new(struct l_checksum, 1);
+
 	fd =3D create_alg(name);
 	if (fd < 0)
 		goto error;
@@ -202,6 +204,8 @@ struct l_checksum *l_checksum_new_hmac(enum l_checksum_=
type type,
 		return NULL;
 =

 	switch (type) {
+	case L_CHECKSUM_NONE:
+		return NULL;
 	case L_CHECKSUM_MD5:
 		name =3D "hmac(md5)";
 		break;
diff --git a/ell/checksum.h b/ell/checksum.h
index 34401a6..e6eceb9 100644
--- a/ell/checksum.h
+++ b/ell/checksum.h
@@ -32,6 +32,7 @@ extern "C" {
 struct l_checksum;
 =

 enum l_checksum_type {
+	L_CHECKSUM_NONE,
 	L_CHECKSUM_MD5,
 	L_CHECKSUM_SHA1,
 	L_CHECKSUM_SHA256,
-- =

2.9.2


--===============6954815944464159992==--

