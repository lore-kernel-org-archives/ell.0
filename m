Content-Type: multipart/mixed; boundary="===============8429555596779595760=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 12/16] examples: Fix check in https-server-test
Date: Wed, 21 Nov 2018 16:08:59 +0100
Message-ID: <20181121150903.24437-12-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8429555596779595760==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-server-test.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index da44af8..f720f09 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -174,7 +174,7 @@ int main(int argc, char *argv[])
 	auth_ok =3D l_tls_set_auth_data(tls, argv[1], argv[2], argv[3]);
 	l_tls_set_cacert(tls, argc > 4 ? argv[4] : NULL);
 =

-	if (tls && !auth_ok)
+	if (tls && auth_ok)
 		l_main_run();
 =

 	l_io_destroy(io);
-- =

2.19.1


--===============8429555596779595760==--

