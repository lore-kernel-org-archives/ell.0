Content-Type: multipart/mixed; boundary="===============7085690518292022697=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 5/5] examples: Free tls certificate data on error
Date: Tue, 29 Oct 2019 01:24:43 +0100
Message-ID: <20191029002443.23574-5-andrew.zaborowski@intel.com>
In-Reply-To: <20191029002443.23574-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7085690518292022697==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/https-client-test.c | 6 +++++-
 examples/https-server-test.c | 6 +++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/examples/https-client-test.c b/examples/https-client-test.c
index 11dce88..eaa7900 100644
--- a/examples/https-client-test.c
+++ b/examples/https-client-test.c
@@ -208,8 +208,12 @@ int main(int argc, char *argv[])
 =

 	if (tls && auth_ok)
 		l_main_run();
-	else
+	else {
 		printf("TLS setup failed\n");
+		l_queue_destroy(ca_cert, (l_queue_destroy_func_t) l_cert_free);
+		l_certchain_free(cert);
+		l_key_free(priv_key);
+	}
 =

 	l_io_destroy(io);
 	l_tls_free(tls);
diff --git a/examples/https-server-test.c b/examples/https-server-test.c
index 813650a..2512601 100644
--- a/examples/https-server-test.c
+++ b/examples/https-server-test.c
@@ -189,8 +189,12 @@ int main(int argc, char *argv[])
 =

 	if (tls && auth_ok)
 		l_main_run();
-	else
+	else {
 		printf("TLS setup failed\n");
+		l_queue_destroy(ca_cert, (l_queue_destroy_func_t) l_cert_free);
+		l_certchain_free(cert);
+		l_key_free(priv_key);
+	}
 =

 	l_io_destroy(io);
 	l_tls_free(tls);
-- =

2.20.1

--===============7085690518292022697==--

