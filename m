Content-Type: multipart/mixed; boundary="===============3696197783958910172=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3 2/6] unit: remove index from pem APIs
Date: Tue, 01 Oct 2019 09:47:39 -0700
Message-ID: <20191001164743.23088-2-prestwoj@gmail.com>
In-Reply-To: <20191001164743.23088-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3696197783958910172==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-key.c | 2 +-
 unit/test-pem.c | 2 +-
 unit/test-tls.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/unit/test-key.c b/unit/test-key.c
index 1b23059..697ff47 100644
--- a/unit/test-key.c
+++ b/unit/test-key.c
@@ -399,7 +399,7 @@ static struct l_cert *load_cert_file(const char *filena=
me)
 	char *label;
 	struct l_cert *cert;
 =

-	der =3D l_pem_load_file(filename, 0, &label, &len);
+	der =3D l_pem_load_file(filename, &label, &len);
 	if (!der)
 		return NULL;
 =

diff --git a/unit/test-pem.c b/unit/test-pem.c
index df396ce..6a927fc 100644
--- a/unit/test-pem.c
+++ b/unit/test-pem.c
@@ -230,7 +230,7 @@ static void test_pem(const void *data)
 	size_t decoded_size;
 =

 	decoded =3D l_pem_load_buffer((const uint8_t *) test->input,
-					strlen(test->input), 0,
+					strlen(test->input),
 					&label, &decoded_size);
 =

 	if (!test->valid) {
diff --git a/unit/test-tls.c b/unit/test-tls.c
index f4c5cb1..9243e16 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -214,7 +214,7 @@ static struct l_cert *load_cert_file(const char *filena=
me)
 	char *label;
 	struct l_cert *cert;
 =

-	der =3D l_pem_load_file(filename, 0, &label, &len);
+	der =3D l_pem_load_file(filename, &label, &len);
 	if (!der)
 		return NULL;
 =

-- =

2.17.1

--===============3696197783958910172==--

