Content-Type: multipart/mixed; boundary="===============3613002904063672656=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 15/16] tools: Update certchain-verify's cert API usage
Date: Wed, 21 Nov 2018 16:09:02 +0100
Message-ID: <20181121150903.24437-15-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3613002904063672656==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 tools/certchain-verify.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/certchain-verify.c b/tools/certchain-verify.c
index 99adb17..08eec90 100644
--- a/tools/certchain-verify.c
+++ b/tools/certchain-verify.c
@@ -96,7 +96,7 @@ int main(int argc, char *argv[])
 {
 	int status =3D EXIT_FAILURE;
 	struct l_certchain *certchain;
-	struct l_cert *ca_cert;
+	struct l_queue *ca_certs;
 	int err;
 =

 	if (argc !=3D 3) {
@@ -116,13 +116,13 @@ int main(int argc, char *argv[])
 		goto done;
 	}
 =

-	ca_cert =3D tls_cert_load_file(argv[1]);
-	if (!ca_cert) {
-		fprintf(stderr, "Unable to load CA certifiate\n");
+	ca_certs =3D l_pem_load_certificate_list(argv[1]);
+	if (!ca_certs) {
+		fprintf(stderr, "Unable to load CA certifiates\n");
 		goto free_certchain;
 	}
 =

-	if (!l_certchain_verify(certchain, ca_cert)) {
+	if (!l_certchain_verify(certchain, ca_certs)) {
 		fprintf(stderr, "Verification failed\n");
 		goto free_cacert;
 	}
@@ -131,7 +131,7 @@ int main(int argc, char *argv[])
 	status =3D EXIT_SUCCESS;
 =

 free_cacert:
-	l_cert_free(ca_cert);
+	l_queue_destroy(ca_certs, (l_queue_destroy_func_t) l_cert_free);
 free_certchain:
 	l_certchain_free(certchain);
 done:
-- =

2.19.1


--===============3613002904063672656==--

