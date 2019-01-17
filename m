Content-Type: multipart/mixed; boundary="===============0705998309548468449=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/4] key: Unlink keys when revoking
Date: Thu, 17 Jan 2019 18:19:13 +0100
Message-ID: <20190117171916.27960-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0705998309548468449==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

As an optimization unlink the key in l_key_free and l_keyring_free same
as we do in l_key(ring)_free_norevoke, in addition to the actual
revocation.  This happens to release the quota spot used by the key much
faster under some circumstances.
---
 ell/key.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/ell/key.c b/ell/key.c
index 06c7a98..587ee05 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -313,6 +313,20 @@ LIB_EXPORT void l_key_free(struct l_key *key)
 	if (unlikely(!key))
 		return;
 =

+	/*
+	 * Unlinking the key from internal_keyring, while not necessary,
+	 * causes the kernel's key garbage collector to run much sooner
+	 * than if the key is only revoked, at least under some kernel
+	 * versions and when the key is not linked to any other ring.
+	 * In practice this helps the user processes stay under the
+	 * per-user key quota (kernel.keys.maxkeys) which is difficult
+	 * to control when there's no way to reclaim the spot occupied
+	 * by the freed key until the GC runs and not even a way to
+	 * wait for the GC.  That means that running many key
+	 * operations too fast may cause add_key to start failing
+	 * independent of how high the quota has been set.
+	 */
+	kernel_unlink_key(key->serial, internal_keyring);
 	kernel_revoke_key(key->serial);
 =

 	l_free(key);
@@ -700,6 +714,7 @@ LIB_EXPORT void l_keyring_free(struct l_keyring *keyrin=
g)
 	if (unlikely(!keyring))
 		return;
 =

+	kernel_unlink_key(keyring->serial, internal_keyring);
 	kernel_revoke_key(keyring->serial);
 =

 	l_free(keyring);
-- =

2.19.1


--===============0705998309548468449==--

