Content-Type: multipart/mixed; boundary="===============8535999777680128938=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] unit: Fix Clang 8 "-Wstring-plus-int" warning
Date: Wed, 24 Apr 2019 10:48:05 -0700
Message-ID: <20190424174805.7013-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8535999777680128938==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Declare the fixed string in unit/test-checksum.c as a static array
instead of a string literal to address a warning exhibited by Clang 8
regarding addition of an integer to a string:

unit/test-checksum.c:170:30: warning: adding 'unsigned long' to a
      string does not append to the string [-Wstring-plus-int]
        iov[1].iov_base =3D FIXED_STR + FIXED_LEN / 2;
                          ~~~~~~~~~~^~~~~~~~~~~~~~~
unit/test-checksum.c:170:30: note: use array indexing to silence this
      warning
        iov[1].iov_base =3D FIXED_STR + FIXED_LEN / 2;
                                    ^
                          &         [              ]

Storing the string in an array makes it obvious that pointer
arithmetic is being performed.
---
 unit/test-checksum.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/unit/test-checksum.c b/unit/test-checksum.c
index 296395f..f21d0bb 100644
--- a/unit/test-checksum.c
+++ b/unit/test-checksum.c
@@ -28,10 +28,12 @@
 =

 #include <ell/ell.h>
 =

-#define FIXED_STR  "The quick brown fox jumps over the lazy dog. " \
-		   "Jackdaws love my big sphinx of quartz. "       \
-		   "Pack my box with five dozen liquor jugs. "     \
-		   "How razorback-jumping frogs can level six piqued gymnasts!"
+static char FIXED_STR[] =3D
+	"The quick brown fox jumps over the lazy dog. "
+	"Jackdaws love my big sphinx of quartz. "
+	"Pack my box with five dozen liquor jugs. "
+	"How razorback-jumping frogs can level six piqued gymnasts!";
+
 #define FIXED_LEN  (strlen (FIXED_STR))
 =

 static void test_unsupported(const void *data)
-- =

2.20.1


--===============8535999777680128938==--

