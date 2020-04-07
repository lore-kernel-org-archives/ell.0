Content-Type: multipart/mixed; boundary="===============4223408212231841456=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/3] cert: Relax trused CA matching in l_certchain_verify
Date: Tue, 07 Apr 2020 19:45:50 +0200
Message-ID: <20200407174551.9505-2-andrew.zaborowski@intel.com>
In-Reply-To: <20200407174551.9505-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4223408212231841456==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Check if any of the certificates in the chain matched any of the
trusted CA certificates (if given) and treat the chain as trusted even
if the matching certificate was not the top CA in the chain.
We also don't require that the trusted certificates or the root in the
chain are self-signed.

This allows a user to pin a specific certificate to a server/client or
trust a subtree of all of the certificates emitted by the root CA.
---
 ell/cert.c | 30 ++++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index dc6b845..cb3bda7 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -454,7 +454,8 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain *=
chain,
 	struct l_cert *cert;
 	struct l_key *prev_key =3D NULL;
 	int verified =3D 0;
-	bool ca_match;
+	int ca_match =3D 0;
+	int i =3D 0;
 	static char error_buf[200];
 =

 	if (unlikely(!chain || !chain->leaf))
@@ -464,8 +465,13 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain =
*chain,
 	if (!verify_ring)
 		RETURN_ERROR("Can't create verify keyring");
 =

+	for (cert =3D chain->ca; cert; cert =3D cert->issued, i++)
+		if (cert_is_in_set(cert, ca_certs)) {
+			ca_match =3D i + 1;
+			break;
+		}
+
 	cert =3D chain->ca;
-	ca_match =3D cert_is_in_set(cert, ca_certs);
 =

 	/*
 	 * For TLS compatibility the trusted root CA certificate is
@@ -539,14 +545,22 @@ LIB_EXPORT bool l_certchain_verify(struct l_certchain=
 *chain,
 =

 	if (!prev_key) {
 		int total =3D 0;
+		char str[100];
 =

 		for (cert =3D chain->ca; cert; cert =3D cert->issued, total++);
-		RETURN_ERROR("Linking certificate %i / %i failed, root %s"
-				"verified against trusted CA(s) and the "
-				"following %i top certificates verified ok",
-				verified + 1, total,
-				ca_certs && (ca_match || verified) ? "" :
-				"not ", verified ? verified - 1 : 0);
+
+		if (ca_match)
+			snprintf(str, sizeof(str), "%i / %i matched a trusted "
+					"certificate, root not verified",
+					ca_match, total);
+		else
+			snprintf(str, sizeof(str), "root %sverified against "
+					"trusted CA(s)",
+					ca_certs && !ca_match && verified ? "" :
+					"not ");
+
+		RETURN_ERROR("Linking certificate %i / %i failed, %s",
+				verified + 1, total, str);
 	}
 =

 	l_key_free(prev_key);
-- =

2.20.1

--===============4223408212231841456==--

