Content-Type: multipart/mixed; boundary="===============6232458276289436666=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/10] tls: Report error if private key loading fails
Date: Fri, 11 Aug 2017 01:10:10 +0200
Message-ID: <20170810231016.29445-4-andrew.zaborowski@intel.com>
In-Reply-To: <20170810231016.29445-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6232458276289436666==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Cleanup: drop the unneeded priv_key initialization and don't wait for
the next l_key_get_info() to fail when a private key was set but can't
be loaded.
---
 ell/tls.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 75e3739..aa6e487 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2218,19 +2218,19 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *t=
ls, const char *cert_path,
 	}
 =

 	if (priv_key_path) {
-		uint8_t *priv_key =3D NULL;
+		uint8_t *priv_key;
 		bool is_public =3D true;
 =

 		priv_key =3D l_pem_load_private_key(priv_key_path,
 							priv_key_passphrase,
 							&tls->priv_key_size);
+		if (!priv_key)
+			return false;
 =

 		tls->priv_key =3D l_key_new(L_KEY_RSA, priv_key,
 						tls->priv_key_size);
-		if (priv_key) {
-			memset(priv_key, 0, tls->priv_key_size);
-			l_free(priv_key);
-		}
+		memset(priv_key, 0, tls->priv_key_size);
+		l_free(priv_key);
 =

 		if (!l_key_get_info(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, &tls->priv_key_size,
-- =

2.11.0


--===============6232458276289436666==--

