Content-Type: multipart/mixed; boundary="===============7084963365713988399=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/5] key: Implement l_keyring_link_nested
Date: Fri, 23 Nov 2018 10:44:25 +0100
Message-ID: <20181123094429.7190-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7084963365713988399==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow linking and unlinking keyrings to/from other keyrings with
l_keyring_link_nested (naming proposed by Mat) and
l_keyring_unlink_nested.
---
 ell/ell.sym |  2 ++
 ell/key.c   | 26 ++++++++++++++++++++++++++
 ell/key.h   |  5 +++++
 3 files changed, 33 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index c2aafee..abd139f 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -310,6 +310,8 @@ global:
 	l_keyring_free_norevoke;
 	l_keyring_link;
 	l_keyring_unlink;
+	l_keyring_link_nested;
+	l_keyring_unlink_nested;
 	l_key_is_supported;
 	/* log */
 	l_log_set_ident;
diff --git a/ell/key.c b/ell/key.c
index 4bba559..7487d6f 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -640,6 +640,32 @@ LIB_EXPORT bool l_keyring_unlink(struct l_keyring *key=
ring,
 	return error =3D=3D 0;
 }
 =

+bool l_keyring_link_nested(struct l_keyring *keyring,
+				const struct l_keyring *nested)
+{
+	long error;
+
+	if (unlikely(!keyring) || unlikely(!nested))
+		return false;
+
+	error =3D kernel_link_key(nested->serial, keyring->serial);
+
+	return error =3D=3D 0;
+}
+
+bool l_keyring_unlink_nested(struct l_keyring *keyring,
+				const struct l_keyring *nested)
+{
+	long error;
+
+	if (unlikely(!keyring) || unlikely(!nested))
+		return false;
+
+	error =3D kernel_unlink_key(nested->serial, keyring->serial);
+
+	return error =3D=3D 0;
+}
+
 LIB_EXPORT bool l_key_is_supported(uint32_t features)
 {
 	long result;
diff --git a/ell/key.h b/ell/key.h
index 263e12a..1529135 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -108,6 +108,11 @@ bool l_keyring_link(struct l_keyring *keyring, const s=
truct l_key *key);
 =

 bool l_keyring_unlink(struct l_keyring *keyring, const struct l_key *key);
 =

+bool l_keyring_link_nested(struct l_keyring *keyring,
+				const struct l_keyring *nested);
+bool l_keyring_unlink_nested(struct l_keyring *keyring,
+				const struct l_keyring *nested);
+
 bool l_key_is_supported(uint32_t features);
 =

 #ifdef __cplusplus
-- =

2.19.1


--===============7084963365713988399==--

