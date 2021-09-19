Content-Type: multipart/mixed; boundary="===============5548666262289207876=="
MIME-Version: 1.0
From: Charlotte Delenk <darkkirb at darkkirb.de>
To: ell at lists.01.org
Subject: [PATCH] Restore support for clang and other non-GCC compilers
Date: Sun, 19 Sep 2021 09:07:43 +0200
Message-ID: <20210919070743.5u7aqpchqefd5vev@nutty-noon.ad.darkkirb.de>

--===============5548666262289207876==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The _auto_-macro used in cert.c and tls.c uses a GCC extension that
allows for nested functions. This is not supported by other compilers,
including clang.

Compiling ell with these compilers will result error messages such as:

../ell-0.44/ell/tls.c:1895:2: error: function definition is not allowed here
        _auto_(l_certchain_free) struct l_certchain *certchain =3D NULL;
        ^
../ell-0.44/ell/useful.h:71:2: note: expanded from macro '_auto_'
        _AUTODESTRUCT(__COUNTER__, func)
        ^
../ell-0.44/ell/useful.h:68:2: note: expanded from macro '_AUTODESTRUCT'
        __AUTODESTRUCT(var, func)
        ^
../ell-0.44/ell/useful.h:64:2: note: expanded from macro '__AUTODESTRUCT'
        { func(*(void **) ptr); }                       \
        ^
../ell-0.44/ell/tls.c:1895:2: error: use of undeclared identifier 'cleanup_=
0'
../ell-0.44/ell/useful.h:71:2: note: expanded from macro '_auto_'
        _AUTODESTRUCT(__COUNTER__, func)
        ^
../ell-0.44/ell/useful.h:68:2: note: expanded from macro '_AUTODESTRUCT'
        __AUTODESTRUCT(var, func)
        ^
../ell-0.44/ell/useful.h:65:23: note: expanded from macro '__AUTODESTRUCT'
        __attribute((cleanup(cleanup_ ## var)))
                             ^

This patch will removes the _auto_ macro and implement its functionality
manually in the two locations it is used.

It does not appear to be possible to replace this macro with a more
compatible alternative that does not involve C++.

Signed-off-by: Charlotte Delenk <darkkirb(a)darkkirb.de>
---
 ell/cert.c   |  6 +++++-
 ell/tls.c    |  6 +++++-
 ell/useful.h | 11 -----------
 3 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 141ea1c..13a89e0 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -446,12 +446,16 @@ static struct l_key *cert_try_link(struct l_cert *cer=
t, struct l_keyring *ring)
 		return false;	\
 	} while (0)
 =

+static void cleanup_keyring(void * ptr) {
+	l_keyring_free(*(void **)ptr);
+}
+
 LIB_EXPORT bool l_certchain_verify(struct l_certchain *chain,
 					struct l_queue *ca_certs,
 					const char **error)
 {
 	struct l_keyring *ca_ring =3D NULL;
-	_auto_(l_keyring_free) struct l_keyring *verify_ring =3D NULL;
+	__attribute__((cleanup(cleanup_keyring))) struct l_keyring *verify_ring =
=3D NULL;
 	struct l_cert *cert;
 	struct l_key *prev_key =3D NULL;
 	int verified =3D 0;
diff --git a/ell/tls.c b/ell/tls.c
index c246f1f..1d0e91d 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1888,11 +1888,15 @@ decode_error:
 			"ServerHello decode error");
 }
 =

+static void cleanup_certchain(void * ptr) {
+	l_certchain_free(*(void **)ptr);
+}
+
 static void tls_handle_certificate(struct l_tls *tls,
 					const uint8_t *buf, size_t len)
 {
 	size_t total;
-	_auto_(l_certchain_free) struct l_certchain *certchain =3D NULL;
+	__attribute__((cleanup(cleanup_certchain))) struct l_certchain *certchain=
 =3D NULL;
 	struct l_cert *leaf;
 	size_t der_len;
 	const uint8_t *der;
diff --git a/ell/useful.h b/ell/useful.h
index b4783ce..cd7ec0f 100644
--- a/ell/useful.h
+++ b/ell/useful.h
@@ -59,17 +59,6 @@ static inline unsigned char bit_field(const unsigned cha=
r oct,
 	_x / _d;					\
 })
 =

-#define __AUTODESTRUCT(var, func)			\
-	void cleanup_ ## var(void *ptr)			\
-	{ func(*(void **) ptr); }			\
-	__attribute((cleanup(cleanup_ ## var)))
-
-#define _AUTODESTRUCT(var, func)			\
-	__AUTODESTRUCT(var, func)
-
-#define _auto_(func)					\
-	_AUTODESTRUCT(__COUNTER__, func)
-
 /*
  * Trick the compiler into thinking that var might be changed somehow by
  * the asm
-- =

2.33.0


--===============5548666262289207876==
Content-Type: application/pgp-signature
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="signature.asc"

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KCmlRSXpCQUFCQ0FBZEZpRUVJRzJsNGRvSkJM
YnVTUmE2UE85ZDJwRmE3TEFGQW1GRzRiOEFDZ2tRUE85ZDJwRmEKN0xDQTBCQUFwVEVlNHE3SWhk
bUJtS1JLV2RJY1lMOTJ5ODhkMkJhUHpEQVVsVHNQMXZyeXFLZ0ZEQVAwU1pNNQpLTGlsb0NDaENs
ZkF0OGNTMFZpYTczaDFudXhTdTNLU2ZETTZoT2Y2MXIyNFFkRzlFc090VzUyOFc4ZDE4ZlpnCjIz
ZWs1dFl3d1M2endHZGF5NWNEdjVlRHpRSGwwcWVEZ0JRbjliNGp0ZzZMRDQ3WnJXQ2F5S3p5MDlQ
MjZhZDIKaGZGamFoaXVLWEpscGlab1MxcmJSeVhYUm80anRVOGhkNVJEN0tYSHNQWHlURzZJTmhX
ZUR1M29KZFZFSytKRQprYVM5MGxldzZFOVRjMzBzZ2VvNFgrN1JBUnk2K0RvOUkzS2x0QlQwZzZk
NUtSdVg5TUtjUUpmRGozQ0J2UnFFCjk2YklwNUk3U082RUozV3RaVVo1T0lEQktPN3hDb1oxRjJB
QW5iYzRWaXV6ZGQycy8ydDk4SVBYTWZnV2U1NngKNTZvblBnVnNtKzVEbDlNSjdLc2hxdyt5QXk1
bXo0VUwxR21RTURyT3Fyd0t5bW9VaHY5RUU4Y1FQNDJOUDdTTwpyV1ZoWHJXdUNvNWZsZkFWRmpj
MTV6UVNLelNvV3dtMVNONWxsNmkrd2szRGhMV0hpZk4rN2JWVEJzK2JWK3NoCjJIT284bVhqbFhV
V3REMXlhVU1WejYvYXN2SnpvTkNVdUhWNjFqNTVXMmtSZTFCMjROdW9NU3NGS1dFMGJBTGMKaU44
aWFLam01MHJxdUtHeHBGM2tQWFZZYXN5RTdHc1k5VU5nR0ljTmFWRU9ZQWl4aWwzMXFaOHVyYUhO
YXJCdQpnUWlRWHRsUEZRbVdndEV6Rmo4dkJOTldiNXJST0UraE1uT0pBUnhCSm1rM0o0b1RpNHM9
Cj1scnk1Ci0tLS0tRU5EIFBHUCBTSUdOQVRVUkUtLS0tLQo=

--===============5548666262289207876==--

