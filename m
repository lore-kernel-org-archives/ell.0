Content-Type: multipart/mixed; boundary="===============3849278260834037128=="
MIME-Version: 1.0
From: Sergei Trofimovich <slyich@gmail.com>
Subject: [PATCH 2/2] unit/test-uuid: skip tests on system without AF_ALG
 support
Date: Mon, 30 Aug 2021 15:08:46 +0100
Message-ID: <20210830140846.4096201-2-slyich@gmail.com>
In-Reply-To: <20210830140846.4096201-1-slyich@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3849278260834037128==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Fixes test failure on system with CONFIG_CRYPTO_USER_API=3Dn kernel:

    FAIL: unit/test-uuid
    =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

    test-uuid: unit/test-uuid.c:58: test_v3: Assertion `r' failed.
    FAIL unit/test-uuid (exit status: 134)

Lack of AF_ALG family is the result of CONFIG_CRYPTO_USER_API=3Dn.

The change moved supported ciphed detection under respective
cipher detection presence: MD5 for v3 UUID, SHA1 for v5 UUID.

Signed-off-by: Sergei Trofimovich <slyich@gmail.com>
---
 unit/test-uuid.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/unit/test-uuid.c b/unit/test-uuid.c
index e9943b3..4e183b1 100644
--- a/unit/test-uuid.c
+++ b/unit/test-uuid.c
@@ -227,13 +227,16 @@ int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
 =

-	l_test_add("/uuid/v3", test_v3, NULL);
+	if (l_checksum_is_supported(L_CHECKSUM_MD5, false))
+		l_test_add("/uuid/v3", test_v3, NULL);
 =

 	if (l_getrandom_is_supported())
 		l_test_add("/uuid/v4", test_v4, NULL);
 =

-	l_test_add("/uuid/v5", test_v5, NULL);
-	l_test_add("/uuid/to string", test_to_string, NULL);
+	if (l_checksum_is_supported(L_CHECKSUM_SHA1, false)) {
+		l_test_add("/uuid/v5", test_v5, NULL);
+		l_test_add("/uuid/to string", test_to_string, NULL);
+	}
 	l_test_add("/uuid/from string", test_from_string, NULL);
 	l_test_add("/uuid/from string/too short", test_from_string_too_short, NUL=
L);
 	l_test_add("/uuid/from string/too long", test_from_string_too_long, NULL);
-- =

2.33.0

--===============3849278260834037128==--

