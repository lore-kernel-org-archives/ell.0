Content-Type: multipart/mixed; boundary="===============0878818308844979795=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 6/7] examples: Call l_tls_start in https examples
Date: Fri, 21 Dec 2018 23:03:25 +0100
Message-ID: <20181221220326.10112-6-andrew.zaborowski@intel.com>
In-Reply-To: <20181221220326.10112-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0878818308844979795==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 3 ++-
 examples/https-server-test.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index ccf168e..614a1ce 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -182,7 +182,8 @@ int main(int argc, char *argv[])
 =

 	auth_ok =3D (argc <=3D 2 || l_tls_set_cacert(tls, argv[2])) &&
 		(argc <=3D 5 ||
-		 l_tls_set_auth_data(tls, argv[3], argv[4], argv[5]));
+		 l_tls_set_auth_data(tls, argv[3], argv[4], argv[5])) &&
+		l_tls_start(tls);
 =

 	if (tls && auth_ok)
 		l_main_run();
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 9940a0b..8f7f8ca 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -175,7 +175,8 @@ int main(int argc, char *argv[])
 		l_tls_set_debug(tls, https_tls_debug_cb, NULL, NULL);
 =

 	auth_ok =3D l_tls_set_auth_data(tls, argv[1], argv[2], argv[3]) &&
-		(argc <=3D 4 || l_tls_set_cacert(tls, argv[4]));
+		(argc <=3D 4 || l_tls_set_cacert(tls, argv[4])) &&
+		l_tls_start(tls);
 =

 	if (tls && auth_ok)
 		l_main_run();
-- =

2.19.1


--===============0878818308844979795==--

