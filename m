Content-Type: multipart/mixed; boundary="===============2736795672751228135=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/5] key: Make key/keychain revocation optional when freeing
Date: Mon, 24 Oct 2016 11:44:53 -0700
Message-ID: <20161024184456.25743-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161024184456.25743-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2736795672751228135==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Revoking keys (or keyrings) unlinks them any keyring. Sometimes it is
useful to let the kernel keep a key linked even if ELL isn't directly
keeping track of that key anymore - for example, a keyring of trusted
keys can be used for validation without keeping l_key objects around for
every single key in that keyring. The kernel will clean up the kernel
key objects when there are no more references to them whether or not we
explicitly revoke from userspace.
---
 ell/key.c | 14 ++++++++++----
 ell/key.h |  4 ++--
 ell/tls.c |  6 +++---
 3 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 4cf2307..4225271 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -276,12 +276,15 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_type ty=
pe, const void *payload,
 	return key;
 }
 =

-LIB_EXPORT void l_key_free(struct l_key *key)
+LIB_EXPORT void l_key_free(struct l_key *key, bool revoke)
 {
 	if (unlikely(!key))
 		return;
 =

-	kernel_revoke_key(key->serial);
+	if (revoke)
+		kernel_revoke_key(key->serial);
+	else
+		kernel_unlink_key(key->serial, internal_keyring);
 =

 	l_free(key);
 }
@@ -693,12 +696,15 @@ LIB_EXPORT struct l_keyring *l_keyring_new(enum l_key=
ring_type type,
 	return keyring;
 }
 =

-LIB_EXPORT void l_keyring_free(struct l_keyring *keyring)
+LIB_EXPORT void l_keyring_free(struct l_keyring *keyring, bool revoke)
 {
 	if (unlikely(!keyring))
 		return;
 =

-	kernel_revoke_key(keyring->serial);
+	if (revoke)
+		kernel_revoke_key(keyring->serial);
+	else
+		kernel_unlink_key(keyring->serial, internal_keyring);
 =

 	l_free(keyring);
 }
diff --git a/ell/key.h b/ell/key.h
index e7036c6..0c84000 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -54,7 +54,7 @@ enum l_key_cipher_type {
 struct l_key *l_key_new(enum l_key_type type, const void *payload,
 			size_t payload_length);
 =

-void l_key_free(struct l_key *key);
+void l_key_free(struct l_key *key, bool revoke);
 =

 bool l_key_update(struct l_key *key, const void *payload, size_t len);
 =

@@ -91,7 +91,7 @@ bool l_key_verify(struct l_key *key, enum l_key_cipher_ty=
pe cipher,
 struct l_keyring *l_keyring_new(enum l_keyring_type type,
 				const struct l_keyring *trust);
 =

-void l_keyring_free(struct l_keyring *keyring);
+void l_keyring_free(struct l_keyring *keyring, bool revoke);
 =

 bool l_keyring_link(struct l_keyring *keyring, const struct l_key *key);
 =

diff --git a/ell/tls.c b/ell/tls.c
index bc4c210..a89b2db 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -135,7 +135,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 	memset(tls->pending.key_block, 0, sizeof(tls->pending.key_block));
 =

 	l_free(tls->peer_cert);
-	l_key_free(tls->peer_pubkey);
+	l_key_free(tls->peer_pubkey, true);
 =

 	tls->peer_cert =3D NULL;
 	tls->peer_pubkey =3D NULL;
@@ -2211,7 +2211,7 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls=
, const char *cert_path,
 	}
 =

 	if (tls->priv_key) {
-		l_key_free(tls->priv_key);
+		l_key_free(tls->priv_key, true);
 		tls->priv_key =3D NULL;
 		tls->priv_key_size =3D 0;
 	}
@@ -2234,7 +2234,7 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *tls=
, const char *cert_path,
 		if (!l_key_get_info(tls->priv_key, L_KEY_RSA_PKCS1_V1_5,
 					L_CHECKSUM_NONE, &tls->priv_key_size,
 					&is_public) || is_public) {
-			l_key_free(tls->priv_key);
+			l_key_free(tls->priv_key, true);
 			tls->priv_key =3D NULL;
 			tls->priv_key_size =3D 0;
 			return false;
-- =

2.10.1


--===============2736795672751228135==--

