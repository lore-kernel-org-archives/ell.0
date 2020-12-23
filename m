Content-Type: multipart/mixed; boundary="===============4434160939041295739=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/8] unit: Update tests after l_pkcs5_* renaming
Date: Thu, 24 Dec 2020 00:14:36 +0100
Message-ID: <20201223231437.1078130-7-andrew.zaborowski@intel.com>
In-Reply-To: <20201223231437.1078130-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4434160939041295739==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-pbkdf2.c | 6 +++---
 unit/test-tls.c    | 1 +
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/unit/test-pbkdf2.c b/unit/test-pbkdf2.c
index 37d87ed..3f272ce 100644
--- a/unit/test-pbkdf2.c
+++ b/unit/test-pbkdf2.c
@@ -51,9 +51,9 @@ static void pbkdf2_test(const void *data)
 =

 	key_len =3D test->key_len ? : (strlen(test->key) / 2);
 =

-	result =3D l_pkcs5_pbkdf2(L_CHECKSUM_SHA1, test->password,
-				(const uint8_t *) test->salt, salt_len,
-				test->count, output, key_len);
+	result =3D l_cert_pkcs5_pbkdf2(L_CHECKSUM_SHA1, test->password,
+					(const uint8_t *) test->salt, salt_len,
+					test->count, output, key_len);
 =

 	assert(result =3D=3D true);
 =

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 9503f6b..7937962 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -31,6 +31,7 @@
 #include <ell/ell.h>
 =

 #include "ell/tls-private.h"
+#include "ell/asn1-private.h"
 #include "ell/cert-private.h"
 =

 static void test_tls10_prf(const void *data)
-- =

2.27.0

--===============4434160939041295739==--

