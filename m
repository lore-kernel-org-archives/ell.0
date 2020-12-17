Content-Type: multipart/mixed; boundary="===============5595286933939621343=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] examples: Use l_tls_set_cert_dump_path in https examples
Date: Thu, 17 Dec 2020 22:40:45 +0100
Message-ID: <20201217214045.851919-3-andrew.zaborowski@intel.com>
In-Reply-To: <20201217214045.851919-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5595286933939621343==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c |  9 ++++++++-
 examples/https-server-test.c | 18 ++++++++++++++----
 2 files changed, 22 insertions(+), 5 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index e17b271..b0c24b4 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -190,9 +190,16 @@ int main(int argc, char *argv[])
 	tls =3D l_tls_new(false, https_new_data, https_tls_write,
 			https_tls_ready, https_tls_disconnected, NULL);
 =

-	if (getenv("TLS_DEBUG"))
+	if (getenv("TLS_DEBUG")) {
+		char *str;
+
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

+		str =3D l_strdup_printf("/tmp/ell-certchain-%s.pem", hostname);
+		l_tls_set_cert_dump_path(tls, str);
+		l_free(str);
+	}
+
 	if (argc >=3D 3) {
 		ca_cert =3D l_pem_load_certificate_list(argv[2]);
 		if (!ca_cert) {
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 8f3cb3c..6362722 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -117,7 +117,9 @@ static void https_tls_debug_cb(const char *str, void *u=
ser_data)
 =

 int main(int argc, char *argv[])
 {
-	struct sockaddr_in addr;
+	struct sockaddr_in addr =3D {};
+	struct sockaddr_in client_addr =3D {};
+	socklen_t client_addr_len =3D sizeof(client_addr);
 	int fd, listenfd;
 	bool auth_ok;
 	struct l_certchain *cert;
@@ -141,7 +143,6 @@ int main(int argc, char *argv[])
 	setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &(int) { 1 },
 			sizeof(int));
 =

-	memset(&addr, 0, sizeof(addr));
 	addr.sin_family =3D AF_INET;
 	addr.sin_addr.s_addr =3D htonl(INADDR_ANY);
 	addr.sin_port =3D htons(1234);
@@ -157,7 +158,8 @@ int main(int argc, char *argv[])
 =

 	printf("Try https://localhost:1234/ now\n");
 =

-	fd =3D accept(listenfd, NULL, NULL);
+	fd =3D accept(listenfd, (struct sockaddr *) &client_addr,
+			&client_addr_len);
 	close(listenfd);
 	if (fd =3D=3D -1) {
 		fprintf(stderr, "accept: %s\n", strerror(errno));
@@ -196,9 +198,17 @@ int main(int argc, char *argv[])
 	tls =3D l_tls_new(true, https_new_data, https_tls_write,
 			https_tls_ready, https_tls_disconnected, NULL);
 =

-	if (getenv("TLS_DEBUG"))
+	if (getenv("TLS_DEBUG")) {
+		char *str;
+
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

+		str =3D l_strdup_printf("/tmp/ell-certchain-%s.pem",
+					inet_ntoa(client_addr.sin_addr));
+		l_tls_set_cert_dump_path(tls, str);
+		l_free(str);
+	}
+
 	auth_ok =3D l_tls_set_auth_data(tls, cert, priv_key) &&
 		(argc <=3D 4 || l_tls_set_cacert(tls, ca_cert)) &&
 		l_tls_start(tls);
-- =

2.27.0

--===============5595286933939621343==--

