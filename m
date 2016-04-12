Content-Type: multipart/mixed; boundary="===============1793668669413354024=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 2/3] key: Add Diffie-Hellman support using keyctl
Date: Tue, 12 Apr 2016 09:42:43 -0700
Message-ID: <1460479364-14478-2-git-send-email-mathew.j.martineau@linux.intel.com>
In-Reply-To: <1460479364-14478-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1793668669413354024==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/key.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/key.h |  6 ++++++
 2 files changed, 61 insertions(+)

diff --git a/ell/key.c b/ell/key.c
index f9f8b7e..b0afc2f 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -34,6 +34,16 @@
 #include "util.h"
 #include "key.h"
 =

+#ifndef KEYCTL_DH_COMPUTE
+#define KEYCTL_DH_COMPUTE 23
+
+struct keyctl_dh_params {
+	int32_t private;
+	int32_t prime;
+	int32_t base;
+};
+#endif
+
 static int32_t keyring_base;
 =

 struct l_key {
@@ -67,6 +77,16 @@ static long kernel_revoke_key(int32_t serial)
 	return syscall(__NR_keyctl, KEYCTL_REVOKE, serial);
 }
 =

+static long kernel_dh_compute(int32_t private, int32_t prime, int32_t base,
+			      void *payload, size_t len)
+{
+	struct keyctl_dh_params params =3D { .private =3D private,
+					   .prime =3D prime,
+					   .base =3D base };
+
+	return syscall(__NR_keyctl, KEYCTL_DH_COMPUTE, &params, payload, len);
+}
+
 static bool setup_keyring_base(void)
 {
 	keyring_base =3D kernel_add_key("keyring", "ell-keyring", 0, 0,
@@ -155,3 +175,38 @@ LIB_EXPORT ssize_t l_key_get_size(struct l_key *key)
 {
 	return kernel_read_key(key->serial, NULL, 0);
 }
+
+static bool compute_common(struct l_key *base,
+			   struct l_key *private,
+			   struct l_key *prime,
+			   void *payload, size_t *len)
+{
+	long result_len;
+	bool usable_payload =3D *len !=3D 0;
+
+	result_len =3D kernel_dh_compute(private->serial, prime->serial,
+				       base->serial, payload, *len);
+
+	if (result_len > 0) {
+		*len =3D result_len;
+		return usable_payload;
+	} else {
+		return false;
+	}
+}
+
+LIB_EXPORT bool l_key_compute_dh_public(struct l_key *generator,
+					struct l_key *private,
+					struct l_key *prime,
+					void *payload, size_t *len)
+{
+	return compute_common(generator, private, prime, payload, len);
+}
+
+LIB_EXPORT bool l_key_compute_dh_secret(struct l_key *other_public,
+					struct l_key *private,
+					struct l_key *prime,
+					void *payload, size_t *len)
+{
+	return compute_common(other_public, private, prime, payload, len);
+}
diff --git a/ell/key.h b/ell/key.h
index 73c2c97..7d48c4d 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -48,6 +48,12 @@ bool l_key_extract(struct l_key *key, void *payload, siz=
e_t *len);
 =

 ssize_t l_key_get_size(struct l_key *key);
 =

+bool l_key_compute_dh_public(struct l_key *generator, struct l_key *privat=
e,
+			     struct l_key *prime, void *payload, size_t *len);
+
+bool l_key_compute_dh_secret(struct l_key *other_public, struct l_key *pri=
vate,
+			     struct l_key *prime, void *payload, size_t *len);
+
 #ifdef __cplusplus
 }
 #endif
-- =

2.8.1


--===============1793668669413354024==--

