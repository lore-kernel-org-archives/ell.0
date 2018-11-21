Content-Type: multipart/mixed; boundary="===============4935059167821973968=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 14/16] examples: Improve messages printed by https examples
Date: Wed, 21 Nov 2018 16:09:01 +0100
Message-ID: <20181121150903.24437-14-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4935059167821973968==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure we print something in all situations that cause the end of the
main loop.  Print the "page served" message before l_tls_close to not
imply that we sent the page after the TLS alert message.  Use printf
consistently to avoid potential confusion is messages were buffered
separately by l_info.
---
 examples/https-client-test.c |  4 +++-
 examples/https-server-test.c | 13 +++++++++----
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 6ba862d..ccf168e 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -115,7 +115,7 @@ static void https_tls_ready(const char *peer_identity, =
void *user_data)
 =

 static void https_tls_debug_cb(const char *str, void *user_data)
 {
-	l_info("%s", str);
+	printf("%s\n", str);
 }
 =

 int main(int argc, char *argv[])
@@ -186,6 +186,8 @@ int main(int argc, char *argv[])
 =

 	if (tls && auth_ok)
 		l_main_run();
+	else
+		printf("TLS setup failed\n");
 =

 	l_io_destroy(io);
 	l_tls_free(tls);
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 9a0a3dc..9940a0b 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -52,9 +52,11 @@ static bool https_io_read(struct l_io *io, void *user_da=
ta)
 	int l;
 =

 	l =3D read(l_io_get_fd(io), buf, sizeof(buf));
-	if (l =3D=3D 0)
+	if (l =3D=3D 0) {
+		if (!served)
+			printf("EOF before serving a page\n");
 		l_main_quit();
-	else if (l > 0)
+	} else if (l > 0)
 		l_tls_handle_rx(tls, buf, l);
 =

 	return true;
@@ -78,9 +80,9 @@ static void https_new_data(const uint8_t *data, size_t le=
n, void *user_data)
 =

 	if (len >=3D 4 && !memcmp(data + len - 4, "\r\n\r\n", 4)) {
 		l_tls_write(tls, (void *) reply, strlen(reply));
-		l_tls_close(tls);
 		served =3D true;
 		printf("Hello world page served\n");
+		l_tls_close(tls);
 	}
 }
 =

@@ -91,6 +93,7 @@ static void https_tls_write(const uint8_t *data, size_t l=
en, void *user_data)
 	while (len) {
 		r =3D send(l_io_get_fd(io), data, len, MSG_NOSIGNAL);
 		if (r < 0) {
+			printf("send error\n");
 			l_main_quit();
 			break;
 		}
@@ -109,7 +112,7 @@ static void https_tls_ready(const char *peer_identity, =
void *user_data)
 =

 static void https_tls_debug_cb(const char *str, void *user_data)
 {
-	l_info("%s", str);
+	printf("%s\n", str);
 }
 =

 int main(int argc, char *argv[])
@@ -176,6 +179,8 @@ int main(int argc, char *argv[])
 =

 	if (tls && auth_ok)
 		l_main_run();
+	else
+		printf("TLS setup failed\n");
 =

 	l_io_destroy(io);
 	l_tls_free(tls);
-- =

2.19.1


--===============4935059167821973968==--

