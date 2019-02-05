Content-Type: multipart/mixed; boundary="===============8629245995332607338=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/4] tls: Drop duplicate check
Date: Tue, 05 Feb 2019 16:55:00 +0100
Message-ID: <20190205155500.24750-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190205155500.24750-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8629245995332607338==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The Hello message handlers already call tls_cipher_suite_is_compatible
which makes sure a cipher suite incompatible with the loaded certificate
is not selected so drop the later check for certificate compatibility.
---
 ell/tls.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 7a30617..69a183c 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -921,7 +921,6 @@ static bool tls_send_certificate(struct l_tls *tls)
 {
 	uint8_t *buf, *ptr;
 	size_t total;
-	struct l_cert *leaf;
 =

 	if (tls->server && !tls->cert) {
 		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_BAD_CERT,
@@ -936,18 +935,6 @@ static bool tls_send_certificate(struct l_tls *tls)
 		return false;
 	}
 =

-	/* TODO: might want check this earlier and exclude the cipher suite */
-	leaf =3D l_certchain_get_leaf(tls->cert);
-	if (leaf && !tls->pending.cipher_suite->signature->
-			validate_cert_key_type(leaf)) {
-		TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, TLS_ALERT_CERT_UNKNOWN,
-				"Local certificate has key type incompatible "
-				"with pending cipher suite %s",
-				tls->pending.cipher_suite->name);
-
-		return false;
-	}
-
 	/*
 	 * TODO: check that the certificate is compatible with hash and
 	 * signature algorithms lists supplied to us in the Client Hello
-- =

2.19.1


--===============8629245995332607338==--

