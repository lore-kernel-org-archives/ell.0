Content-Type: multipart/mixed; boundary="===============1128135761621312104=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 6/6] examples: Check return value of l_tls_set_auth_data
Date: Fri, 05 Aug 2016 13:53:21 -0700
Message-ID: <20160805205321.1427-6-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160805205321.1427-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1128135761621312104==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 6 ++++--
 examples/https-server-test.c | 6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 04a3b37..7a9c2a8 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -119,6 +119,7 @@ int main(int argc, char *argv[])
 	struct in_addr **addr_list;
 	struct sockaddr_in addr;
 	int fd;
+	bool auth_ok =3D true;
 =

 	if (argc !=3D 2 && argc !=3D 3 && argc !=3D 6) {
 		printf("Usage: %s <https-host-name> [<ca-cert-path> "
@@ -172,9 +173,10 @@ int main(int argc, char *argv[])
 	if (argc > 2)
 		l_tls_set_cacert(tls, argv[2]);
 	if (argc > 5)
-		l_tls_set_auth_data(tls, argv[3], argv[4], argv[5]);
+		auth_ok =3D l_tls_set_auth_data(tls, argv[3], argv[4], argv[5]);
 =

-	l_main_run();
+	if (tls && auth_ok)
+		l_main_run();
 =

 	l_io_destroy(io);
 	l_tls_free(tls);
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 0f16ed2..f5f5d7a 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -111,6 +111,7 @@ int main(int argc, char *argv[])
 {
 	struct sockaddr_in addr;
 	int fd, listenfd;
+	bool auth_ok;
 =

 	if (argc !=3D 4 && argc !=3D 5) {
 		printf("Usage: %s <server-cert-path> <server-key-path> "
@@ -159,10 +160,11 @@ int main(int argc, char *argv[])
 =

 	tls =3D l_tls_new(true, https_new_data, https_tls_write,
 			https_tls_ready, https_tls_disconnected, NULL);
-	l_tls_set_auth_data(tls, argv[1], argv[2], argv[3]);
+	auth_ok =3D l_tls_set_auth_data(tls, argv[1], argv[2], argv[3]);
 	l_tls_set_cacert(tls, argc > 4 ? argv[4] : NULL);
 =

-	l_main_run();
+	if (tls && !auth_ok)
+		l_main_run();
 =

 	l_io_destroy(io);
 	l_tls_free(tls);
-- =

2.9.2


--===============1128135761621312104==--

