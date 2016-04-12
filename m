Content-Type: multipart/mixed; boundary="===============7644261740707050353=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/3] key: Use unique key descriptors
Date: Tue, 12 Apr 2016 09:42:42 -0700
Message-ID: <1460479364-14478-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7644261740707050353==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The kernel expects the key descriptor text to be unique. If a key is
added with a descriptor that matches an existing key, the existing key
is overwritten.
---
 ell/key.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 6ec8541..f9f8b7e 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -69,7 +69,7 @@ static long kernel_revoke_key(int32_t serial)
 =

 static bool setup_keyring_base(void)
 {
-	keyring_base =3D kernel_add_key("keyring", "ell", 0, 0,
+	keyring_base =3D kernel_add_key("keyring", "ell-keyring", 0, 0,
 					KEY_SPEC_THREAD_KEYRING);
 =

 	if (keyring_base <=3D 0) {
@@ -84,6 +84,7 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_type type, =
const void *payload,
 					size_t payload_length)
 {
 	struct l_key *key;
+	char *description;
 =

 	if (unlikely(!payload))
 		return NULL;
@@ -97,8 +98,10 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_type type,=
 const void *payload,
 =

 	key =3D l_new(struct l_key, 1);
 	key->type =3D type;
-	key->serial =3D kernel_add_key(key_type_names[type], "ell", payload,
+	description =3D l_strdup_printf("ell-%p", key);
+	key->serial =3D kernel_add_key(key_type_names[type], description, payload,
 					payload_length, keyring_base);
+	l_free(description);
 =

 	if (key->serial < 0) {
 		l_free(key);
-- =

2.8.1


--===============7644261740707050353==--

