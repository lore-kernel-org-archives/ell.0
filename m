Content-Type: multipart/mixed; boundary="===============1365171532068139098=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 11/12] examples: Print TLS debug info if TLS_DEBUG set
Date: Wed, 14 Nov 2018 14:19:01 +0100
Message-ID: <20181114131902.1695-11-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1365171532068139098==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 7 +++++++
 examples/https-server-test.c | 7 +++++++
 2 files changed, 14 insertions(+)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 7135346..e0188ee 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -113,6 +113,11 @@ static void https_tls_ready(const char *peer_identity,=
 void *user_data)
 	l_tls_write(tls, buf, l);
 }
 =

+static void https_tls_debug_cb(const char *str, void *user_data)
+{
+	l_info("%s", str);
+}
+
 int main(int argc, char *argv[])
 {
 	struct hostent *he;
@@ -171,6 +176,8 @@ int main(int argc, char *argv[])
 =

 	tls =3D l_tls_new(false, https_new_data, https_tls_write,
 			https_tls_ready, https_tls_disconnected, NULL);
+	if (getenv("TLS_DEBUG"))
+		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 	if (argc > 2)
 		l_tls_set_cacert(tls, argv[2]);
 	if (argc > 5)
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 2539277..faaf50d 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -107,6 +107,11 @@ static void https_tls_ready(const char *peer_identity,=
 void *user_data)
 		printf("Client not authenticated\n");
 }
 =

+static void https_tls_debug_cb(const char *str, void *user_data)
+{
+	l_info("%s", str);
+}
+
 int main(int argc, char *argv[])
 {
 	struct sockaddr_in addr;
@@ -162,6 +167,8 @@ int main(int argc, char *argv[])
 =

 	tls =3D l_tls_new(true, https_new_data, https_tls_write,
 			https_tls_ready, https_tls_disconnected, NULL);
+	if (getenv("TLS_DEBUG"))
+		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 	auth_ok =3D l_tls_set_auth_data(tls, argv[1], argv[2], argv[3]);
 	l_tls_set_cacert(tls, argc > 4 ? argv[4] : NULL);
 =

-- =

2.19.1


--===============1365171532068139098==--

