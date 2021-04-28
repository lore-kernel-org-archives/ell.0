Content-Type: multipart/mixed; boundary="===============7478602110485167674=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/3] tls: Proceed after l_certchain_verify failure if no CA
 certs
Date: Wed, 28 Apr 2021 19:30:21 +0200
Message-ID: <20210428173021.2036697-3-andrew.zaborowski@intel.com>
In-Reply-To: <20210428173021.2036697-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7478602110485167674==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Until the mainstream kernel can handle the occasionally used
certificates without the AKID extension (both root, which is legal, and
non-root, which is iffy but still happens) don't fail on peer
certificate chain verification failure when CA certificates were not
provided.  Knowing that the chain is self-consistent alone doesn't
authenticate the peer in any way.  Only warn when it looks like the
chain is bad, but it parses and we can get the peer public key from it
for later key derivation etc.

Some patches for the kernel problem have been on the kernel lists for a
long while but have not been merged so far.
---
 ell/tls.c | 52 +++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 35 insertions(+), 17 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 2c3274a..c246f1f 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1892,7 +1892,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 					const uint8_t *buf, size_t len)
 {
 	size_t total;
-	struct l_certchain *certchain =3D NULL;
+	_auto_(l_certchain_free) struct l_certchain *certchain =3D NULL;
 	struct l_cert *leaf;
 	size_t der_len;
 	const uint8_t *der;
@@ -1914,7 +1914,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
 				"Error decoding peer certificate chain");
 =

-		goto done;
+		return;
 	}
 =

 	/*
@@ -1930,12 +1930,12 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 			TLS_DISCONNECT(TLS_ALERT_HANDSHAKE_FAIL, 0,
 					"Server sent no certificate chain");
 =

-			goto done;
+			return;
 		}
 =

 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_KEY_EXCHANGE);
 =

-		goto done;
+		return;
 	}
 =

 	if (tls->cert_dump_path) {
@@ -1956,12 +1956,33 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 	 * against our CAs if we have any.
 	 */
 	if (!l_certchain_verify(certchain, tls->ca_certs, &error_str)) {
-		TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
-				"Peer certchain verification failed "
-				"consistency check%s: %s", tls->ca_certs ?
-				" or against local CA certs" : "", error_str);
+		if (tls->ca_certs) {
+			TLS_DISCONNECT(TLS_ALERT_BAD_CERT, 0,
+					"Peer certchain verification failed "
+					"consistency check%s: %s",
+					tls->ca_certs ?
+					" or against local CA certs" : "",
+					error_str);
 =

-		goto done;
+			return;
+		}
+
+		/*
+		 * Until the mainstream kernel can handle the occasionally
+		 * used certificates without the AKID extension (both root,
+		 * which is legal, and non-root, which is iffy but still
+		 * happens) don't fail on peer certificate chain verification
+		 * failure when CA certificates were not provided.  Knowing
+		 * that the chain is self-consistent alone doesn't
+		 * authenticate the peer in any way.  Only warn when it looks
+		 * like the chain is bad but parses and we can get the peer
+		 * public key from it below.
+		 */
+		TLS_DEBUG("Peer certchain verification failed (%s.)  No local "
+				"CA certs provided so proceeding anyway.  This "
+				"failure can signal a security issue or a "
+				"known kernel problem with some certificates.",
+				error_str);
 	}
 =

 	/*
@@ -1978,7 +1999,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 				"pending cipher suite %s",
 				tls->pending.cipher_suite->name);
 =

-		goto done;
+		return;
 	}
 =

 	if (tls->subject_mask && !tls_cert_domains_match_mask(leaf,
@@ -1992,7 +2013,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 		l_free(mask);
 		l_free(subject_str);
 =

-		goto done;
+		return;
 	}
 =

 	/* Save the end-entity certificate and free the chain */
@@ -2004,7 +2025,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 		TLS_DISCONNECT(TLS_ALERT_UNSUPPORTED_CERT, 0,
 				"Error loading peer public key to kernel");
 =

-		goto done;
+		return;
 	}
 =

 	if (!l_key_get_info(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
@@ -2013,7 +2034,7 @@ static void tls_handle_certificate(struct l_tls *tls,
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
 				"Can't l_key_get_info for peer public key");
 =

-		goto done;
+		return;
 	}
 =

 	tls->peer_pubkey_size /=3D 8;
@@ -2024,14 +2045,11 @@ static void tls_handle_certificate(struct l_tls *tl=
s,
 	else
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO_DONE);
 =

-	goto done;
+	return;
 =

 decode_error:
 	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
 			"TLS_CERTIFICATE decode error");
-
-done:
-	l_certchain_free(certchain);
 }
 =

 static void tls_handle_certificate_request(struct l_tls *tls,
-- =

2.27.0

--===============7478602110485167674==--

