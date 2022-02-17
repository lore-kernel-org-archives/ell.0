Content-Type: multipart/mixed; boundary="===============5746336134360353066=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 2/2] unit: add base64 failure cases
Date: Thu, 17 Feb 2022 12:13:05 -0800
Message-ID: <20220217201305.2065223-2-prestwoj@gmail.com>
In-Reply-To: 20220217201305.2065223-1-prestwoj@gmail.com

--===============5746336134360353066==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-base64.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/unit/test-base64.c b/unit/test-base64.c
index 6e47c2b..2d5099d 100644
--- a/unit/test-base64.c
+++ b/unit/test-base64.c
@@ -30,6 +30,7 @@
 =

 struct base64_decode_test {
 	const char *input;
+	size_t input_size;
 	const uint8_t *output;
 	size_t output_size;
 };
@@ -81,6 +82,46 @@ static void test_base64_decode(const void *data)
 	l_free(decoded);
 }
 =

+/* Length !=3D string length */
+static const struct base64_decode_test error_1 =3D {
+	.input =3D "cGxlYXN1cmUu",
+	.input_size =3D 11
+};
+
+/* Length doesn't include pad */
+static const struct base64_decode_test error_2 =3D {
+	.input =3D "bGVhc3VyZS4=3D",
+	.input_size =3D 11,
+};
+
+/* Length doesn't include pad */
+static const struct base64_decode_test error_3 =3D {
+	.input =3D "ZWFzdXJlLg=3D=3D",
+	.input_size =3D 10
+};
+
+/* Length correct, but data after padding */
+static const struct base64_decode_test error_4 =3D {
+	.input =3D "ZWFzdXJlLg=3D=3DbG",
+	.input_size =3D 14
+};
+
+/* Only pad */
+static const struct base64_decode_test error_5 =3D {
+	.input =3D "=3D=3D",
+	.input_size =3D 2
+};
+
+static void test_base64_error(const void *data)
+{
+	const struct base64_decode_test *test =3D data;
+	uint8_t *decoded;
+	size_t decoded_size;
+
+	decoded =3D l_base64_decode(test->input, test->input_size, &decoded_size);
+	assert(!decoded);
+}
+
 struct base64_encode_test {
 	const char *input;
 	const char *output;
@@ -133,6 +174,11 @@ int main(int argc, char *argv[])
 	l_test_add("base64/decode/test2", test_base64_decode, &decode_2);
 	l_test_add("base64/decode/test3", test_base64_decode, &decode_3);
 	l_test_add("base64/decode/test4", test_base64_decode, &decode_4);
+	l_test_add("base64/decode/test5", test_base64_error, &error_1);
+	l_test_add("base64/decode/test6", test_base64_error, &error_2);
+	l_test_add("base64/decode/test7", test_base64_error, &error_3);
+	l_test_add("base64/decode/test8", test_base64_error, &error_4);
+	l_test_add("base64/decode/test9", test_base64_error, &error_5);
 =

 	l_test_add("base64/encode/test1", test_base64_encode, &encode_1);
 	l_test_add("base64/encode/test2", test_base64_encode, &encode_2);
-- =

2.34.1

--===============5746336134360353066==--

