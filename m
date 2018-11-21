Content-Type: multipart/mixed; boundary="===============1156478330104484317=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 04/16] tls: Load local cert using l_pem_load_certificate_chain
Date: Wed, 21 Nov 2018 16:08:51 +0100
Message-ID: <20181121150903.24437-4-andrew.zaborowski@intel.com>
In-Reply-To: <20181121150903.24437-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1156478330104484317==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This will allow to load the whole chain instead of just the first
certificate in the file, if a certificate chain file is supplied
although that's optional.  The certificate chain file is just a
concatenation of PEM structures and the first one is the end-entity
certificate so it is backwards compatible.  If a CA certificate
is set with l_tls_set_cacert it need to also be the last certificate
in the file or the issuer of the last certificate.

Until now things worked because the certificate supplied can be directly
signed by the supplied CA certificate and the two certificates then form
the full chain but longer chains need to also be supported.

With this tls_cert_load_file is only used by the unit tests.
tls_cert_load_file is the only user of <ell/cert-private.h> in tls.c and
also the only user of l_pem_load_certificate.
---
 ell/tls.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 4f29cec..d92854c 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2640,14 +2640,11 @@ LIB_EXPORT bool l_tls_set_auth_data(struct l_tls *t=
ls, const char *cert_path,
 	}
 =

 	if (cert_path) {
-		struct l_cert *cert =3D tls_cert_load_file(cert_path);
-
-		if (!cert) {
+		tls->cert =3D l_pem_load_certificate_chain(cert_path);
+		if (!tls->cert) {
 			TLS_DEBUG("Error loading %s", cert_path);
 			return false;
 		}
-
-		tls->cert =3D certchain_new_from_leaf(cert);
 	}
 =

 	if (priv_key_path) {
-- =

2.19.1


--===============1156478330104484317==--

