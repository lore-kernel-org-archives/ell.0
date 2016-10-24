Content-Type: multipart/mixed; boundary="===============2833412000265533893=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 4/5] tls: Validate cert chain using l_keyring
Date: Mon, 24 Oct 2016 11:44:55 -0700
Message-ID: <20161024184456.25743-4-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20161024184456.25743-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2833412000265533893==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/tls.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 54 insertions(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index a89b2db..55b3b1a 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2464,10 +2464,63 @@ static const struct pkcs1_encryption_oid {
 	},
 };
 =

+static void tls_key_cleanup(struct l_key **p)
+{
+	l_key_free(*p, false);
+}
+
+static bool tls_cert_verify_with_keyring(struct tls_cert *cert,
+						struct l_keyring *ring)
+{
+	if (!cert)
+		return true;
+
+	if (tls_cert_verify_with_keyring(cert->issuer, ring)) {
+		L_AUTO_CLEANUP_VAR(struct l_key *, key, tls_key_cleanup);
+
+		key =3D l_key_new(L_KEY_RSA, cert->asn1, cert->size);
+		if (!key)
+			return false;
+
+		return l_keyring_link(ring, key);
+	}
+
+	return false;
+}
+
+static void tls_keyring_cleanup(struct l_keyring **p)
+{
+	l_keyring_free(*p, true);
+}
+
 bool tls_cert_verify_certchain(struct tls_cert *certchain,
 				struct tls_cert *ca_cert)
 {
-	return true;
+	L_AUTO_CLEANUP_VAR(struct l_keyring *, ca_ring, tls_keyring_cleanup);
+	L_AUTO_CLEANUP_VAR(struct l_keyring *, verify_ring,
+				tls_keyring_cleanup);
+
+	ca_ring =3D NULL;
+	verify_ring =3D NULL;
+
+	if (ca_cert) {
+		L_AUTO_CLEANUP_VAR(struct l_key *, ca_key, tls_key_cleanup);
+		ca_key =3D NULL;
+
+		ca_ring =3D l_keyring_new(L_KEYRING_SIMPLE, NULL);
+		if (!ca_ring)
+			return false;
+
+		ca_key =3D l_key_new(L_KEY_RSA, ca_cert->asn1, ca_cert->size);
+		if (!ca_key || !l_keyring_link(ca_ring, ca_key))
+			return false;
+	}
+
+	verify_ring =3D l_keyring_new(L_KEYRING_TRUSTED_ASYM_CHAIN, ca_ring);
+	if (!verify_ring)
+		return false;
+
+	return tls_cert_verify_with_keyring(certchain, verify_ring);
 }
 =

 void tls_cert_free_certchain(struct tls_cert *cert)
-- =

2.10.1


--===============2833412000265533893==--

