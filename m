Content-Type: multipart/mixed; boundary="===============3290743476152329149=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 2/3] key: Make key/keychain revocation optional when freeing
Date: Mon, 24 Oct 2016 14:36:32 -0700
Message-ID: <20161024213633.10668-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161024213633.10668-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3290743476152329149==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Revoking keys (or keyrings) unlinks them from every keyring. Sometimes
it is useful to let the kernel keep a key even if ELL isn't directly
tracking that key anymore - for example, a keyring of trusted keys can
be used for validation without keeping l_key objects around for every
single key in that keyring. The kernel will clean up the kernel key
objects when there are no more references to them whether or not we
explicitly revoke from userspace.

l_key_free_norevoke and l_keyring_free_norevoke are added to support the
non-revoking behavior, while the default is still to revoke the key.
---
 ell/key.c | 20 ++++++++++++++++++++
 ell/key.h |  2 ++
 2 files changed, 22 insertions(+)

diff --git a/ell/key.c b/ell/key.c
index 4cf2307..370b3c8 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -286,6 +286,16 @@ LIB_EXPORT void l_key_free(struct l_key *key)
 	l_free(key);
 }
 =

+LIB_EXPORT void l_key_free_norevoke(struct l_key *key)
+{
+	if (unlikely(!key))
+		return;
+
+	kernel_unlink_key(key->serial, internal_keyring);
+
+	l_free(key);
+}
+
 LIB_EXPORT bool l_key_update(struct l_key *key, const void *payload, size_=
t len)
 {
 	long error;
@@ -703,6 +713,16 @@ LIB_EXPORT void l_keyring_free(struct l_keyring *keyri=
ng)
 	l_free(keyring);
 }
 =

+LIB_EXPORT void l_keyring_free_norevoke(struct l_keyring *keyring)
+{
+	if (unlikely(!keyring))
+		return;
+
+	kernel_unlink_key(keyring->serial, internal_keyring);
+
+	l_free(keyring);
+}
+
 bool l_keyring_link(struct l_keyring *keyring, const struct l_key *key)
 {
 	long error;
diff --git a/ell/key.h b/ell/key.h
index e7036c6..35c63eb 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -55,6 +55,7 @@ struct l_key *l_key_new(enum l_key_type type, const void =
*payload,
 			size_t payload_length);
 =

 void l_key_free(struct l_key *key);
+void l_key_free_norevoke(struct l_key *key);
 =

 bool l_key_update(struct l_key *key, const void *payload, size_t len);
 =

@@ -92,6 +93,7 @@ struct l_keyring *l_keyring_new(enum l_keyring_type type,
 				const struct l_keyring *trust);
 =

 void l_keyring_free(struct l_keyring *keyring);
+void l_keyring_free_norevoke(struct l_keyring *keyring);
 =

 bool l_keyring_link(struct l_keyring *keyring, const struct l_key *key);
 =

-- =

2.10.1


--===============3290743476152329149==--

