Content-Type: multipart/mixed; boundary="===============1787626308543416412=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 06/11] tools: Update tls_cert_verify_certchain parameters
Date: Thu, 01 Nov 2018 12:54:48 +0100
Message-ID: <20181101115453.10373-6-andrew.zaborowski@intel.com>
In-Reply-To: <20181101115453.10373-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1787626308543416412==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 tools/certchain-verify.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/tools/certchain-verify.c b/tools/certchain-verify.c
index 1800f68..9bd46b1 100644
--- a/tools/certchain-verify.c
+++ b/tools/certchain-verify.c
@@ -87,7 +87,7 @@ static void usage(const char *bin)
 	printf("%s - TLS certificate chain verification utility\n\n", bin);
 =

 	printf("Usage: %s [options] <ca_cert file> <raw certificates file>\n"
-		"  <ca_cert file> - local CA Certificate to validate against\n"
+		"  <ca_cert file> - local CA Certificate(s) to validate against\n"
 		"  <raw certificates file> - Certificates obtained from PCAP\n"
 		"  --help\n\n", bin);
 }
@@ -96,7 +96,7 @@ int main(int argc, char *argv[])
 {
 	int status =3D EXIT_FAILURE;
 	struct tls_cert *certchain;
-	struct tls_cert *ca_cert;
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
+	ca_certs =3D tls_cert_list_load_file(argv[1]);
+	if (!ca_certs) {
+		fprintf(stderr, "Unable to load CA certifiates\n");
 		goto free_certchain;
 	}
 =

-	if (!tls_cert_verify_certchain(certchain, ca_cert)) {
+	if (!tls_cert_verify_certchain(certchain, ca_certs)) {
 		fprintf(stderr, "Verification failed\n");
 		goto free_cacert;
 	}
@@ -131,7 +131,7 @@ int main(int argc, char *argv[])
 	status =3D EXIT_SUCCESS;
 =

 free_cacert:
-	l_free(ca_cert);
+	l_queue_destroy(ca_certs, l_free);
 free_certchain:
 	tls_cert_free_certchain(certchain);
 done:
-- =

2.19.1


--===============1787626308543416412==--

