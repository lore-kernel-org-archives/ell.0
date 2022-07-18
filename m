Received: from mail-oa1-f54.google.com (mail-oa1-f54.google.com [209.85.160.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB19733C0
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 16:08:39 +0000 (UTC)
Received: by mail-oa1-f54.google.com with SMTP id 586e51a60fabf-10d4691a687so9638385fac.10
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 09:08:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=unu6ORPw6j+/SmyNfiGgFZxAK6xKh4SCn2G4Tz01QfQ=;
        b=W5ROfOEHRZML2S7rWGyQqVwT4sMUqFLPhZaA+nh0+M9eC5s7zUbRO/gwgyRq8de8jQ
         nUje5Dw/jfnwKWmzAccIkRwo1YpVp1ClPibWnlWE/fEOQ2KayrhsatfSUgLx7rP2JYKm
         Y/JeLOLFOcUye2vIC/Wdv6p7rFko0YUewMjxxyoT9I+Gug4PlS2mKyOmMdfV9EDQjvk7
         j8Gc4wb8pl113m5aCVUhabqrFKhVu8zeoyRPhWG1puVVYLyhaNleY1tfn3hkkN5ncB+Z
         Lul8YWofSvo50GesOV879DLGy7GHPukMuk/2Qu5GwdEANIIxGedBdogOHY1QOPqmHBJz
         0FUg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=unu6ORPw6j+/SmyNfiGgFZxAK6xKh4SCn2G4Tz01QfQ=;
        b=WNAabWWDGLDDj1a38eJchAq5bqj+c2iYYMV6gBysKi4InJ0pwX255Idx/EPOCOIBzh
         XngvzFJegY1E/6MCf/ckHoMOYGmT9lQchpF8WJWV6GL5VdsDSj/5HjpA61957P4Wy6/6
         KJVBxdSp60+kqAf3oHt4IsijfCCOkD0ADo9lc0pSZG5xOMXzxtZzWaPe1XVeH9BgMcSn
         /xAzOMdkQ5vlW7CVrbnjTPpMHsQhZQn4twziqEs9e2jR/1C4dTlU/Yw1pLN12tdgLuAZ
         ymg+FRatiotkPPYtlsxoQhIlPwplHkm1XHI9RcFw5fcoXMQucdBTlLkec9wlc0LIVuU0
         TvWA==
X-Gm-Message-State: AJIora8V5lJWKo9/fi5ghBRCYu07iaVzDDHPLGqWtnkmlOz21gLJwT2m
	DcqsSIWQjsErZ+9zfDUWVvEVD+cN+90=
X-Google-Smtp-Source: AGRyM1uOYl0AGoKkvq/DMgTiMOFvubit1XnUKqUdF9Z2uKWkAQXYnvcsc2K2OoG6XDYikfcaWmaiTQ==
X-Received: by 2002:a05:6808:140e:b0:33a:6e25:ac6 with SMTP id w14-20020a056808140e00b0033a6e250ac6mr3915439oiv.183.1658160518684;
        Mon, 18 Jul 2022 09:08:38 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id t19-20020a9d5913000000b0061cae832e5dsm297941oth.3.2022.07.18.09.08.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 09:08:38 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 7/9] tls-suites: Add ECDSA suites from RFC 8422
Date: Mon, 18 Jul 2022 11:02:20 -0500
Message-Id: <20220718160222.10634-7-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220718160222.10634-1-denkenz@gmail.com>
References: <20220718160222.10634-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/tls-suites.c | 119 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 119 insertions(+)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index bc6a756422b3..34141ab7fa56 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -262,6 +262,81 @@ static struct tls_signature_algorithm tls_rsa_signature = {
 	.verify = tls_rsa_verify,
 };
 
+static bool tls_ecdsa_validate_cert_key(struct l_cert *cert)
+{
+	return l_cert_get_pubkey_type(cert) == L_CERT_KEY_ECC;
+}
+
+static bool tls_ecdsa_verify(struct l_tls *tls,
+				const uint8_t *in, size_t in_len,
+				tls_get_hash_t get_hash,
+				const uint8_t *data, size_t data_len)
+{
+	/* RFC 8422, Section 5.10: "SHA-1 is used in TLS 1.1 and earlier" */
+	enum handshake_hash_type hash = HANDSHAKE_HASH_SHA1;
+	enum l_checksum_type sign_checksum_type;
+	const uint8_t *opaque;
+	uint16_t opaque_len;
+	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE];
+	size_t expected_len;
+	bool success;
+
+	opaque = validate_digitally_signed(tls, in, in_len,
+				SIGNATURE_ALGORITHM_ECDSA, &opaque_len);
+	if (!opaque)
+		return false;
+
+	if (tls->negotiated_version >= L_TLS_V12) {
+		hash = find_hash_by_id(in[0]);
+		if (hash == __HANDSHAKE_HASH_COUNT) {
+			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+					"Unknown hash type %i", in[0]);
+			return false;
+		}
+
+		/* Hash should match the curve, refer to RFC 5480, Section 4 */
+		switch (tls->peer_pubkey_size) {
+		case 32:
+			if (hash != HANDSHAKE_HASH_SHA256 &&
+					hash != HANDSHAKE_HASH_SHA384)
+				goto bad_hash;
+
+			break;
+		case 48:
+			if (hash != HANDSHAKE_HASH_SHA384)
+				goto bad_hash;
+
+			break;
+		bad_hash:
+		default:
+			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+					"Invalid hash %i",
+					in[0]);
+		}
+	}
+
+	get_hash(tls, hash, data, data_len, expected, &expected_len);
+	sign_checksum_type = tls_handshake_hash_data[hash].l_id;
+
+	success = l_key_verify(tls->peer_pubkey, L_KEY_ECDSA_X962,
+				sign_checksum_type, expected, opaque,
+				expected_len, opaque_len);
+
+	if (!success)
+		TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+				"Peer signature verification failed");
+	else
+		TLS_DEBUG("Peer signature verified");
+
+	return success;
+}
+
+static struct tls_signature_algorithm tls_ecdsa_signature = {
+	.id = 3, /* SignatureAlgorithm.ecdsa */
+	.validate_cert_key_type = tls_ecdsa_validate_cert_key,
+	.verify = tls_ecdsa_verify,
+};
+
 static bool tls_send_rsa_client_key_xchg(struct l_tls *tls)
 {
 	uint8_t buf[1024 + 32];
@@ -1350,11 +1425,52 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 	.prf_hmac = L_CHECKSUM_SHA384,
 	.signature = &tls_rsa_signature,
 	.key_xchg = &tls_ecdhe,
+}, tls_ecdhe_ecdsa_with_3des_ede_cbc_sha = {
+	.id = { 0xc0, 0x08 },
+	.name = "TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA",
+	.verify_data_length = 12,
+	.encryption = &tls_3des_ede,
+	.mac = &tls_sha,
+	.signature = &tls_ecdsa_signature,
+	.key_xchg = &tls_ecdhe,
+}, tls_ecdhe_ecdsa_with_aes_128_cbc_sha = {
+	.id = { 0xc0, 0x09 },
+	.name = "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
+	.verify_data_length = 12,
+	.encryption = &tls_aes128,
+	.mac = &tls_sha,
+	.signature = &tls_ecdsa_signature,
+	.key_xchg = &tls_ecdhe,
+}, tls_ecdhe_ecdsa_with_aes_256_cbc_sha = {
+	.id = { 0xc0, 0x0a },
+	.name = "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
+	.verify_data_length = 12,
+	.encryption = &tls_aes256,
+	.mac = &tls_sha,
+	.signature = &tls_ecdsa_signature,
+	.key_xchg = &tls_ecdhe,
+}, tls_ecdhe_ecdsa_with_aes_128_gcm_sha256 = {
+	.id = { 0xc0, 0x2b },
+	.name = "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
+	.verify_data_length = 12,
+	.encryption = &tls_aes128_gcm,
+	.signature = &tls_ecdsa_signature,
+	.key_xchg = &tls_ecdhe,
+}, tls_ecdhe_ecdsa_with_aes_256_gcm_sha384 = {
+	.id = { 0xc0, 0x2c },
+	.name = "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
+	.verify_data_length = 12,
+	.encryption = &tls_aes256_gcm,
+	.prf_hmac = L_CHECKSUM_SHA384,
+	.signature = &tls_ecdsa_signature,
+	.key_xchg = &tls_ecdhe,
 };
 
 struct tls_cipher_suite *tls_cipher_suite_pref[] = {
 	&tls_ecdhe_rsa_with_aes_256_cbc_sha,
+	&tls_ecdhe_ecdsa_with_aes_256_cbc_sha,
 	&tls_ecdhe_rsa_with_aes_128_cbc_sha,
+	&tls_ecdhe_ecdsa_with_aes_128_cbc_sha,
 	&tls_dhe_rsa_with_aes_256_cbc_sha,
 	&tls_dhe_rsa_with_aes_128_cbc_sha,
 	&tls_rsa_with_aes_256_cbc_sha,
@@ -1367,11 +1483,14 @@ struct tls_cipher_suite *tls_cipher_suite_pref[] = {
 	&tls_rsa_with_aes_128_cbc_sha256,
 	&tls_ecdhe_rsa_with_aes_256_gcm_sha384,
 	&tls_ecdhe_rsa_with_aes_128_gcm_sha256,
+	&tls_ecdhe_ecdsa_with_aes_256_gcm_sha384,
+	&tls_ecdhe_ecdsa_with_aes_128_gcm_sha256,
 	&tls_dhe_rsa_with_aes_256_gcm_sha384,
 	&tls_dhe_rsa_with_aes_128_gcm_sha256,
 	&tls_rsa_with_aes_256_gcm_sha384,
 	&tls_rsa_with_aes_128_gcm_sha256,
 	&tls_ecdhe_rsa_with_3des_ede_cbc_sha,
+	&tls_ecdhe_ecdsa_with_3des_ede_cbc_sha,
 	&tls_dhe_rsa_with_3des_ede_cbc_sha,
 	&tls_rsa_with_3des_ede_cbc_sha,
 	NULL,
-- 
2.35.1

