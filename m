Content-Type: multipart/mixed; boundary="===============8536761593174251758=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 8/9] tls: Use l_checksum_updatev in tls_get_dh_params_hash
Date: Tue, 22 Jan 2019 07:09:04 +0100
Message-ID: <20190122060905.27452-8-andrew.zaborowski@intel.com>
In-Reply-To: <20190122060905.27452-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8536761593174251758==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Reduce the number of syscalls by using an iovec.
---
 ell/tls-suites.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index fc849ce..d6b4caa 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -347,19 +347,23 @@ static bool tls_get_dh_params_hash(struct l_tls *tls,
 	struct l_checksum *checksum;
 	ssize_t ret;
 =

-	checksum =3D l_checksum_new(tls_handshake_hash_data[type].l_id);
-	if (!checksum)
-		return false;
-
 	/*
 	 * The ServerKeyExchange signature hash input format for RSA_sign is
 	 * not really specified in either RFC 8422 or RFC 5246 explicitly
 	 * but we use this format by analogy to DHE_RSA which uses RSA_sign
 	 * as well.  Also matches ecdsa, ed25519 and ed448 formats.
 	 */
-	l_checksum_update(checksum, tls->pending.client_random, 32);
-	l_checksum_update(checksum, tls->pending.server_random, 32);
-	l_checksum_update(checksum, data, data_len);
+	struct iovec iov[] =3D {
+		{ .iov_base =3D tls->pending.client_random, .iov_len =3D 32 },
+		{ .iov_base =3D tls->pending.server_random, .iov_len =3D 32 },
+		{ .iov_base =3D (void *) data, .iov_len =3D data_len },
+	};
+
+	checksum =3D l_checksum_new(tls_handshake_hash_data[type].l_id);
+	if (!checksum)
+		return false;
+
+	l_checksum_updatev(checksum, iov, L_ARRAY_SIZE(iov));
 	ret =3D l_checksum_get_digest(checksum, out, HANDSHAKE_HASH_MAX_SIZE);
 	l_checksum_free(checksum);
 =

-- =

2.19.1


--===============8536761593174251758==--

