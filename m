Content-Type: multipart/mixed; boundary="===============1569587940585825467=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/5] examples: More error messages in https-{client,
 server}-test
Date: Fri, 20 Nov 2020 21:28:31 +0100
Message-ID: <20201120202833.43358-3-andrew.zaborowski@intel.com>
In-Reply-To: <20201120202833.43358-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1569587940585825467==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Change the error messages to go to stderr and add messages on
certificate and key loading errors.
---
 examples/https-client-test.c | 39 ++++++++++++++++++++++++--------
 examples/https-server-test.c | 44 ++++++++++++++++++++++++------------
 2 files changed, 59 insertions(+), 24 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index eaa7900..2c8d020 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -67,7 +67,7 @@ static void https_tls_disconnected(enum l_tls_alert_desc =
reason, bool remote,
 					void *user_data)
 {
 	if (reason)
-		printf("TLS error: %s\n", l_tls_alert_to_str(reason));
+		fprintf(stderr, "TLS error: %s\n", l_tls_alert_to_str(reason));
 	l_main_quit();
 }
 =

@@ -137,6 +137,7 @@ int main(int argc, char *argv[])
 	struct l_certchain *cert =3D NULL;
 	struct l_key *priv_key =3D NULL;
 	struct l_queue *ca_cert =3D NULL;
+	bool encrypted;
 =

 	if (argc !=3D 2 && argc !=3D 3 && argc !=3D 6) {
 		printf("Usage: %s <https-host-name> [<ca-cert-path> "
@@ -153,19 +154,19 @@ int main(int argc, char *argv[])
 	hostname =3D argv[1];
 	he =3D gethostbyname(hostname);
 	if (!he) {
-		printf("gethostbyname: %s\n", strerror(errno));
+		fprintf(stderr, "gethostbyname: %s\n", strerror(errno));
 		return -1;
 	}
 =

 	addr_list =3D (struct in_addr **) he->h_addr_list;
 	if (!addr_list) {
-		printf("No host addresses found\n");
+		fprintf(stderr, "No host addresses found\n");
 		return -1;
 	}
 =

 	fd =3D socket(AF_INET, SOCK_STREAM, 0);
 	if (fd < 0) {
-		printf("socket: %s\n", strerror(errno));
+		fprintf(stderr, "socket: %s\n", strerror(errno));
 		return -1;
 	}
 =

@@ -174,7 +175,7 @@ int main(int argc, char *argv[])
 	addr.sin_port =3D htons(443);
 	memcpy(&addr.sin_addr, addr_list[0], sizeof(addr.sin_addr));
 	if (connect(fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
-		printf("connect: %s\n", strerror(errno));
+		fprintf(stderr, "connect: %s\n", strerror(errno));
 		return -1;
 	}
 =

@@ -192,14 +193,32 @@ int main(int argc, char *argv[])
 	if (getenv("TLS_DEBUG"))
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

-	if (argc >=3D 3)
+	if (argc >=3D 3) {
 		ca_cert =3D l_pem_load_certificate_list(argv[2]);
+		if (!cert) {
+			fprintf(stderr, "Couldn't load the CA certificates\n");
+			return -1;
+		}
+	}
 =

-	if (argc >=3D 4)
+	if (argc >=3D 4) {
 		cert =3D l_pem_load_certificate_chain(argv[3]);
+		if (!cert) {
+			fprintf(stderr,
+				"Couldn't load the server certificate\n");
+			return -1;
+		}
+	}
 =

-	if (argc >=3D 6)
-		priv_key =3D l_pem_load_private_key(argv[4], argv[5], NULL);
+	if (argc >=3D 6) {
+		priv_key =3D l_pem_load_private_key(argv[4], argv[5], &encrypted);
+		if (!priv_key) {
+			fprintf(stderr,
+				"Couldn't load the client private key%s\n",
+				encrypted ? " (encrypted)" : "");
+			return -1;
+		}
+	}
 =

 	auth_ok =3D (argc <=3D 2 || l_tls_set_cacert(tls, ca_cert)) &&
 		(argc <=3D 5 ||
@@ -209,7 +228,7 @@ int main(int argc, char *argv[])
 	if (tls && auth_ok)
 		l_main_run();
 	else {
-		printf("TLS setup failed\n");
+		fprintf(stderr, "TLS setup failed\n");
 		l_queue_destroy(ca_cert, (l_queue_destroy_func_t) l_cert_free);
 		l_certchain_free(cert);
 		l_key_free(priv_key);
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 2512601..53a11e2 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -42,7 +42,7 @@ bool served;
 static void https_io_disconnect(struct l_io *io, void *user_data)
 {
 	if (!served)
-		printf("Disconnected before serving a page\n");
+		fprintf(stderr, "Disconnected before serving a page\n");
 	l_main_quit();
 }
 =

@@ -54,7 +54,7 @@ static bool https_io_read(struct l_io *io, void *user_dat=
a)
 	l =3D read(l_io_get_fd(io), buf, sizeof(buf));
 	if (l =3D=3D 0) {
 		if (!served)
-			printf("EOF before serving a page\n");
+			fprintf(stderr, "EOF before serving a page\n");
 		l_main_quit();
 	} else if (l > 0)
 		l_tls_handle_rx(tls, buf, l);
@@ -66,7 +66,7 @@ static void https_tls_disconnected(enum l_tls_alert_desc =
reason, bool remote,
 					void *user_data)
 {
 	if (reason)
-		printf("TLS error: %s\n", l_tls_alert_to_str(reason));
+		fprintf(stderr, "TLS error: %s\n", l_tls_alert_to_str(reason));
 	l_main_quit();
 }
 =

@@ -93,7 +93,7 @@ static void https_tls_write(const uint8_t *data, size_t l=
en, void *user_data)
 	while (len) {
 		r =3D send(l_io_get_fd(io), data, len, MSG_NOSIGNAL);
 		if (r < 0) {
-			printf("send: %s\n", strerror(errno));
+			fprintf(stderr, "send: %s\n", strerror(errno));
 			l_main_quit();
 			break;
 		}
@@ -123,6 +123,7 @@ int main(int argc, char *argv[])
 	struct l_certchain *cert;
 	struct l_key *priv_key;
 	struct l_queue *ca_cert =3D NULL;
+	bool encrypted;
 =

 	if (argc !=3D 4 && argc !=3D 5) {
 		printf("Usage: %s <server-cert-path> <server-key-path> "
@@ -146,11 +147,11 @@ int main(int argc, char *argv[])
 	addr.sin_port =3D htons(1234);
 =

 	if (bind(listenfd, (struct sockaddr *) &addr, sizeof(addr)) =3D=3D -1) {
-		printf("bind: %s\n", strerror(errno));
+		fprintf(stderr, "bind: %s\n", strerror(errno));
 		return -1;
 	}
 	if (listen(listenfd, 1) =3D=3D -1) {
-		printf("listen: %s\n", strerror(errno));
+		fprintf(stderr, "listen: %s\n", strerror(errno));
 		return -1;
 	}
 =

@@ -159,13 +160,34 @@ int main(int argc, char *argv[])
 	fd =3D accept(listenfd, NULL, NULL);
 	close(listenfd);
 	if (fd =3D=3D -1) {
-		printf("accept: %s\n", strerror(errno));
+		fprintf(stderr, "accept: %s\n", strerror(errno));
 		return -1;
 	}
 =

 	if (!l_main_init())
 		return -1;
 =

+	cert =3D l_pem_load_certificate_chain(argv[1]);
+	if (!cert) {
+		fprintf(stderr, "Couldn't load the server certificate\n");
+		return -1;
+	}
+
+	priv_key =3D l_pem_load_private_key(argv[2], argv[3], &encrypted);
+	if (!priv_key) {
+		fprintf(stderr, "Couldn't load the server private key%s\n",
+			encrypted ? " (encrypted)" : "");
+		return -1;
+	}
+
+	if (argc >=3D 5) {
+		ca_cert =3D l_pem_load_certificate_list(argv[4]);
+		if (!cert) {
+			fprintf(stderr, "Couldn't load the CA certificates\n");
+			return -1;
+		}
+	}
+
 	io =3D l_io_new(fd);
 	l_io_set_close_on_destroy(io, true);
 	l_io_set_read_handler(io, https_io_read, tls, NULL);
@@ -177,12 +199,6 @@ int main(int argc, char *argv[])
 	if (getenv("TLS_DEBUG"))
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

-	cert =3D l_pem_load_certificate_chain(argv[1]);
-	priv_key =3D l_pem_load_private_key(argv[2], argv[3], NULL);
-
-	if (argc >=3D 5)
-		ca_cert =3D l_pem_load_certificate_list(argv[4]);
-
 	auth_ok =3D l_tls_set_auth_data(tls, cert, priv_key) &&
 		(argc <=3D 4 || l_tls_set_cacert(tls, ca_cert)) &&
 		l_tls_start(tls);
@@ -190,7 +206,7 @@ int main(int argc, char *argv[])
 	if (tls && auth_ok)
 		l_main_run();
 	else {
-		printf("TLS setup failed\n");
+		fprintf(stderr, "TLS setup failed\n");
 		l_queue_destroy(ca_cert, (l_queue_destroy_func_t) l_cert_free);
 		l_certchain_free(cert);
 		l_key_free(priv_key);
-- =

2.25.1

--===============1569587940585825467==--

