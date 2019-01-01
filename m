Content-Type: multipart/mixed; boundary="===============0106918362141015862=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 17/17] tls: Switch state before handling Key Echange messages
Date: Tue, 01 Jan 2019 20:49:39 +0100
Message-ID: <20190101194939.5974-17-andrew.zaborowski@intel.com>
In-Reply-To: <20190101194939.5974-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0106918362141015862==
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
index fc8ab41..7db1d9b 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2176,11 +2176,11 @@ static void tls_handle_handshake(struct l_tls *tls,=
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
@@ -2247,9 +2247,6 @@ static void tls_handle_handshake(struct l_tls *tls, i=
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
@@ -2262,6 +2259,9 @@ static void tls_handle_handshake(struct l_tls *tls, i=
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


--===============0106918362141015862==--

