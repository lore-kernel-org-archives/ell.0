Content-Type: multipart/mixed; boundary="===============2419881860190482564=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] tools: Convert certchain-verify to
 l_cert_load_container_file
Date: Wed, 28 Apr 2021 19:30:20 +0200
Message-ID: <20210428173021.2036697-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210428173021.2036697-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2419881860190482564==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Drop the local certificate chain loading code in favour of
l_cert_load_container_file to support the format dumped by
l_tls_set_cert_dump_path and whlie there also other formats.
---
 tools/certchain-verify.c | 68 +++-------------------------------------
 1 file changed, 5 insertions(+), 63 deletions(-)

diff --git a/tools/certchain-verify.c b/tools/certchain-verify.c
index 1a1dab1..732c187 100644
--- a/tools/certchain-verify.c
+++ b/tools/certchain-verify.c
@@ -23,72 +23,16 @@
 #endif
 =

 #include <stdio.h>
-#include <errno.h>
-#include <stdint.h>
-#include <stdbool.h>
-#include <sys/types.h>
-#include <sys/stat.h>
-#include <fcntl.h>
-#include <unistd.h>
-#include <sys/mman.h>
 =

 #include <ell/ell.h>
-#include "ell/tls-private.h"
-
-static int load_cert_chain(const char *file, struct l_certchain **certchai=
n)
-{
-	int fd;
-	struct stat st;
-	char *data;
-	int err;
-
-	fd =3D open(file, O_RDONLY);
-	if (fd < 0) {
-		fprintf(stderr, "Could not open %s: %s\n",
-						file, strerror(errno));
-		return -errno;
-	}
-
-	if (fstat(fd, &st) < 0) {
-		err =3D -errno;
-		fprintf(stderr, "Could not stat %s: %s\n",
-						file, strerror(errno));
-		goto close_file;
-	}
-
-	if (st.st_size =3D=3D 0) {
-		err =3D -EINVAL;
-		fprintf(stderr, "Certificate file %s is empty!\n", file);
-		goto close_file;
-	}
-
-	data =3D mmap(NULL, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
-	if (data =3D=3D MAP_FAILED) {
-		err =3D -errno;
-		fprintf(stderr, "Could not mmap %s: %s\n",
-						file, strerror(errno));
-		goto close_file;
-	}
-
-	err =3D tls_parse_certificate_list(data, st.st_size, certchain);
-	if (err < 0)
-		fprintf(stderr, "Could not parse certificate list: %s\n",
-						strerror(-err));
-
-	munmap(data, st.st_size);
-
-close_file:
-	close(fd);
-	return err;
-}
 =

 static void usage(const char *bin)
 {
-	printf("%s - TLS certificate chain verification utility\n\n", bin);
+	printf("%s - Certificate chain verification utility\n\n", bin);
 =

-	printf("Usage: %s [options] <ca_cert file> <raw certificates file>\n"
-		"  <ca_cert file> - local CA Certificate to validate against\n"
-		"  <raw certificates file> - Certificates obtained from PCAP\n"
+	printf("Usage: %s [options] <ca_cert file> <certchain container>\n"
+		"  <ca_cert file> - local CA Certificates to validate against\n"
+		"  <certchain container> - certificate chain to verify\n"
 		"  --help\n\n", bin);
 }
 =

@@ -97,7 +41,6 @@ int main(int argc, char *argv[])
 	int status =3D EXIT_FAILURE;
 	struct l_certchain *certchain;
 	struct l_queue *ca_certs;
-	int err;
 	const char *error_str;
 =

 	if (argc !=3D 3) {
@@ -107,8 +50,7 @@ int main(int argc, char *argv[])
 =

 	l_log_set_stderr();
 =

-	err =3D load_cert_chain(argv[2], &certchain);
-	if (err < 0)
+	if (!l_cert_load_container_file(argv[2], NULL, &certchain, NULL, NULL))
 		goto done;
 =

 	if (!certchain) {
-- =

2.27.0

--===============2419881860190482564==--

