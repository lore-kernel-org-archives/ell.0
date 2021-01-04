Content-Type: multipart/mixed; boundary="===============1983457878952606898=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH] pkcs5: Fix warning of possible uninitialized var
Date: Mon, 04 Jan 2021 10:12:27 -0800
Message-ID: <20210104181227.553930-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1983457878952606898==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

ell/pkcs5.c: In function =E2=80=98pkcs12_pbkdf=E2=80=99:
ell/pkcs5.c:240:3: error: =E2=80=98bmpstring=E2=80=99 may be used uninitial=
ized in this function [-Werror=3Dmaybe-uninitialized]
  240 |   explicit_bzero(bmpstring, passwd_len);
      |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
---
 ell/pkcs5.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/pkcs5.c b/ell/pkcs5.c
index 25bf431..47d66ae 100644
--- a/ell/pkcs5.c
+++ b/ell/pkcs5.c
@@ -190,7 +190,7 @@ uint8_t *pkcs12_pbkdf(const char *password, const struc=
t pkcs12_hash *hash,
 {
 	/* All lengths in bytes instead of bits */
 	size_t passwd_len =3D password ? 2 * strlen(password) + 2 : 0;
-	uint8_t *bmpstring;
+	uint8_t *bmpstring =3D NULL;
 	/* Documented as v(ceiling(s/v)), usually will just equal v */
 	unsigned int s_len =3D (salt_len + hash->v - 1) & ~(hash->v - 1);
 	/* Documented as p(ceiling(s/p)), usually will just equal v */
-- =

2.25.4

--===============1983457878952606898==--

