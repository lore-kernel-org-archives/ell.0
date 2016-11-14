Content-Type: multipart/mixed; boundary="===============4850336384230536642=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] tls: Don't fail if root CA present in received chain
Date: Mon, 14 Nov 2016 21:16:32 +0100
Message-ID: <1479154592-8116-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1479154592-8116-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4850336384230536642==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The certificate chain from the Server Certificate message may be a
complete chain from server's certificate to root CA.  l_keyring_link
would fail if we tried to add the self-signed root CA to the ring,
this seems to be unrelated to that certificate being the same as the
one in the trusted ring.

In the early userspace tls_cert_verify_certchain implementation the
verification would succeed if any of the certificates in the chain
was trusted by the supplied CA + the trust chain was correct, but the
RFC implies this must be the root CA (see the comment in the code).
---
 ell/tls.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 388efa7..06e3341 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2469,13 +2469,26 @@ static void tls_key_cleanup(struct l_key **p)
 	l_key_free_norevoke(*p);
 }
 =

-static bool tls_cert_verify_with_keyring(struct tls_cert *cert,
-						struct l_keyring *ring)
+static int tls_cert_verify_with_keyring(struct tls_cert *cert,
+						struct l_keyring *ring,
+						struct tls_cert *root)
 {
 	if (!cert)
 		return true;
 =

-	if (tls_cert_verify_with_keyring(cert->issuer, ring)) {
+	/*
+	 * RFC5246 7.4.2:
+	 * "Because certificate validation requires that root keys be
+	 * distributed independently, the self-signed certificate that
+	 * specifies the root certificate authority MAY be omitted from
+	 * the chain, under the assumption that the remote end must
+	 * already possess it in order to validate it in any case."
+	 */
+	if (!cert->issuer && root && cert->size =3D=3D root->size &&
+			!memcmp(cert->asn1, root->asn1, root->size))
+		return true;
+
+	if (tls_cert_verify_with_keyring(cert->issuer, ring, root)) {
 		L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup);
 =

 		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
@@ -2520,7 +2533,7 @@ bool tls_cert_verify_certchain(struct tls_cert *certc=
hain,
 	if (!verify_ring)
 		return false;
 =

-	return tls_cert_verify_with_keyring(certchain, verify_ring);
+	return tls_cert_verify_with_keyring(certchain, verify_ring, ca_cert);
 }
 =

 void tls_cert_free_certchain(struct tls_cert *cert)
-- =

2.7.4


--===============4850336384230536642==--

