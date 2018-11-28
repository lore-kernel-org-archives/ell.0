Content-Type: multipart/mixed; boundary="===============8618304129733964945=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/9] tls: Fix length in TLS 1.0 signature verification
Date: Wed, 28 Nov 2018 03:38:28 +0100
Message-ID: <20181128023835.2081-2-andrew.zaborowski@intel.com>
In-Reply-To: <20181128023835.2081-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8618304129733964945==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Account for the shorter Certificate Verify message in TLS 1.0/1.1 when
parsing the message to verify the signature.  This fixes server side TLS
1.0/1.1 support which apparently has been broken since the migration to
l_key.
---
 ell/tls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index 9969fcc..fd89206 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1319,7 +1319,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const u=
int8_t *in, size_t len,
 	}
 =

 	success =3D l_key_verify(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
-				hash_type, expected, in + 4,
+				hash_type, expected, in + offset + 2,
 				expected_len, tls->peer_pubkey_size);
 =

 	if (!success)
-- =

2.19.1


--===============8618304129733964945==--

