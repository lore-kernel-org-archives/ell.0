Content-Type: multipart/mixed; boundary="===============4032962317606675996=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 6/7] tools: Update certchain-verify to new certificate API
Date: Mon, 19 Nov 2018 19:23:47 +0100
Message-ID: <20181119182348.4562-6-andrew.zaborowski@intel.com>
In-Reply-To: <20181119182348.4562-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4032962317606675996==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 tools/certchain-verify.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/tools/certchain-verify.c b/tools/certchain-verify.c
index 1800f68..99adb17 100644
--- a/tools/certchain-verify.c
+++ b/tools/certchain-verify.c
@@ -35,7 +35,7 @@
 #include <ell/ell.h>
 #include "ell/tls-private.h"
 =

-static int load_cert_chain(const char *file, struct tls_cert **certchain)
+static int load_cert_chain(const char *file, struct l_certchain **certchai=
n)
 {
 	int fd;
 	struct stat st;
@@ -70,7 +70,7 @@ static int load_cert_chain(const char *file, struct tls_c=
ert **certchain)
 		goto close_file;
 	}
 =

-	err =3D tls_cert_from_certificate_list(data, st.st_size, certchain);
+	err =3D tls_parse_certificate_list(data, st.st_size, certchain);
 	if (err < 0)
 		fprintf(stderr, "Could not parse certificate list: %s\n",
 						strerror(-err));
@@ -95,8 +95,8 @@ static void usage(const char *bin)
 int main(int argc, char *argv[])
 {
 	int status =3D EXIT_FAILURE;
-	struct tls_cert *certchain;
-	struct tls_cert *ca_cert;
+	struct l_certchain *certchain;
+	struct l_cert *ca_cert;
 	int err;
 =

 	if (argc !=3D 3) {
@@ -122,7 +122,7 @@ int main(int argc, char *argv[])
 		goto free_certchain;
 	}
 =

-	if (!tls_cert_verify_certchain(certchain, ca_cert)) {
+	if (!l_certchain_verify(certchain, ca_cert)) {
 		fprintf(stderr, "Verification failed\n");
 		goto free_cacert;
 	}
@@ -131,9 +131,9 @@ int main(int argc, char *argv[])
 	status =3D EXIT_SUCCESS;
 =

 free_cacert:
-	l_free(ca_cert);
+	l_cert_free(ca_cert);
 free_certchain:
-	tls_cert_free_certchain(certchain);
+	l_certchain_free(certchain);
 done:
 	return status;
 }
-- =

2.19.1


--===============4032962317606675996==--

