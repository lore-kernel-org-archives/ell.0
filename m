Content-Type: multipart/mixed; boundary="===============3488186212990361693=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/4] tls: Disconnect if ls_get_peer_identity_str fails
Date: Sat, 17 Aug 2019 02:28:32 +0200
Message-ID: <20190817002834.15208-2-andrew.zaborowski@intel.com>
In-Reply-To: <20190817002834.15208-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3488186212990361693==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make sure the ell client's ready callback can safely assume that
whenever a CA certificate was set, the peer_identity string is
non-NULL if that callback is reached.
---
 ell/tls.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 37f5b3f..b1fec9f 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2107,8 +2107,11 @@ static void tls_finished(struct l_tls *tls)
 =

 	if (tls->peer_authenticated) {
 		peer_identity =3D tls_get_peer_identity_str(tls->peer_cert);
-		if (!peer_identity)
-			TLS_DEBUG("tls_get_peer_identity_str failed");
+		if (!peer_identity) {
+			TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+					"tls_get_peer_identity_str failed");
+			return;
+		}
 	}
 =

 	/* Free up the resources used in the handshake */
-- =

2.20.1


--===============3488186212990361693==--

