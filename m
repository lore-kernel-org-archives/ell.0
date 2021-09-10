Content-Type: multipart/mixed; boundary="===============2358295181929959459=="
MIME-Version: 1.0
From: Inga Stotland <inga.stotland@intel.com>
Subject: [PATCH] cipher: Allow zero byte input for AEAD cipher
Date: Fri, 10 Sep 2021 15:24:32 -0700
Message-ID: <20210910222432.26046-1-inga.stotland@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2358295181929959459==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

For AEAD-based cipher, either the plaintext or the associated
data may contain zero bytes.

Add extra checks to disallow combinations of NULL input data and
nonzero data length.
---
 ell/cipher.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index 866fdb5..6b8528c 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -607,7 +607,10 @@ LIB_EXPORT bool l_aead_cipher_encrypt(struct l_aead_ci=
pher *cipher,
 	if (unlikely(!cipher))
 		return false;
 =

-	if (unlikely(!in) || unlikely(!out))
+	if (unlikely(!in && !ad) || unlikely(!out))
+		return false;
+
+	if (unlikely(!in && in_len) || unlikely(!ad && ad_len))
 		return false;
 =

 	if (cipher->type =3D=3D L_AEAD_CIPHER_AES_CCM) {
-- =

2.31.1

--===============2358295181929959459==--

