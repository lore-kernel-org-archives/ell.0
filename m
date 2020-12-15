Content-Type: multipart/mixed; boundary="===============3562955270773479649=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/5] examples: Fix arguments check in https-client-test
Date: Tue, 15 Dec 2020 23:53:44 +0100
Message-ID: <20201215225345.791738-4-andrew.zaborowski@intel.com>
In-Reply-To: <20201215225345.791738-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3562955270773479649==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 2c8d020..e17b271 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -195,7 +195,7 @@ int main(int argc, char *argv[])
 =

 	if (argc >=3D 3) {
 		ca_cert =3D l_pem_load_certificate_list(argv[2]);
-		if (!cert) {
+		if (!ca_cert) {
 			fprintf(stderr, "Couldn't load the CA certificates\n");
 			return -1;
 		}
-- =

2.27.0

--===============3562955270773479649==--

