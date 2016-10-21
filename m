Content-Type: multipart/mixed; boundary="===============2451728139622763409=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/4] key: Add cert chain validation capability to keyring
Date: Fri, 21 Oct 2016 13:52:23 -0700
Message-ID: <20161021205226.419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2451728139622763409==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Verifying certificate chains was a little awkward using the
L_KEYRING_TRUSTED_ASYM keyring type, which required verifying the
signature and then separately adding the verified certificate to the
"trusted" keyring.

With L_KEYRING_TRUSTED_ASYM_CHAIN, the destination keyring is also
searched for signing keys.

One use model is to have two keyrings:

 1. trust_keyring: contains long-lived root and intermediate CA certs.
 2. verify_keyring: an L_KEYRING_TRUSTED_ASYM_CHAIN keyring that
                    is created with "trust_keyring" referenced for
		    trusted certificates.

In order to validate new certificates, they are added to verify_keyring
in series, starting with certs that are signed by those in
trust_keyring. Once an intermediate CA cert is added to verify_keyring,
certs signed by that intermediate CA can also be added to verify_keyring.
---
 ell/key.c | 22 ++++++++++++++++------
 ell/key.h |  3 ++-
 2 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index fc20d29..4cf2307 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -653,15 +653,25 @@ LIB_EXPORT struct l_keyring *l_keyring_new(enum l_key=
ring_type type,
 	if (!internal_keyring && !setup_internal_keyring())
 		return NULL;
 =

-	if (type =3D=3D L_KEYRING_TRUSTED_ASYM) {
-		if (!trusted)
-			return NULL;
+	switch (type) {
+	case L_KEYRING_SIMPLE:
+		break;
+	case L_KEYRING_TRUSTED_ASYM:
+	case L_KEYRING_TRUSTED_ASYM_CHAIN:
+	{
+		char *option =3D "";
+
+		if (type =3D=3D L_KEYRING_TRUSTED_ASYM_CHAIN)
+			option =3D ":chain";
 =

 		payload =3D l_strdup_printf(
-			"restrict=3Dasymmetric:key_or_keyring:%d",
-			trusted->serial);
+			"restrict=3Dasymmetric:key_or_keyring:%d%s",
+			trusted ? trusted->serial : 0, option);
 		payload_length =3D strlen(payload);
-	} else if (type !=3D L_KEYRING_SIMPLE) {
+
+		break;
+	}
+	default:
 		/* Unsupported type */
 		return NULL;
 	}
diff --git a/ell/key.h b/ell/key.h
index ff4b543..e7036c6 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -42,7 +42,8 @@ enum l_key_type {
 =

 enum l_keyring_type {
 	L_KEYRING_SIMPLE =3D 0,
-	L_KEYRING_TRUSTED_ASYM
+	L_KEYRING_TRUSTED_ASYM,
+	L_KEYRING_TRUSTED_ASYM_CHAIN,
 };
 =

 enum l_key_cipher_type {
-- =

2.10.1


--===============2451728139622763409==--

