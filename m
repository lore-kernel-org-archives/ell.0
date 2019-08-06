Content-Type: multipart/mixed; boundary="===============6204415682011538209=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 4/4] tls: Fix an error check
Date: Tue, 06 Aug 2019 15:45:14 +0200
Message-ID: <20190806134514.6340-4-andrew.zaborowski@intel.com>
In-Reply-To: <20190806134514.6340-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6204415682011538209==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index 4b23076..7405098 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2058,7 +2058,7 @@ static char *tls_get_peer_identity_str(struct l_cert =
*cert)
 			goto error;
 =

 		name =3D asn1_der_find_elem(seq, len, 1, &tag, &name_len);
-		if (!oid || (tag !=3D ASN1_ID_PRINTABLESTRING &&
+		if (!name || (tag !=3D ASN1_ID_PRINTABLESTRING &&
 					tag !=3D ASN1_ID_UTF8STRING &&
 					tag !=3D ASN1_ID_IA5STRING))
 			continue;
-- =

2.20.1


--===============6204415682011538209==--

