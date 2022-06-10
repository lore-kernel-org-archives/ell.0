Content-Type: multipart/mixed; boundary="===============6545427093673094522=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 1/2] cert-crypto: pragma false positive (-Wmaybe-uninitialized)
Date: Fri, 10 Jun 2022 10:11:31 -0700
Message-ID: <20220610171132.334641-1-prestwoj@gmail.com>

--===============6545427093673094522==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On musl-gcc 'bmpstring' was detected as maybe uninitialized. This
is actually a false positive since the usage is guarded by
if (p_len) but the compiler isn't aware. Pragma to ignore this
warning.

ell/cert-crypto.c: In function 'cert_pkcs12_pbkdf':
ell/cert-crypto.c:246:17: error: 'bmpstring' may be used uninitialized in t=
his function [-Werror=3Dmaybe-uninitialized]
  246 |                 explicit_bzero(bmpstring, passwd_len);
---
 ell/cert-crypto.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
index cc312e2..e6e8876 100644
--- a/ell/cert-crypto.c
+++ b/ell/cert-crypto.c
@@ -236,6 +236,8 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,
 		ptr +=3D s_len + salt_len - j;
 	}
 =

+_Pragma("GCC diagnostic push")
+_Pragma("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
 	if (p_len) {
 		for (j =3D passwd_len; j < p_len;
 					j +=3D passwd_len, ptr +=3D passwd_len)
@@ -246,6 +248,7 @@ uint8_t *cert_pkcs12_pbkdf(const char *password,
 		explicit_bzero(bmpstring, passwd_len);
 		l_free(bmpstring);
 	}
+_Pragma("GCC diagnostic pop")
 =

 	key =3D l_malloc(key_len + hash->len);
 =

-- =

2.34.1

--===============6545427093673094522==--

