Content-Type: multipart/mixed; boundary="===============1729670789372762713=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 5/7] key: Rename asymmetric key type to L_KEY_RSA
Date: Fri, 29 Jul 2016 11:11:59 -0700
Message-ID: <20160729181201.16446-5-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160729181201.16446-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1729670789372762713==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The kernel automatically determines the correct crypto algorithm using
an OID present in each X.509 key, but it's still important to know which
algorithm it is in userspace so the requested cipher can be matched
up.

RSA is the only asymmetric algorithm supported using the keyctl API as
of v4.8. The crypto algorithm for a key can be parsed out of /proc/keys,
but it may soon be accessible through the keyctl API.
---
 ell/key.c | 9 ++++++++-
 ell/key.h | 2 +-
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 8e7b398..7dad4a7 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -59,7 +59,7 @@ struct l_keyring {
 =

 static const char * const key_type_names[] =3D {
 	[L_KEY_RAW] =3D "user",
-	[L_KEY_ASYMMETRIC] =3D "asymmetric",
+	[L_KEY_RSA] =3D "asymmetric",
 };
 =

 static long kernel_add_key(const char *type, const char *description,
@@ -173,6 +173,13 @@ LIB_EXPORT struct l_key *l_key_new(enum l_key_type typ=
e, const void *payload,
 		key =3D NULL;
 	}
 =

+	/*
+	 * TODO: Query asymmetric key algorithm from the kernel and
+	 * ensure that it matches the expected l_key_type. This can
+	 * currently be found by digging through /proc/keys, but a
+	 * keyctl() op makes more sense.
+	 */
+
 	return key;
 }
 =

diff --git a/ell/key.h b/ell/key.h
index 4ec32a6..a0b4b64 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -35,7 +35,7 @@ struct l_keyring;
 =

 enum l_key_type {
 	L_KEY_RAW =3D 0,
-	L_KEY_ASYMMETRIC
+	L_KEY_RSA,
 };
 =

 enum l_keyring_type {
-- =

2.9.2


--===============1729670789372762713==--

