Content-Type: multipart/mixed; boundary="===============8156293567180261736=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] cert: Try TLS format in l_cert_load_container_file
Date: Wed, 28 Apr 2021 19:30:19 +0200
Message-ID: <20210428173021.2036697-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8156293567180261736==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/cert.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 14631b2..141ea1c 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -35,6 +35,8 @@
 #include "pem-private.h"
 #include "cert.h"
 #include "cert-private.h"
+#include "tls.h"
+#include "tls-private.h"
 #include "missing.h"
 =

 #define X509_CERTIFICATE_POS			0
@@ -1635,14 +1637,34 @@ LIB_EXPORT bool l_cert_load_container_file(const ch=
ar *filename,
 		if (err !=3D -ENOMSG)
 			goto close;
 =

-		/* Try PEM */
+		/* Try other formats */
+	}
+
+	/*
+	 * For backwards compatibility try the TLS internal struct Certificate
+	 * format as may be captured by PCAP (no future support guaranteed).
+	 */
+	if (out_certchain && !password && file.st.st_size &&
+			tls_parse_certificate_list(file.data, file.st.st_size,
+							out_certchain) =3D=3D 0) {
+		error =3D false;
+
+		if (out_privkey)
+			*out_privkey =3D NULL;
+
+		if (out_encrypted)
+			*out_encrypted =3D false;
+
+		goto close;
 	}
 =

 	/*
 	 * RFC 7486 allows whitespace and possibly other data before the
 	 * PEM "encapsulation boundary" so rather than check if the start
 	 * of the data looks like PEM, we fall back to this format if the
-	 * data didn't look like anything else we knew about.
+	 * data didn't look like anything else we knew about.  Note this
+	 * succeeds for empty files and files without any PEM markers,
+	 * returning NULL chain and privkey.
 	 */
 	if (cert_try_load_pem_format((const char *) file.data, file.st.st_size,
 					password, out_certchain, out_privkey,
-- =

2.27.0

--===============8156293567180261736==--

