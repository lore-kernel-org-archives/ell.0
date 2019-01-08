Content-Type: multipart/mixed; boundary="===============0599146342552994256=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/8] tls: Switch state before handling Key Exchange messages
Date: Tue, 08 Jan 2019 05:29:46 +0100
Message-ID: <20190108042951.21914-3-andrew.zaborowski@intel.com>
In-Reply-To: <20190108042951.21914-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0599146342552994256==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Where we handle a Client Key Exchange or a Server Key Exchange message
and then switch to a new state, do the state change first so that if
the tls_handle_*_key_exchange functions detect and error and move to an
error state, tls->state is not overwritten afterwards.  This seems
simpler than adding a success/failure return value to these methods so
that the callers can just stop execution on error.
---
 ell/tls.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index de62e83..919c696 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2203,11 +2203,11 @@ static void tls_handle_handshake(struct l_tls *tls,=
 int type,
 			break;
 		}
 =

+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
+
 		tls->pending.cipher_suite->key_xchg->handle_server_key_exchange(
 								tls, buf, len);
 =

-		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
-
 		break;
 =

 	case TLS_CERTIFICATE_REQUEST:
@@ -2274,9 +2274,6 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 			break;
 		}
 =

-		tls->pending.cipher_suite->key_xchg->handle_client_key_exchange(
-								tls, buf, len);
-
 		/*
 		 * If we accepted a client Certificate message with a
 		 * certificate that has signing capability (TODO: check
@@ -2289,6 +2286,9 @@ static void tls_handle_handshake(struct l_tls *tls, i=
nt type,
 		else
 			TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 =

+		tls->pending.cipher_suite->key_xchg->handle_client_key_exchange(
+								tls, buf, len);
+
 		break;
 =

 	case TLS_FINISHED:
-- =

2.19.1


--===============0599146342552994256==--

