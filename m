Content-Type: multipart/mixed; boundary="===============8833252518554955050=="
MIME-Version: 1.0
From: Sergei Trofimovich <slyich@gmail.com>
Subject: [PATCH 1/2] unit/test-cipher: always report local ciphers as supported
Date: Mon, 30 Aug 2021 15:08:45 +0100
Message-ID: <20210830140846.4096201-1-slyich@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8833252518554955050==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Fixes test failure on system with CONFIG_CRYPTO_USER_API=3Dn kernel:

    FAIL: unit/test-cipher
    =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

    test-cipher: unit/test-cipher.c:124:
      test_arc4: Assertion `l_cipher_is_supported(L_CIPHER_ARC4)' failed.
    FAIL unit/test-cipher (exit status: 134)

Lack of AF_ALG family is the result of CONFIG_CRYPTO_USER_API=3Dn.

The change moved supported ciphed detection before AF_ALG socket
creation attempt.

Signed-off-by: Sergei Trofimovich <slyich@gmail.com>
---
 ell/cipher.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/ell/cipher.c b/ell/cipher.c
index 0d10394..866fdb5 100644
--- a/ell/cipher.c
+++ b/ell/cipher.c
@@ -677,6 +677,10 @@ static void init_supported()
 =

 	initialized =3D true;
 =

+	for (c =3D 0; c < L_ARRAY_SIZE(local_impl_ciphers); c++)
+		if (HAVE_LOCAL_IMPLEMENTATION(c))
+			supported_ciphers |=3D 1 << c;
+
 	sk =3D socket(PF_ALG, SOCK_SEQPACKET | SOCK_CLOEXEC, 0);
 	if (sk < 0)
 		return;
@@ -698,10 +702,6 @@ static void init_supported()
 		supported_ciphers |=3D 1 << c;
 	}
 =

-	for (c =3D 0; c < L_ARRAY_SIZE(local_impl_ciphers); c++)
-		if (HAVE_LOCAL_IMPLEMENTATION(c))
-			supported_ciphers |=3D 1 << c;
-
 	strcpy((char *) salg.salg_type, "aead");
 =

 	for (a =3D L_AEAD_CIPHER_AES_CCM; a <=3D L_AEAD_CIPHER_AES_GCM; a++) {
-- =

2.33.0

--===============8833252518554955050==--

