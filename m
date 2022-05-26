Content-Type: multipart/mixed; boundary="===============3971883970007066102=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 3/3] tls: Fix state check on Client Hello
Date: Thu, 26 May 2022 17:56:57 +0200
Message-ID: <20220526155657.63641-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220526155657.63641-1-andrew.zaborowski@intel.com

--===============3971883970007066102==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

A Client Hello message is allowed in the WAIT_HELLO and DONE states,
apparently this check had a typo.
---
 ell/tls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index fa00075..b2f7411 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2740,7 +2740,7 @@ bool tls_handle_message(struct l_tls *tls, const uint=
8_t *message,
 		/* Start hashing the handshake contents on first message */
 		if (tls->server && message[0] =3D=3D TLS_CLIENT_HELLO &&
 				(tls->state =3D=3D TLS_HANDSHAKE_WAIT_HELLO ||
-				 tls->state !=3D TLS_HANDSHAKE_DONE))
+				 tls->state =3D=3D TLS_HANDSHAKE_DONE))
 			if (!tls_init_handshake_hash(tls))
 				return false;
 =

-- =

2.32.0

--===============3971883970007066102==--

