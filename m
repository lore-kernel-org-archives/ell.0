Content-Type: multipart/mixed; boundary="===============0983664914889025742=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] key: Use KEYCTL_INVALIDATE in l_key_free
Date: Thu, 31 Jan 2019 18:56:59 +0100
Message-ID: <20190131175659.8150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0983664914889025742==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Replace the use of KEYCTL_REVOKE with KEYCTL_INVALIDE in
l_key(ring)_free.  10ff938dc758e36135c1e07370c2d06cf89d8620 improved the
behaiour of l_key_free with regards to the key quota freeing for cases
when the key was only linked to the internal session keyring.  By using
KEYCTL_INVALIDATE we can achieve the same effect even if the key is
still linked to multiple keyrings and with just one operation instead of
two.  keyctl(2):

KEYCTL_REVOKE (since Linux 2.6.10)
[...]
Revoke  the  key  with  the ID provided in arg2 (cast to key_serial_t).
The key is scheduled for garbage collection;

(In practice this means the key gets freed after 5 minutes)

KEYCTL_INVALIDATE (since Linux 3.5)
[...]
This operation marks the key as invalid and schedules immediate garbage
collection.  The garbage collector removes  the  invalidated  key  from
all keyrings and deletes the key when its reference count reaches zero.
---
 ell/key.c | 24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 6c36655..304344f 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -138,11 +138,11 @@ static long kernel_update_key(int32_t serial, const v=
oid *payload, size_t len)
 	return result >=3D 0 ? result : -errno;
 }
 =

-static long kernel_revoke_key(int32_t serial)
+static long kernel_invalidate_key(int32_t serial)
 {
 	long result;
 =

-	result =3D syscall(__NR_keyctl, KEYCTL_REVOKE, serial);
+	result =3D syscall(__NR_keyctl, KEYCTL_INVALIDATE, serial);
 =

 	return result >=3D 0 ? result : -errno;
 }
@@ -324,20 +324,11 @@ LIB_EXPORT void l_key_free(struct l_key *key)
 		return;
 =

 	/*
-	 * Unlinking the key from internal_keyring, while not necessary,
-	 * causes the kernel's key garbage collector to run much sooner
-	 * than if the key is only revoked, at least under some kernel
-	 * versions and when the key is not linked to any other ring.
-	 * In practice this helps the user processes stay under the
-	 * per-user key quota (kernel.keys.maxkeys) which is difficult
-	 * to control when there's no way to reclaim the spot occupied
-	 * by the freed key until the GC runs and not even a way to
-	 * wait for the GC.  That means that running many key
-	 * operations too fast may cause add_key to start failing
-	 * independent of how high the quota has been set.
+	 * Use invalidate as, unlike revoke, this doesn't delay the
+	 * key garbage collection and causes the quota used by the
+	 * key to be released sooner and more predictably.
 	 */
-	kernel_unlink_key(key->serial, internal_keyring);
-	kernel_revoke_key(key->serial);
+	kernel_invalidate_key(key->serial);
 =

 	l_free(key);
 }
@@ -724,8 +715,7 @@ LIB_EXPORT void l_keyring_free(struct l_keyring *keyrin=
g)
 	if (unlikely(!keyring))
 		return;
 =

-	kernel_unlink_key(keyring->serial, internal_keyring);
-	kernel_revoke_key(keyring->serial);
+	kernel_invalidate_key(keyring->serial);
 =

 	l_free(keyring);
 }
-- =

2.19.1


--===============0983664914889025742==--

