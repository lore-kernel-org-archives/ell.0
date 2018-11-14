Content-Type: multipart/mixed; boundary="===============8387696468106139555=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 02/12] cipher: Add gcm(aes) AEAD cipher
Date: Wed, 14 Nov 2018 14:18:52 +0100
Message-ID: <20181114131902.1695-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181114131902.1695-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8387696468106139555==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cipher.c | 10 +++++++---
 ell/cipher.h |  1 +
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index af4bc10..0f5804a 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -202,6 +202,8 @@ static const char *aead_cipher_type_to_name(enum l_aead=
_cipher_type type)
 	switch (type) {
 	case L_AEAD_CIPHER_AES_CCM:
 		return "ccm(aes)";
+	case L_AEAD_CIPHER_AES_GCM:
+		return "gcm(aes)";
 	}
 =

 	return NULL;
@@ -218,7 +220,7 @@ LIB_EXPORT struct l_aead_cipher *l_aead_cipher_new(enum=
 l_aead_cipher_type type,
 	if (unlikely(!key))
 		return NULL;
 =

-	if (type !=3D L_AEAD_CIPHER_AES_CCM)
+	if (type !=3D L_AEAD_CIPHER_AES_CCM && type !=3D L_AEAD_CIPHER_AES_GCM)
 		return NULL;
 =

 	cipher =3D l_new(struct l_aead_cipher, 1);
@@ -510,6 +512,8 @@ static size_t l_aead_cipher_get_ivlen(struct l_aead_cip=
her *cipher)
 	switch (cipher->type) {
 	case L_AEAD_CIPHER_AES_CCM:
 		return 16;
+	case L_AEAD_CIPHER_AES_GCM:
+		return 12;
 	}
 =

 	return 0;
@@ -633,7 +637,7 @@ static void init_supported()
 =

 	strcpy((char *) salg.salg_type, "aead");
 =

-	for (a =3D L_AEAD_CIPHER_AES_CCM; a <=3D L_AEAD_CIPHER_AES_CCM; a++) {
+	for (a =3D L_AEAD_CIPHER_AES_CCM; a <=3D L_AEAD_CIPHER_AES_GCM; a++) {
 		strcpy((char *) salg.salg_name, aead_cipher_type_to_name@);
 =

 		if (bind(sk, (struct sockaddr *) &salg, sizeof(salg)) < 0)
@@ -657,7 +661,7 @@ LIB_EXPORT bool l_cipher_is_supported(enum l_cipher_typ=
e type)
 =

 LIB_EXPORT bool l_aead_cipher_is_supported(enum l_aead_cipher_type type)
 {
-	if (type !=3D L_AEAD_CIPHER_AES_CCM)
+	if (type !=3D L_AEAD_CIPHER_AES_CCM && type !=3D L_AEAD_CIPHER_AES_GCM)
 		return false;
 =

 	init_supported();
diff --git a/ell/cipher.h b/ell/cipher.h
index d787f33..946b9ad 100644
--- a/ell/cipher.h
+++ b/ell/cipher.h
@@ -62,6 +62,7 @@ struct l_aead_cipher;
 =

 enum l_aead_cipher_type {
 	L_AEAD_CIPHER_AES_CCM =3D 0,
+	L_AEAD_CIPHER_AES_GCM,
 };
 =

 struct l_aead_cipher *l_aead_cipher_new(enum l_aead_cipher_type type,
-- =

2.19.1


--===============8387696468106139555==--

