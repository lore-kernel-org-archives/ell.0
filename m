Content-Type: multipart/mixed; boundary="===============5248072281748767461=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v10 4/4] unit: fix memory leak in test-pem
Date: Fri, 04 Oct 2019 12:51:11 -0700
Message-ID: <20191004195111.8751-4-prestwoj@gmail.com>
In-Reply-To: <20191004195111.8751-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5248072281748767461==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-pem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

-v10:
 * Removed NULL check for label, this is not needed

diff --git a/unit/test-pem.c b/unit/test-pem.c
index 6a927fc..d39003e 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -226,7 +226,7 @@ static void test_pem(const void *data)
 {
 	const struct pem_test *test =3D data;
 	uint8_t *decoded;
-	char *label;
+	char *label =3D NULL;
 	size_t decoded_size;
 =

 	decoded =3D l_pem_load_buffer((const uint8_t *) test->input,
@@ -234,6 +234,7 @@ static void test_pem(const void *data)
 					&label, &decoded_size);
 =

 	if (!test->valid) {
+		l_free(label);
 		assert(!decoded);
 		return;
 	}
-- =

2.17.1

--===============5248072281748767461==--

