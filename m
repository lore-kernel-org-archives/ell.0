Content-Type: multipart/mixed; boundary="===============8885070570119210646=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/4] key: Don't generate description string from pointer
Date: Fri, 08 Feb 2019 16:31:47 +0100
Message-ID: <20190208153147.30969-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190208153147.30969-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8885070570119210646==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Within a keyring each key must have a unique key type + description
string combination.  If a key is linked to a keyring with the same
description and key type as another key in the keyring, the other key is
unlinked (this is documented).  Since we allow our references to the
kernel keys to be freed without revoking them, through
l_key_free_norevoke, and we depend on them staying usable in the
keyrings we can't generate the key descriptions from just the pointer
because after a key is freed in the userspace another key may get the
same pointer and the same description string.  In fact if we're adding
keys to a keyring in a loop and freeing our references to them
immediately each key will get the same description and we end up
removing the previous key in each iteration.  Fix this by using a
global (to the process) sequential ids for the keys and keyrings.
---
 ell/key.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 304344f..ce4fbad 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -286,6 +286,7 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_type type=
, const void *payload,
 {
 	struct l_key *key;
 	char *description;
+	static unsigned long key_idx;
 =

 	if (unlikely(!payload))
 		return NULL;
@@ -298,7 +299,7 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_type type=
, const void *payload,
 =

 	key =3D l_new(struct l_key, 1);
 	key->type =3D type;
-	description =3D l_strdup_printf("ell-key-%p", key);
+	description =3D l_strdup_printf("ell-key-%lu", key_idx++);
 	key->serial =3D kernel_add_key(key_type_names[type], description, payload,
 					payload_length, internal_keyring);
 	l_free(description);
@@ -657,12 +658,13 @@ LIB_EXPORT struct l_keyring *l_keyring_new(void)
 {
 	struct l_keyring *keyring;
 	char *description;
+	static unsigned long keyring_idx;
 =

 	if (!internal_keyring && !setup_internal_keyring())
 		return NULL;
 =

 	keyring =3D l_new(struct l_keyring, 1);
-	description =3D l_strdup_printf("ell-keyring-%p", keyring);
+	description =3D l_strdup_printf("ell-keyring-%lu", keyring_idx++);
 	keyring->serial =3D kernel_add_key("keyring", description, NULL, 0,
 						internal_keyring);
 	l_free(description);
-- =

2.19.1


--===============8885070570119210646==--

