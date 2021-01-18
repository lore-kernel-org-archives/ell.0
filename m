Content-Type: multipart/mixed; boundary="===============3788674509764203870=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH v2] cert: Fix warning of possible uninitialized var
Date: Mon, 18 Jan 2021 10:20:28 -0800
Message-ID: <20210118182028.964376-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3788674509764203870==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

ell/cert-crypto.c: In function =E2=80=98cert_pkcs12_pbkdf=E2=80=99:
ell/cert-crypto.c:244:3: error: =E2=80=98bmpstring=E2=80=99 may be used uni=
nitialized in this function [-Werror=3Dmaybe-uninitialized]
  244 |   explicit_bzero(bmpstring, passwd_len);
      |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
---
 ell/cert-crypto.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
index 6eb4e14..838d5b5 100644
--- a/ell/cert-crypto.c
+++ b/ell/cert-crypto.c
@@ -198,7 +198,8 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,
 	/* Documented as v(ceiling(s/v)), usually will just equal v */
 	unsigned int s_len =3D (salt_len + hash->v - 1) & ~(hash->v - 1);
 	/* Documented as p(ceiling(s/p)), usually will just equal v */
-	unsigned int p_len =3D (passwd_len + hash->v - 1) & ~(hash->v - 1);
+	unsigned int p_len =3D password ?
+			(passwd_len + hash->v - 1) & ~(hash->v - 1) : 0;
 	uint8_t di[hash->v + s_len + p_len];
 	uint8_t *ptr;
 	unsigned int j;
@@ -235,10 +236,11 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,
 		ptr +=3D s_len + salt_len - j;
 	}
 =

-	for (j =3D passwd_len; j < p_len; j +=3D passwd_len, ptr +=3D passwd_len)
-		memcpy(ptr, bmpstring, passwd_len);
-
 	if (p_len) {
+		for (j =3D passwd_len; j < p_len;
+					j +=3D passwd_len, ptr +=3D passwd_len)
+			memcpy(ptr, bmpstring, passwd_len);
+
 		memcpy(ptr, bmpstring, p_len + passwd_len - j);
 =

 		explicit_bzero(bmpstring, passwd_len);
-- =

2.25.4

--===============3788674509764203870==--

