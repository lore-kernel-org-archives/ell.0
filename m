Content-Type: multipart/mixed; boundary="===============9075823784424787426=="
MIME-Version: 1.0
From: Michael Tretter <michael.tretter@posteo.net>
Subject: [PATCH 1/2] unit: add utf8_validate_test80 test
Date: Thu, 21 Mar 2019 00:31:44 +0100
Message-ID: <20190320233145.8063-1-michael.tretter@posteo.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9075823784424787426==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

UTF-8 requires the form 10xxxxxx for the second, third and forth bytes
of a well-formed byte sequences.

Add a test for the string "=C3=9Fe" encoded using the Latin-1 Supplement
block. This is a relatively common German letter combination and valid
Unicode, but not UTF-8.
---
 unit/test-utf8.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/unit/test-utf8.c b/unit/test-utf8.c
index 3768506..9b5bc6e 100644
--- a/unit/test-utf8.c
+++ b/unit/test-utf8.c
@@ -815,6 +815,17 @@ static struct utf8_validate_test utf8_validate_test79 =
=3D {
 	.ucs4_len =3D 5,
 };
 =

+static const char utf8_80[] =3D { 0xdf, 0x65 };
+static const wchar_t ucs4_80[] =3D { 0xffff };
+
+static struct utf8_validate_test utf8_validate_test80 =3D {
+	.utf8 =3D utf8_80,
+	.utf8_len =3D 2,
+	.type =3D UTF8_VALIDATE_TYPE_NOTUNICODE,
+	.ucs4 =3D ucs4_80,
+	.ucs4_len =3D 1,
+};
+
 static void test_utf8_codepoint(const struct utf8_validate_test *test)
 {
 	unsigned int i, pos;
@@ -1085,6 +1096,8 @@ int main(int argc, char *argv[])
 					&utf8_validate_test78);
 	l_test_add("Validate UTF 79", test_utf8_validate,
 					&utf8_validate_test79);
+	l_test_add("Validate UTF 80", test_utf8_validate,
+					&utf8_validate_test80);
 =

 	l_test_add("Strlen UTF 1", test_utf8_strlen,
 					&utf8_strlen_test1);
-- =

2.21.0


--===============9075823784424787426==--

