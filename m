Content-Type: multipart/mixed; boundary="===============1662567364937209431=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 9/9] key: Check for supported checksum types
Date: Fri, 23 Sep 2016 16:02:22 -0700
Message-ID: <20160923230222.27401-9-mathew.j.martineau@linux.intel.com>
In-Reply-To: <20160923230222.27401-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1662567364937209431==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The TLS code currently handles digest info for PKCS1, and the key API's
use of the keyctl syscall doesn't currently use the kernel's PKCS1
functionality, so make it clear that only L_CHECKSUM_NONE is supported
for now.
---

The other alternative to this is removing the checksum args
altogether. I opted to leave those args in place since it's a reasonable
piece of (future) functionality and we can avoid API churn.


 ell/key.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/ell/key.c b/ell/key.c
index c7ee329..ad88d81 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -372,6 +372,10 @@ bool l_key_get_info(struct l_key *key, enum l_key_ciph=
er_type cipher,
 	if (unlikely(!key))
 		return false;
 =

+	/* Other checksum types are not yet supported */
+	if (checksum !=3D L_CHECKSUM_NONE)
+		return false;
+
 	return !kernel_query_key(key->serial, lookup_cipher(cipher),
 					lookup_checksum(checksum), bits,
 					public);
@@ -505,6 +509,10 @@ LIB_EXPORT ssize_t l_key_encrypt(struct l_key *key,
 	uint8_t *padded =3D NULL;
 	ssize_t ret_len;
 =

+	/* Other checksum types are not yet supported */
+	if (checksum !=3D L_CHECKSUM_NONE)
+		return -EINVAL;
+
 	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5) {
 		padded =3D pad(in, len_in, len_out, 0x02, true);
 		if (!padded)
@@ -531,6 +539,10 @@ LIB_EXPORT ssize_t l_key_decrypt(struct l_key *key,
 	uint8_t *padded =3D NULL;
 	ssize_t ret_len;
 =

+	/* Other checksum types are not yet supported */
+	if (checksum !=3D L_CHECKSUM_NONE)
+		return -EINVAL;
+
 	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5)
 		padded =3D l_malloc(len_in);
 =

@@ -557,6 +569,10 @@ LIB_EXPORT ssize_t l_key_sign(struct l_key *key,
 	uint8_t *padded =3D NULL;
 	ssize_t ret_len;
 =

+	/* Other checksum types are not yet supported */
+	if (checksum !=3D L_CHECKSUM_NONE)
+		return -EINVAL;
+
 	if (cipher =3D=3D L_KEY_RSA_PKCS1_V1_5) {
 		padded =3D pad(in, len_in, len_out, 0x01, false);
 		if (!padded)
@@ -586,6 +602,10 @@ LIB_EXPORT bool l_key_verify(struct l_key *key,
 	bool success =3D false;
 	uint8_t *sig_hash =3D l_malloc(len_sig);
 =

+	/* Other checksum types are not yet supported */
+	if (checksum !=3D L_CHECKSUM_NONE)
+		return -EINVAL;
+
 	/* The keyctl verify implementation compares the verify results
 	 * before we get a chance to unpad it. Instead, use the *encrypt*
 	 * operation (which uses the same math as verify) to get the hash
-- =

2.10.0


--===============1662567364937209431==--

