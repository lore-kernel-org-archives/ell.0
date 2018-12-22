Content-Type: multipart/mixed; boundary="===============5742926159609274277=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 01/11] tls: Only accept the Certificate Request in client mode
Date: Sat, 22 Dec 2018 05:16:25 +0100
Message-ID: <20181222041635.6533-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5742926159609274277==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/tls.c b/ell/tls.c
index eab9cc2..f4cd94c 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2312,6 +2312,12 @@ static void tls_handle_handshake(struct l_tls *tls, =
int type,
 		break;
 =

 	case TLS_CERTIFICATE_REQUEST:
+		if (tls->server) {
+			TLS_DISCONNECT(TLS_ALERT_UNEXPECTED_MESSAGE, 0,
+					"Message invalid in server mode");
+			break;
+		}
+
 		/*
 		 * Server sends this optionally so in the WAIT_HELLO_DONE
 		 * state we accept either this or a Server Hello Done (below).
-- =

2.19.1


--===============5742926159609274277==--

