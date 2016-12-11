Content-Type: multipart/mixed; boundary="===============2163152360464924542=="
MIME-Version: 1.0
From: Markus Ongyerth <ongy@ongy.net>
Subject: [PATCH 2/2] Add tests for l_utf8_get_codepoint
Date: Sun, 11 Dec 2016 15:48:07 +0100
Message-ID: <20161211144807.25441-2-ongy@ongy.net>
In-Reply-To: <20161211144807.25441-1-ongy@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2163152360464924542==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-utf8.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/unit/test-utf8.c b/unit/test-utf8.c
index 55b0d72..7c641bc 100644
--- a/unit/test-utf8.c
+++ b/unit/test-utf8.c
@@ -815,6 +815,20 @@ static struct utf8_validate_test utf8_validate_test79 =
=3D {
 	.ucs4_len =3D 5,
 };
 =

+static void test_utf8_codepoint(const struct utf8_validate_test *test)
+{
+	unsigned int i, pos;
+	int ret;
+	wchar_t val;
+
+	for (i =3D 0, pos =3D 0; i < test->ucs4_len; ++i) {
+		ret =3D l_utf8_get_codepoint(test->utf8 + pos,
+						test->utf8_len - pos, &val);
+		assert(ret > 0 && val =3D=3D test->ucs4[i]);
+		pos +=3D ret;
+	}
+}
+
 static void test_utf8_validate(const void *test_data)
 {
 	const struct utf8_validate_test *test =3D test_data;
@@ -827,6 +841,10 @@ static void test_utf8_validate(const void *test_data)
 		assert(res =3D=3D true);
 	else
 		assert(res =3D=3D false);
+
+	if (test->type =3D=3D UTF8_VALIDATE_TYPE_VALID && test->ucs4_len) {
+		test_utf8_codepoint(test);
+	}
 }
 =

 struct utf8_strlen_test {
-- =

2.10.2


--===============2163152360464924542==--

