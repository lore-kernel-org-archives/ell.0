Content-Type: multipart/mixed; boundary="===============5151471452945360475=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 08/16] cert: Fix l_cert_get_dn
Date: Wed, 21 Nov 2018 16:08:55 +0100
Message-ID: <20181121150903.24437-8-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5151471452945360475==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The DistinguishedName type is a SEQUENCE, this was a copy&paste error.
---
 ell/cert.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/cert.c b/ell/cert.c
index 1c95d0c..f0ce181 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -162,7 +162,7 @@ LIB_EXPORT const uint8_t *l_cert_get_dn(struct l_cert *=
cert, size_t *out_len)
 		return NULL;
 =

 	return asn1_der_find_elem_by_path(cert->asn1, cert->asn1_len,
-						ASN1_ID_OID, out_len,
+						ASN1_ID_SEQUENCE, out_len,
 						X509_CERTIFICATE_POS,
 						X509_TBSCERTIFICATE_POS,
 						X509_TBSCERT_SUBJECT_DN_POS,
-- =

2.19.1


--===============5151471452945360475==--

