Content-Type: multipart/mixed; boundary="===============0367571900756392460=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 3/3] examples: update https server/client with new TLS APIs
Date: Tue, 01 Oct 2019 14:31:40 -0700
Message-ID: <20191001213140.2163-3-prestwoj@gmail.com>
In-Reply-To: <20191001213140.2163-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0367571900756392460==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 11 +++++++++--
 examples/https-server-test.c | 11 +++++++++--
 2 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 9a765c6..281bdb8 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -134,6 +134,9 @@ int main(int argc, char *argv[])
 	struct sockaddr_in addr;
 	int fd;
 	bool auth_ok;
+	struct l_certchain *cert;
+	struct l_key *priv_key;
+	struct l_queue *ca_cert;
 =

 	if (argc !=3D 2 && argc !=3D 3 && argc !=3D 6) {
 		printf("Usage: %s <https-host-name> [<ca-cert-path> "
@@ -189,9 +192,13 @@ int main(int argc, char *argv[])
 	if (getenv("TLS_DEBUG"))
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

-	auth_ok =3D (argc <=3D 2 || l_tls_set_cacert(tls, argv[2])) &&
+	ca_cert =3D l_pem_load_certificate_list(argv[2]);
+	cert =3D l_pem_load_certificate_chain(argv[3]);
+	priv_key =3D l_pem_load_private_key(argv[4], argv[5], NULL);
+
+	auth_ok =3D (argc <=3D 2 || l_tls_set_cacert(tls, ca_cert)) &&
 		(argc <=3D 5 ||
-		 l_tls_set_auth_data(tls, argv[3], argv[4], argv[5])) &&
+		 l_tls_set_auth_data(tls, cert, priv_key)) &&
 		l_tls_start(tls);
 =

 	if (tls && auth_ok)
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 4f706ca..93c0bcf 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -120,6 +120,9 @@ int main(int argc, char *argv[])
 	struct sockaddr_in addr;
 	int fd, listenfd;
 	bool auth_ok;
+	struct l_certchain *cert;
+	struct l_key *priv_key;
+	struct l_queue *ca_cert;
 =

 	if (argc !=3D 4 && argc !=3D 5) {
 		printf("Usage: %s <server-cert-path> <server-key-path> "
@@ -174,8 +177,12 @@ int main(int argc, char *argv[])
 	if (getenv("TLS_DEBUG"))
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

-	auth_ok =3D l_tls_set_auth_data(tls, argv[1], argv[2], argv[3]) &&
-		(argc <=3D 4 || l_tls_set_cacert(tls, argv[4])) &&
+	cert =3D l_pem_load_certificate_chain(argv[1]);
+	priv_key =3D l_pem_load_private_key(argv[2], argv[3], NULL);
+	ca_cert =3D l_pem_load_certificate_list(argv[4]);
+
+	auth_ok =3D l_tls_set_auth_data(tls, cert, priv_key) &&
+		(argc <=3D 4 || l_tls_set_cacert(tls, ca_cert)) &&
 		l_tls_start(tls);
 =

 	if (tls && auth_ok)
-- =

2.17.1

--===============0367571900756392460==--

