Content-Type: multipart/mixed; boundary="===============2425379243500950651=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/3] pkcs5: Fix pbes2 KDF parsing
Date: Thu, 17 Aug 2017 11:06:29 +0200
Message-ID: <20170817090631.27630-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2425379243500950651==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make the key length field optional -- skip if the tag doesn't match --
and fix the oid comparison.
---
 ell/pkcs5.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/ell/pkcs5.c b/ell/pkcs5.c
index cf61a35..7cedf4d 100644
--- a/ell/pkcs5.c
+++ b/ell/pkcs5.c
@@ -254,7 +254,7 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_params(
 	const uint8_t *kdf_sequence, *enc_sequence, *oid, *params,
 		*salt, *iter_count_buf, *key_len_buf, *prf_sequence;
 	size_t kdf_len, enc_len, params_len, salt_len, key_len, tmp_len;
-	unsigned int i, iter_count;
+	unsigned int i, iter_count, pos;
 	enum l_checksum_type prf_alg =3D L_CHECKSUM_NONE;
 	const struct pkcs5_enc_alg_oid *enc_scheme =3D NULL;
 	uint8_t derived_key[64];
@@ -309,11 +309,14 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_param=
s(
 	while (tmp_len--)
 		iter_count =3D (iter_count << 8) | *iter_count_buf++;
 =

-	key_len_buf =3D asn1_der_find_elem(params, params_len, 2, &tag, &tmp_len);
-	if (key_len_buf) {
-		if (tag !=3D ASN1_ID_INTEGER || tmp_len !=3D 1)
+	pos =3D 2;
+	key_len_buf =3D asn1_der_find_elem(params, params_len, pos,
+						&tag, &tmp_len);
+	if (key_len_buf && tag =3D=3D ASN1_ID_INTEGER) {
+		if (tmp_len !=3D 1)
 			return NULL;
 =

+		pos++;
 		key_len =3D 0;
 =

 		while (tmp_len--)
@@ -321,11 +324,10 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_param=
s(
 	} else
 		key_len =3D 0;
 =

-	prf_sequence =3D asn1_der_find_elem(params, params_len, 3,
+	prf_sequence =3D asn1_der_find_elem(params, params_len, pos,
 						&tag, &tmp_len);
-	if (prf_sequence) {
-		if (tag !=3D ASN1_ID_SEQUENCE)
-			return NULL;
+	if (prf_sequence && tag =3D=3D ASN1_ID_SEQUENCE) {
+		pos++;
 =

 		oid =3D asn1_der_find_elem(prf_sequence, tmp_len, 0,
 						&tag, &tmp_len);
@@ -333,7 +335,7 @@ static struct l_cipher *pkcs5_cipher_from_pbes2_params(
 			return NULL;
 =

 		for (i =3D 0; i < L_ARRAY_SIZE(pkcs5_digest_alg_oids); i++)
-			if (!asn1_oid_eq(&pkcs5_digest_alg_oids[i].oid,
+			if (asn1_oid_eq(&pkcs5_digest_alg_oids[i].oid,
 						tmp_len, oid))
 				prf_alg =3D pkcs5_digest_alg_oids[i].type;
 =

-- =

2.11.0


--===============2425379243500950651==--

