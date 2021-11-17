Content-Type: multipart/mixed; boundary="===============8419094345147944295=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 2/2] unit: update base64 test with API change
Date: Wed, 17 Nov 2021 13:50:00 -0800
Message-ID: <20211117215000.3111579-2-prestwoj@gmail.com>
In-Reply-To: 20211117215000.3111579-1-prestwoj@gmail.com

--===============8419094345147944295==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-base64.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/unit/test-base64.c b/unit/test-base64.c
index 2c2a57d..6e47c2b 100644
--- a/unit/test-base64.c
+++ b/unit/test-base64.c
@@ -115,13 +115,12 @@ static void test_base64_encode(const void *data)
 {
 	const struct base64_encode_test *test =3D data;
 	char *encoded;
-	size_t encoded_size;
 =

 	encoded =3D l_base64_encode((uint8_t *)test->input, strlen(test->input),
-					test->columns, &encoded_size);
+					test->columns);
 	assert(encoded);
-	assert(encoded_size =3D=3D strlen(test->output));
-	assert(!memcmp(encoded, test->output, encoded_size));
+	assert(strlen(encoded) =3D=3D strlen(test->output));
+	assert(!memcmp(encoded, test->output, strlen(encoded)));
 =

 	l_free(encoded);
 }
-- =

2.31.1

--===============8419094345147944295==--

