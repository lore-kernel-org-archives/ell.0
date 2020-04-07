Content-Type: multipart/mixed; boundary="===============9114554992798831466=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] cert: Fix verification of the 2nd certificate in chain
Date: Tue, 07 Apr 2020 19:45:49 +0200
Message-ID: <20200407174551.9505-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9114554992798831466==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In the case that the trusted CA certificates are provided to
l_certchain_verify() and one of them binary-matches the top CA
certificate in the chain being verified, we'd skip linking it to the
keyring and we'd link the next certificate directly.  As a result
that second certificate would be linked to an empty unrestricted keyring
and would not be verified at all.

Instead add the top CA to the keyring and restrict it the same way we
proceed when no trusted CAs are provided.
---
 ell/cert.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index d1f58d7..dc6b845 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -454,6 +454,7 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *=
chain,
 	struct l_cert *cert;
 	struct l_key *prev_key =3D NULL;
 	int verified =3D 0;
+	bool ca_match;
 	static char error_buf[200];
 =

 	if (unlikely(!chain || !chain->leaf))
@@ -464,6 +465,7 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *=
chain,
 		RETURN_ERROR("Can't create verify keyring");
 =

 	cert =3D chain->ca;
+	ca_match =3D cert_is_in_set(cert, ca_certs);
 =

 	/*
 	 * For TLS compatibility the trusted root CA certificate is
@@ -480,16 +482,9 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain =
*chain,
 	 * cert in the chain if it is identical to one of the trusted CA
 	 * certificates.  It also happens to work around a kernel issue
 	 * preventing self-signed certificates missing the AKID
-	 * extension from being linked to a keyring.
+	 * extension from being linked to a restricted keyring.
 	 */
-	if (cert_is_in_set(cert, ca_certs)) {
-		verified++;
-		cert =3D cert->issued;
-		if (!cert)
-			return true;
-
-		prev_key =3D cert_try_link(cert, verify_ring);
-	} else if (ca_certs) {
+	if (ca_certs && !ca_match) {
 		ca_ring =3D cert_set_to_keyring(ca_certs, error_buf);
 		if (!ca_ring) {
 			if (error)
@@ -550,8 +545,8 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *=
chain,
 				"verified against trusted CA(s) and the "
 				"following %i top certificates verified ok",
 				verified + 1, total,
-				ca_certs && verified ? "" : "not ",
-				verified ? verified - 1 : 0);
+				ca_certs && (ca_match || verified) ? "" :
+				"not ", verified ? verified - 1 : 0);
 	}
 =

 	l_key_free(prev_key);
-- =

2.20.1

--===============9114554992798831466==--

