Content-Type: multipart/mixed; boundary="===============6852214216143449070=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH v2 2/2] unit: Add tests for the suffix check for a string
Date: Mon, 25 Apr 2016 13:51:03 -0700
Message-ID: <1461617463-31883-2-git-send-email-tim.a.kourt@linux.intel.com>
In-Reply-To: <1461617463-31883-1-git-send-email-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6852214216143449070==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-util.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/unit/test-util.c b/unit/test-util.c
index d72646f..427c74a 100644
--- a/unit/test-util.c
+++ b/unit/test-util.c
@@ -62,6 +62,18 @@ static void test_from_hexstring(const void *test_data)
 	assert(!bytes);
 }
 =

+static void test_has_suffix(const void *test_data)
+{
+	const char *str =3D "string";
+	const char *suffix =3D "ing";
+
+	assert(l_str_has_suffix(str, suffix));
+	assert(l_str_has_suffix(str, str));
+	assert(!l_str_has_suffix(NULL, suffix));
+	assert(!l_str_has_suffix(str, NULL));
+	assert(!l_str_has_suffix(suffix, str));
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -69,5 +81,7 @@ int main(int argc, char *argv[])
 	l_test_add("l_util_hexstring", test_hexstring, NULL);
 	l_test_add("l_util_from_hexstring", test_from_hexstring, NULL);
 =

+	l_test_add("l_util_has_suffix", test_has_suffix, NULL);
+
 	return l_test_run();
 }
-- =

2.5.0


--===============6852214216143449070==--

