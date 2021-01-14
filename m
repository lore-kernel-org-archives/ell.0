Content-Type: multipart/mixed; boundary="===============7496733020934517292=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH] cert: Fix warning of possible uninitialized var
Date: Thu, 14 Jan 2021 13:16:02 -0800
Message-ID: <20210114211602.329103-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7496733020934517292==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

ell/cert-crypto.c: In function =E2=80=98cert_pkcs12_pbkdf=E2=80=99:
ell/cert-crypto.c:244:3: error: =E2=80=98bmpstring=E2=80=99 may be used uni=
nitialized in this function [-Werror=3Dmaybe-uninitialized]
  244 |   explicit_bzero(bmpstring, passwd_len);
      |   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
---
 ell/cert-crypto.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
index 6eb4e14..b3d3000 100644
--- a/ell/cert-crypto.c
+++ b/ell/cert-crypto.c
@@ -194,7 +194,7 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,
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

--===============7496733020934517292==--

