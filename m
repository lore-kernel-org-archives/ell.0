Content-Type: multipart/mixed; boundary="===============3147365705561991956=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 1/2] base64: Null terminate encoding
Date: Wed, 17 Nov 2021 13:49:59 -0800
Message-ID: <20211117215000.3111579-1-prestwoj@gmail.com>

--===============3147365705561991956==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_base64_encode was returning a char* without any NULL terminator. This
appeared to be written to satisfy the only use in ELL (pem.c) but made
for a confusing public API. Anyone using this API would expect a char*
return to be NULL terminated.

Now l_base64_encode will NULL terminate which also removes the need for
the length out parameter.

pem.c was updated to use strlen rather than rely on the out parameter.
---
 ell/base64.c | 8 ++++----
 ell/base64.h | 3 +--
 ell/pem.c    | 3 ++-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/ell/base64.c b/ell/base64.c
index c241869..e430470 100644
--- a/ell/base64.c
+++ b/ell/base64.c
@@ -107,8 +107,7 @@ LIB_EXPORT uint8_t *l_base64_decode(const char *in, siz=
e_t in_len,
 	return out_buf;
 }
 =

-LIB_EXPORT char *l_base64_encode(const uint8_t *in, size_t in_len,
-					int columns, size_t *n_written)
+LIB_EXPORT char *l_base64_encode(const uint8_t *in, size_t in_len, int col=
umns)
 {
 	const uint8_t *in_end =3D in + in_len;
 	char *out_buf, *out;
@@ -127,8 +126,7 @@ LIB_EXPORT char *l_base64_encode(const uint8_t *in, siz=
e_t in_len,
 	if (columns && out_len)
 		out_len +=3D (out_len - 4) / columns;
 =

-	out_buf =3D l_malloc(out_len);
-	*n_written =3D out_len;
+	out_buf =3D l_malloc(out_len + 1);
 =

 	out =3D out_buf;
 =

@@ -169,5 +167,7 @@ LIB_EXPORT char *l_base64_encode(const uint8_t *in, siz=
e_t in_len,
 	for (; pad < 4; pad++)
 		*out++ =3D '=3D';
 =

+	*out =3D '\0';
+
 	return out_buf;
 }
diff --git a/ell/base64.h b/ell/base64.h
index 74dae8f..8564cdd 100644
--- a/ell/base64.h
+++ b/ell/base64.h
@@ -27,8 +27,7 @@ extern "C" {
 =

 uint8_t *l_base64_decode(const char *in, size_t in_len, size_t *n_written);
 =

-char *l_base64_encode(const uint8_t *in, size_t in_len, int columns,
-				size_t *n_written);
+char *l_base64_encode(const uint8_t *in, size_t in_len, int columns);
 =

 #ifdef __cplusplus
 }
diff --git a/ell/pem.c b/ell/pem.c
index 2b09c2b..9804b91 100644
--- a/ell/pem.c
+++ b/ell/pem.c
@@ -379,7 +379,8 @@ static bool pem_write_one_cert(struct l_cert *cert, voi=
d *user_data)
 =

 	iov[0].iov_base =3D "-----BEGIN CERTIFICATE-----\n";
 	iov[0].iov_len =3D strlen(iov[0].iov_base);
-	iov[1].iov_base =3D l_base64_encode(der, der_len, 64, &iov[1].iov_len);
+	iov[1].iov_base =3D l_base64_encode(der, der_len, 64);
+	iov[1].iov_len =3D strlen(iov[1].iov_base);
 	iov[2].iov_base =3D "\n-----END CERTIFICATE-----\n";
 	iov[2].iov_len =3D strlen(iov[2].iov_base);
 	r =3D L_TFR(writev(*fd, iov, 3));
-- =

2.31.1

--===============3147365705561991956==--

