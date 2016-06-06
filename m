Content-Type: multipart/mixed; boundary="===============0063854110848433449=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 06/11] key: Add keyring APIs
Date: Mon, 06 Jun 2016 13:54:45 -0700
Message-ID: <20160606205450.23615-6-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160606205450.23615-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0063854110848433449==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

There are two types of keyrings: "simple" and "trusted asymmetric".

Simple keyrings do not validate keys as they are linked. Trusted
asymmetric keyrings have a "trust keyring" designated at allocation
time. Only RSA keys that are signed by an RSA key in the trust keyring
may be linked to a trusted asymmetric keyring.
---
 ell/key.c | 111 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--=
----
 ell/key.h |  15 +++++++++
 2 files changed, 116 insertions(+), 10 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index b0afc2f..adeac04 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -44,13 +44,18 @@ struct keyctl_dh_params {
 };
 #endif
 =

-static int32_t keyring_base;
+static int32_t internal_keyring;
 =

 struct l_key {
 	int type;
 	int32_t serial;
 };
 =

+struct l_keyring {
+	int type;
+	int32_t serial;
+};
+
 static const char * const key_type_names[] =3D {
 	[L_KEY_RAW] =3D "user",
 	[L_KEY_ASYMMETRIC] =3D "asymmetric",
@@ -77,6 +82,16 @@ static long kernel_revoke_key(int32_t serial)
 	return syscall(__NR_keyctl, KEYCTL_REVOKE, serial);
 }
 =

+static long kernel_link_key(int32_t key_serial, int32_t ring_serial)
+{
+	return syscall(__NR_keyctl, KEYCTL_LINK, key_serial, ring_serial);
+}
+
+static long kernel_unlink_key(int32_t key_serial, int32_t ring_serial)
+{
+	return syscall(__NR_keyctl, KEYCTL_UNLINK, key_serial, ring_serial);
+}
+
 static long kernel_dh_compute(int32_t private, int32_t prime, int32_t base,
 			      void *payload, size_t len)
 {
@@ -87,13 +102,13 @@ static long kernel_dh_compute(int32_t private, int32_t=
 prime, int32_t base,
 	return syscall(__NR_keyctl, KEYCTL_DH_COMPUTE, &params, payload, len);
 }
 =

-static bool setup_keyring_base(void)
+static bool setup_internal_keyring(void)
 {
-	keyring_base =3D kernel_add_key("keyring", "ell-keyring", 0, 0,
-					KEY_SPEC_THREAD_KEYRING);
+	internal_keyring =3D kernel_add_key("keyring", "ell-internal", NULL, 0,
+						KEY_SPEC_THREAD_KEYRING);
 =

-	if (keyring_base <=3D 0) {
-		keyring_base =3D 0;
+	if (internal_keyring <=3D 0) {
+		internal_keyring =3D 0;
 		return false;
 	}
 =

@@ -112,15 +127,14 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_type ty=
pe, const void *payload,
 	if (unlikely((size_t)type >=3D L_ARRAY_SIZE(key_type_names)))
 		return NULL;
 =

-	if (!keyring_base && !setup_keyring_base()) {
+	if (!internal_keyring && !setup_internal_keyring())
 		return NULL;
-	}
 =

 	key =3D l_new(struct l_key, 1);
 	key->type =3D type;
-	description =3D l_strdup_printf("ell-%p", key);
+	description =3D l_strdup_printf("ell-key-%p", key);
 	key->serial =3D kernel_add_key(key_type_names[type], description, payload,
-					payload_length, keyring_base);
+					payload_length, internal_keyring);
 	l_free(description);
 =

 	if (key->serial < 0) {
@@ -210,3 +224,80 @@ LIB_EXPORT bool l_key_compute_dh_secret(struct l_key *=
other_public,
 {
 	return compute_common(other_public, private, prime, payload, len);
 }
+
+LIB_EXPORT struct l_keyring *l_keyring_new(enum l_keyring_type type,
+						const struct l_keyring *trusted)
+{
+	struct l_keyring *keyring;
+	char *description;
+	char *payload =3D NULL;
+	size_t payload_length =3D 0;
+
+	if (!internal_keyring && !setup_internal_keyring())
+		return NULL;
+
+	if (type =3D=3D L_KEYRING_TRUSTED_ASYM) {
+		if (!trusted)
+			return NULL;
+
+		payload =3D l_strdup_printf(
+			"restrict_type=3Dasymmetric "
+			"restrict_by=3Dsignature_keyring "
+			"restrict_key=3D%d",
+			trusted->serial);
+		payload_length =3D strlen(payload);
+	} else if (type !=3D L_KEYRING_SIMPLE) {
+		/* Unsupported type */
+		return NULL;
+	}
+
+	keyring =3D l_new(struct l_keyring, 1);
+	keyring->type =3D type;
+	description =3D l_strdup_printf("ell-keyring-%p", keyring);
+	keyring->serial =3D kernel_add_key("keyring", description, payload,
+						payload_length,
+						internal_keyring);
+	l_free(description);
+	l_free(payload);
+
+	if (keyring->serial < 0) {
+		l_free(keyring);
+		keyring =3D NULL;
+	}
+
+	return keyring;
+}
+
+LIB_EXPORT void l_keyring_free(struct l_keyring *keyring)
+{
+	if (unlikely(!keyring))
+		return;
+
+	kernel_revoke_key(keyring->serial);
+
+	l_free(keyring);
+}
+
+bool l_keyring_link(struct l_keyring *keyring, const struct l_key *key)
+{
+	long error;
+
+	if (unlikely(!keyring) || unlikely(!key))
+		return false;
+
+	error =3D kernel_link_key(key->serial, keyring->serial);
+
+	return error =3D=3D 0;
+}
+
+bool l_keyring_unlink(struct l_keyring *keyring, const struct l_key *key)
+{
+	long error;
+
+	if (unlikely(!keyring) || unlikely(!key))
+		return false;
+
+	error =3D kernel_unlink_key(key->serial, keyring->serial);
+
+	return error =3D=3D 0;
+}
diff --git a/ell/key.h b/ell/key.h
index 7d48c4d..5d981f1 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -31,12 +31,18 @@ extern "C" {
 #include <stdbool.h>
 =

 struct l_key;
+struct l_keyring;
 =

 enum l_key_type {
 	L_KEY_RAW =3D 0,
 	L_KEY_ASYMMETRIC
 };
 =

+enum l_keyring_type {
+	L_KEYRING_SIMPLE =3D 0,
+	L_KEYRING_TRUSTED_ASYM
+};
+
 struct l_key *l_key_new(enum l_key_type type, const void *payload,
 			size_t payload_length);
 =

@@ -54,6 +60,15 @@ bool l_key_compute_dh_public(struct l_key *generator, st=
ruct l_key *private,
 bool l_key_compute_dh_secret(struct l_key *other_public, struct l_key *pri=
vate,
 			     struct l_key *prime, void *payload, size_t *len);
 =

+struct l_keyring *l_keyring_new(enum l_keyring_type type,
+				const struct l_keyring *trust);
+
+void l_keyring_free(struct l_keyring *keyring);
+
+bool l_keyring_link(struct l_keyring *keyring, const struct l_key *key);
+
+bool l_keyring_unlink(struct l_keyring *keyring, const struct l_key *key);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.8.3


--===============0063854110848433449==--

