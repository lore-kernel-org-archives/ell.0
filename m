Content-Type: multipart/mixed; boundary="===============8085627214098836477=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 1/4] asn1: Call va_end() before every return
Date: Fri, 22 Sep 2017 15:12:41 -0700
Message-ID: <20170922221244.12670-2-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20170922221244.12670-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8085627214098836477==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

One call to va_end() was missing on an error path.
---
 ell/asn1-private.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ell/asn1-private.h b/ell/asn1-private.h
index 7827355..4ba17ac 100644
--- a/ell/asn1-private.h
+++ b/ell/asn1-private.h
@@ -108,8 +108,10 @@ static inline const uint8_t *asn1_der_find_elem_by_pat=
h(const uint8_t *buf,
 =

 		pos =3D va_arg(vl, int);
 =

-		if (!buf || elem_tag !=3D (pos =3D=3D -1 ? tag : ASN1_ID_SEQUENCE))
+		if (!buf || elem_tag !=3D (pos =3D=3D -1 ? tag : ASN1_ID_SEQUENCE)) {
+			va_end(vl);
 			return NULL;
+		}
 	}
 =

 	va_end(vl);
-- =

2.14.1


--===============8085627214098836477==--

