Content-Type: multipart/mixed; boundary="===============8727363615540350574=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 7/7] examples: Further improve https example error messages
Date: Fri, 21 Dec 2018 23:03:26 +0100
Message-ID: <20181221220326.10112-7-andrew.zaborowski@intel.com>
In-Reply-To: <20181221220326.10112-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8727363615540350574==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 13 +++++++++++--
 examples/https-server-test.c |  2 +-
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 614a1ce..9a765c6 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -38,9 +38,12 @@
 static struct l_io *io;
 static struct l_tls *tls;
 static const char *hostname;
+static bool ready;
 =

 static void https_io_disconnect(struct l_io *io, void *user_data)
 {
+	if (!ready)
+		printf("socket disconnected\n");
 	l_main_quit();
 }
 =

@@ -50,9 +53,11 @@ static bool https_io_read(struct l_io *io, void *user_da=
ta)
 	int l;
 =

 	l =3D read(l_io_get_fd(io), buf, sizeof(buf));
-	if (l =3D=3D 0)
+	if (l =3D=3D 0) {
+		if (!ready)
+			printf("socket EOF\n");
 		l_main_quit();
-	else if (l > 0)
+	} else if (l > 0)
 		l_tls_handle_rx(tls, buf, l);
 =

 	return true;
@@ -73,6 +78,7 @@ static void https_new_data(const uint8_t *data, size_t le=
n, void *user_data)
 	while (len) {
 		r =3D write(1, data, len);
 		if (r < 0) {
+			printf("socket EOF\n");
 			l_main_quit();
 			break;
 		}
@@ -88,6 +94,7 @@ static void https_tls_write(const uint8_t *data, size_t l=
en, void *user_data)
 	while (len) {
 		r =3D send(l_io_get_fd(io), data, len, MSG_NOSIGNAL);
 		if (r < 0) {
+			printf("socket send: %s\n", strerror(errno));
 			l_main_quit();
 			break;
 		}
@@ -101,6 +108,8 @@ static void https_tls_ready(const char *peer_identity, =
void *user_data)
 	uint8_t buf[2048];
 	int l;
 =

+	ready =3D true;
+
 	if (peer_identity)
 		printf("Server authenticated as %s\n", peer_identity);
 	else
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 8f7f8ca..4f706ca 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -93,7 +93,7 @@ static void https_tls_write(const uint8_t *data, size_t l=
en, void *user_data)
 	while (len) {
 		r =3D send(l_io_get_fd(io), data, len, MSG_NOSIGNAL);
 		if (r < 0) {
-			printf("send error\n");
+			printf("send: %s\n", strerror(errno));
 			l_main_quit();
 			break;
 		}
-- =

2.19.1


--===============8727363615540350574==--

