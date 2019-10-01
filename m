Content-Type: multipart/mixed; boundary="===============5866619359698458690=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2 2/3] unit: update test-tls to use new API definition
Date: Tue, 01 Oct 2019 14:31:39 -0700
Message-ID: <20191001213140.2163-2-prestwoj@gmail.com>
In-Reply-To: <20191001213140.2163-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5866619359698458690==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 unit/test-tls.c | 32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/unit/test-tls.c b/unit/test-tls.c
index 9243e16..2c0ea5c 100644
--- a/unit/test-tls.c
+++ b/unit/test-tls.c
@@ -528,6 +528,13 @@ static void test_tls_with_ver(const struct tls_conn_te=
st *test,
 		},
 	};
 =

+	struct l_certchain *server_cert;
+	struct l_certchain *client_cert;
+	struct l_key *server_key;
+	struct l_key *client_key;
+	struct l_queue *server_ca;
+	struct l_queue *client_ca;
+
 	/* Server */
 	s[0].tls =3D l_tls_new(true, tls_test_new_data, tls_test_write,
 				tls_test_ready, tls_test_disconnected, &s[0]);
@@ -556,16 +563,25 @@ static void test_tls_with_ver(const struct tls_conn_t=
est *test,
 	if (getenv("TLS_DEBUG"))
 		l_tls_set_debug(s[1].tls, tls_debug_cb, "client", NULL);
 =

-	auth_ok =3D l_tls_set_auth_data(s[0].tls, test->server_cert_path,
-					test->server_key_path,
-					test->server_key_passphrase);
+	server_cert =3D l_pem_load_certificate_chain(test->server_cert_path);
+	client_cert =3D l_pem_load_certificate_chain(test->client_cert_path);
+
+	server_key =3D l_pem_load_private_key(test->server_key_path,
+						test->server_key_passphrase,
+						NULL);
+	client_key =3D l_pem_load_private_key(test->client_key_path,
+						test->client_key_passphrase,
+						NULL);
+
+	server_ca =3D l_pem_load_certificate_list(test->server_ca_cert_path);
+	client_ca =3D l_pem_load_certificate_list(test->client_ca_cert_path);
+
+	auth_ok =3D l_tls_set_auth_data(s[0].tls, server_cert, server_key);
 	assert(auth_ok);
-	auth_ok =3D l_tls_set_auth_data(s[1].tls, test->client_cert_path,
-					test->client_key_path,
-					test->client_key_passphrase);
+	auth_ok =3D l_tls_set_auth_data(s[1].tls, client_cert, client_key);
 	assert(auth_ok);
-	assert(l_tls_set_cacert(s[0].tls, test->server_ca_cert_path));
-	assert(l_tls_set_cacert(s[1].tls, test->client_ca_cert_path));
+	assert(l_tls_set_cacert(s[0].tls, server_ca));
+	assert(l_tls_set_cacert(s[1].tls, client_ca));
 =

 	if (test->client_domain_mask)
 		l_tls_set_domain_mask(s[1].tls, test->client_domain_mask);
-- =

2.17.1

--===============5866619359698458690==--

