Content-Type: multipart/mixed; boundary="===============0996700105443529897=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 13/16] examples: Check l_tls_set_cacert return value in https
 examples
Date: Wed, 21 Nov 2018 16:09:00 +0100
Message-ID: <20181121150903.24437-13-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0996700105443529897==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 9 ++++-----
 examples/https-server-test.c | 4 ++--
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 9454a1d..6ba862d 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -124,7 +124,7 @@ int main(int argc, char *argv[])
 	struct in_addr **addr_list;
 	struct sockaddr_in addr;
 	int fd;
-	bool auth_ok =3D true;
+	bool auth_ok;
 =

 	if (argc !=3D 2 && argc !=3D 3 && argc !=3D 6) {
 		printf("Usage: %s <https-host-name> [<ca-cert-path> "
@@ -180,10 +180,9 @@ int main(int argc, char *argv[])
 	if (getenv("TLS_DEBUG"))
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

-	if (argc > 2)
-		l_tls_set_cacert(tls, argv[2]);
-	if (argc > 5)
-		auth_ok =3D l_tls_set_auth_data(tls, argv[3], argv[4], argv[5]);
+	auth_ok =3D (argc <=3D 2 || l_tls_set_cacert(tls, argv[2])) &&
+		(argc <=3D 5 ||
+		 l_tls_set_auth_data(tls, argv[3], argv[4], argv[5]));
 =

 	if (tls && auth_ok)
 		l_main_run();
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index f720f09..9a0a3dc 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -171,8 +171,8 @@ int main(int argc, char *argv[])
 	if (getenv("TLS_DEBUG"))
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

-	auth_ok =3D l_tls_set_auth_data(tls, argv[1], argv[2], argv[3]);
-	l_tls_set_cacert(tls, argc > 4 ? argv[4] : NULL);
+	auth_ok =3D l_tls_set_auth_data(tls, argv[1], argv[2], argv[3]) &&
+		(argc <=3D 4 || l_tls_set_cacert(tls, argv[4]));
 =

 	if (tls && auth_ok)
 		l_main_run();
-- =

2.19.1


--===============0996700105443529897==--

