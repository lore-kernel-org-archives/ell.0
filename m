Content-Type: multipart/mixed; boundary="===============5774094597805557882=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/5] examples: Only access argv up to argc
Date: Tue, 29 Oct 2019 01:24:42 +0100
Message-ID: <20191029002443.23574-4-andrew.zaborowski@intel.com>
In-Reply-To: <20191029002443.23574-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5774094597805557882==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

There was an assumption that argv elements beyond argc were NULL.  This
may be true under some conditions but I guess it's better to not assume
that in example code.
---
 examples/https-client-test.c | 17 +++++++++++------
 examples/https-server-test.c |  6 ++++--
 2 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 281bdb8..11dce88 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -134,9 +134,9 @@ int main(int argc, char *argv[])
 	struct sockaddr_in addr;
 	int fd;
 	bool auth_ok;
-	struct l_certchain *cert;
-	struct l_key *priv_key;
-	struct l_queue *ca_cert;
+	struct l_certchain *cert =3D NULL;
+	struct l_key *priv_key =3D NULL;
+	struct l_queue *ca_cert =3D NULL;
 =

 	if (argc !=3D 2 && argc !=3D 3 && argc !=3D 6) {
 		printf("Usage: %s <https-host-name> [<ca-cert-path> "
@@ -192,9 +192,14 @@ int main(int argc, char *argv[])
 	if (getenv("TLS_DEBUG"))
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

-	ca_cert =3D l_pem_load_certificate_list(argv[2]);
-	cert =3D l_pem_load_certificate_chain(argv[3]);
-	priv_key =3D l_pem_load_private_key(argv[4], argv[5], NULL);
+	if (argc >=3D 3)
+		ca_cert =3D l_pem_load_certificate_list(argv[2]);
+
+	if (argc >=3D 4)
+		cert =3D l_pem_load_certificate_chain(argv[3]);
+
+	if (argc >=3D 6)
+		priv_key =3D l_pem_load_private_key(argv[4], argv[5], NULL);
 =

 	auth_ok =3D (argc <=3D 2 || l_tls_set_cacert(tls, ca_cert)) &&
 		(argc <=3D 5 ||
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 93c0bcf..813650a 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -122,7 +122,7 @@ int main(int argc, char *argv[])
 	bool auth_ok;
 	struct l_certchain *cert;
 	struct l_key *priv_key;
-	struct l_queue *ca_cert;
+	struct l_queue *ca_cert =3D NULL;
 =

 	if (argc !=3D 4 && argc !=3D 5) {
 		printf("Usage: %s <server-cert-path> <server-key-path> "
@@ -179,7 +179,9 @@ int main(int argc, char *argv[])
 =

 	cert =3D l_pem_load_certificate_chain(argv[1]);
 	priv_key =3D l_pem_load_private_key(argv[2], argv[3], NULL);
-	ca_cert =3D l_pem_load_certificate_list(argv[4]);
+
+	if (argc >=3D 5)
+		ca_cert =3D l_pem_load_certificate_list(argv[4]);
 =

 	auth_ok =3D l_tls_set_auth_data(tls, cert, priv_key) &&
 		(argc <=3D 4 || l_tls_set_cacert(tls, ca_cert)) &&
-- =

2.20.1

--===============5774094597805557882==--

