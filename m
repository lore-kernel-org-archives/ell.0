Received: from mail-oa1-f41.google.com (mail-oa1-f41.google.com [209.85.160.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D12D3323F
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 16:08:40 +0000 (UTC)
Received: by mail-oa1-f41.google.com with SMTP id 586e51a60fabf-10d4691a687so9638570fac.10
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 09:08:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=AZ+FE6qrnP6Zq9i6akjQ5AGX+vnggdrL7q6BgX8QNd8=;
        b=nRLpp3Wcs5GlUx0lOh365HHkxZVnmvSLQ1w1ju9bHyf3gJVLE/r/cePEEKrO4tmmyD
         ngTDZ5QE6erxzy066ty+8z4UIlK+TyWq0M+1mHVOxFwt14HW8nDw4l2kN7H2CQgBYyIm
         bX0wX5XrCeerktkZQ9v9sz5qwV2QXUF6oLWcmWxdYiEQ18b7WTy81wERA/xWvz6WzxxE
         fiw1ogeybkcu8gTiwExUnvv0rkubNPJIp2Ffvmu4fJNR9vhe2XTEHV7eXcxRA9MR35B4
         WyC47IpDsIQDQxpAIZgO4a2vMUjHDx1C5UlG3R5zEFpoSv1vyR/DNw0HxZ33Dl7sVDar
         sv6g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=AZ+FE6qrnP6Zq9i6akjQ5AGX+vnggdrL7q6BgX8QNd8=;
        b=J9KWozcUt7+r8gv9gxHwswQbrcZrJFFE3SFYZRhfHmMS6F5EPDhLTYkSNcO7f1AzWi
         mtMVwCPGtQuyVqGftr1ewqZuU1QDbiQ2ATvfrRAzBLstgxwh6XcETpkQHxXmIEPQLlN5
         xdngXs3LFHNzHmPlz5RQ8cAW/ujYDuboZeiVlIU5pUpoKOaPvnwc11xK0P6BUNcx118A
         lBQhKfAYz6mXyvCUsMSTMI186vu19/imseN8Z2iqhG9WyC6U/GD8SyqCDIZYbTycmOJ7
         DMeEvXqRNjemnDUynwqa7r/+VuKtgqNVr9Fa/wzy7kc72lS9aHpMT1IaKkXgj5Q/HwoU
         KrEQ==
X-Gm-Message-State: AJIora/mTeEZJkvrZ0NAgBT7MgpLjIHyRNNsRQwXYYD4RWEP2WcWuPy8
	eNkVhvTyfz6HEqIpRYDjz+JQDDbf2bU=
X-Google-Smtp-Source: AGRyM1sDWWI6/PeZkPHs7Gdkovcv0oTAFaIi4ew+NvdvAax3pdv+69Wobfs410rJohcrvlRN5lVbTQ==
X-Received: by 2002:a05:6808:144b:b0:337:aee7:b006 with SMTP id x11-20020a056808144b00b00337aee7b006mr13965313oiv.204.1658160520201;
        Mon, 18 Jul 2022 09:08:40 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id t19-20020a9d5913000000b0061cae832e5dsm297941oth.3.2022.07.18.09.08.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 09:08:39 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 9/9] tls: Do not set verify_data_length unless needed
Date: Mon, 18 Jul 2022 11:02:22 -0500
Message-Id: <20220718160222.10634-9-denkenz@gmail.com>
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

All current TLS cipher suites use a verify_data_length of 12.  In fact,
according to RFC 5246, most cipher suites are expected to be 12 bytes
unless specified otherwise.  Use this fact to simplify the cipher suite
definition: initialization of verify_data_length is no longer necessary
unless the length is greater than 12 bytes.

While here, also update struct tls_cipher_suite to use a size_t member
for verify_data_length instead of an int.
---
 ell/tls-private.h |  2 +-
 ell/tls-suites.c  | 26 --------------------------
 ell/tls.c         | 29 +++++++++++++++++++++--------
 3 files changed, 22 insertions(+), 35 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 8ceeb68df40b..8941e90d03ca 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -112,7 +112,7 @@ struct tls_mac_algorithm {
 struct tls_cipher_suite {
 	uint8_t id[2];
 	const char *name;
-	int verify_data_length;
+	size_t verify_data_length;
 
 	struct tls_bulk_encryption_algorithm *encryption;
 	struct tls_signature_algorithm *signature;
diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 34141ab7fa56..ee4e7ee6c310 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -1262,7 +1262,6 @@ static struct tls_mac_algorithm tls_sha = {
 static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 	.id = { 0x00, 0x0a },
 	.name = "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_3des_ede,
 	.mac = &tls_sha,
 	.signature = &tls_rsa_signature,
@@ -1270,7 +1269,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_dhe_rsa_with_3des_ede_cbc_sha = {
 	.id = { 0x00, 0x16 },
 	.name = "TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_3des_ede,
 	.mac = &tls_sha,
 	.signature = &tls_rsa_signature,
@@ -1278,7 +1276,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_rsa_with_aes_128_cbc_sha = {
 	.id = { 0x00, 0x2f },
 	.name = "TLS_RSA_WITH_AES_128_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128,
 	.mac = &tls_sha,
 	.signature = &tls_rsa_signature,
@@ -1286,7 +1283,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_dhe_rsa_with_aes_128_cbc_sha = {
 	.id = { 0x00, 0x33 },
 	.name = "TLS_DHE_RSA_WITH_AES_128_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128,
 	.mac = &tls_sha,
 	.signature = &tls_rsa_signature,
@@ -1294,7 +1290,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_rsa_with_aes_256_cbc_sha = {
 	.id = { 0x00, 0x35 },
 	.name = "TLS_RSA_WITH_AES_256_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256,
 	.mac = &tls_sha,
 	.signature = &tls_rsa_signature,
@@ -1302,7 +1297,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_dhe_rsa_with_aes_256_cbc_sha = {
 	.id = { 0x00, 0x39 },
 	.name = "TLS_DHE_RSA_WITH_AES_256_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256,
 	.mac = &tls_sha,
 	.signature = &tls_rsa_signature,
@@ -1310,7 +1304,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_rsa_with_aes_128_cbc_sha256 = {
 	.id = { 0x00, 0x3c },
 	.name = "TLS_RSA_WITH_AES_128_CBC_SHA256",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128,
 	.mac = &tls_sha256,
 	.signature = &tls_rsa_signature,
@@ -1318,7 +1311,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_rsa_with_aes_256_cbc_sha256 = {
 	.id = { 0x00, 0x3d },
 	.name = "TLS_RSA_WITH_AES_256_CBC_SHA256",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256,
 	.mac = &tls_sha256,
 	.signature = &tls_rsa_signature,
@@ -1326,7 +1318,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_dhe_rsa_with_aes_128_cbc_sha256 = {
 	.id = { 0x00, 0x67 },
 	.name = "TLS_DHE_RSA_WITH_AES_128_CBC_SHA256",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128,
 	.mac = &tls_sha256,
 	.signature = &tls_rsa_signature,
@@ -1334,7 +1325,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_dhe_rsa_with_aes_256_cbc_sha256 = {
 	.id = { 0x00, 0x6b },
 	.name = "TLS_DHE_RSA_WITH_AES_256_CBC_SHA256",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256,
 	.mac = &tls_sha256,
 	.signature = &tls_rsa_signature,
@@ -1342,14 +1332,12 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_rsa_with_aes_128_gcm_sha256 = {
 	.id = { 0x00, 0x9c },
 	.name = "TLS_RSA_WITH_AES_128_GCM_SHA256",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128_gcm,
 	.signature = &tls_rsa_signature,
 	.key_xchg = &tls_rsa_key_xchg,
 }, tls_rsa_with_aes_256_gcm_sha384 = {
 	.id = { 0x00, 0x9d },
 	.name = "TLS_RSA_WITH_AES_256_GCM_SHA384",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256_gcm,
 	.prf_hmac = L_CHECKSUM_SHA384,
 	.signature = &tls_rsa_signature,
@@ -1357,14 +1345,12 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_dhe_rsa_with_aes_128_gcm_sha256 = {
 	.id = { 0x00, 0x9e },
 	.name = "TLS_DHE_RSA_WITH_AES_128_GCM_SHA256",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128_gcm,
 	.signature = &tls_rsa_signature,
 	.key_xchg = &tls_dhe,
 }, tls_dhe_rsa_with_aes_256_gcm_sha384 = {
 	.id = { 0x00, 0x9f },
 	.name = "TLS_DHE_RSA_WITH_AES_256_GCM_SHA384",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256_gcm,
 	.prf_hmac = L_CHECKSUM_SHA384,
 	.signature = &tls_rsa_signature,
@@ -1372,7 +1358,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_rsa_with_3des_ede_cbc_sha = {
 	.id = { 0xc0, 0x12 },
 	.name = "TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_3des_ede,
 	.mac = &tls_sha,
 	.signature = &tls_rsa_signature,
@@ -1380,7 +1365,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_rsa_with_aes_128_cbc_sha = {
 	.id = { 0xc0, 0x13 },
 	.name = "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128,
 	.mac = &tls_sha,
 	.signature = &tls_rsa_signature,
@@ -1388,7 +1372,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_rsa_with_aes_256_cbc_sha = {
 	.id = { 0xc0, 0x14 },
 	.name = "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256,
 	.mac = &tls_sha,
 	.signature = &tls_rsa_signature,
@@ -1396,7 +1379,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_rsa_with_aes_128_cbc_sha256 = {
 	.id = { 0xc0, 0x27 },
 	.name = "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128,
 	.mac = &tls_sha256,
 	.signature = &tls_rsa_signature,
@@ -1404,7 +1386,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_rsa_with_aes_256_cbc_sha384 = {
 	.id = { 0xc0, 0x28 },
 	.name = "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256,
 	.mac = &tls_sha384,
 	.prf_hmac = L_CHECKSUM_SHA384,
@@ -1413,14 +1394,12 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_rsa_with_aes_128_gcm_sha256 = {
 	.id = { 0xc0, 0x2f },
 	.name = "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128_gcm,
 	.signature = &tls_rsa_signature,
 	.key_xchg = &tls_ecdhe,
 }, tls_ecdhe_rsa_with_aes_256_gcm_sha384 = {
 	.id = { 0xc0, 0x30 },
 	.name = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256_gcm,
 	.prf_hmac = L_CHECKSUM_SHA384,
 	.signature = &tls_rsa_signature,
@@ -1428,7 +1407,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_ecdsa_with_3des_ede_cbc_sha = {
 	.id = { 0xc0, 0x08 },
 	.name = "TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_3des_ede,
 	.mac = &tls_sha,
 	.signature = &tls_ecdsa_signature,
@@ -1436,7 +1414,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_ecdsa_with_aes_128_cbc_sha = {
 	.id = { 0xc0, 0x09 },
 	.name = "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128,
 	.mac = &tls_sha,
 	.signature = &tls_ecdsa_signature,
@@ -1444,7 +1421,6 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_ecdsa_with_aes_256_cbc_sha = {
 	.id = { 0xc0, 0x0a },
 	.name = "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256,
 	.mac = &tls_sha,
 	.signature = &tls_ecdsa_signature,
@@ -1452,14 +1428,12 @@ static struct tls_cipher_suite tls_rsa_with_3des_ede_cbc_sha = {
 }, tls_ecdhe_ecdsa_with_aes_128_gcm_sha256 = {
 	.id = { 0xc0, 0x2b },
 	.name = "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
-	.verify_data_length = 12,
 	.encryption = &tls_aes128_gcm,
 	.signature = &tls_ecdsa_signature,
 	.key_xchg = &tls_ecdhe,
 }, tls_ecdhe_ecdsa_with_aes_256_gcm_sha384 = {
 	.id = { 0xc0, 0x2c },
 	.name = "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
-	.verify_data_length = 12,
 	.encryption = &tls_aes256_gcm,
 	.prf_hmac = L_CHECKSUM_SHA384,
 	.signature = &tls_ecdsa_signature,
diff --git a/ell/tls.c b/ell/tls.c
index 75b9d45c6523..0bf647919478 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1370,11 +1370,25 @@ static void tls_send_change_cipher_spec(struct l_tls *tls)
 	tls_tx_record(tls, TLS_CT_CHANGE_CIPHER_SPEC, &buf, 1);
 }
 
+static size_t tls_verify_data_length(struct l_tls *tls, unsigned int index)
+{
+	/*
+	 * RFC 5246, Section 7.4.9:
+	 *
+	 * In previous versions of TLS, the verify_data was always 12 octets
+	 * long.  In the current version of TLS, it depends on the cipher
+	 * suite.  Any cipher suite which does not explicitly specify
+	 * verify_data_length has a verify_data_length equal to 12.
+	 */
+	return maxsize(tls->cipher_suite[index]->verify_data_length, 12);
+}
+
 static void tls_send_finished(struct l_tls *tls)
 {
 	uint8_t buf[512];
 	uint8_t *ptr = buf + TLS_HANDSHAKE_HEADER_SIZE;
 	uint8_t seed[HANDSHAKE_HASH_MAX_SIZE * 2];
+	size_t vdl = tls_verify_data_length(tls, 1);
 	size_t seed_len;
 
 	if (tls->negotiated_version >= L_TLS_V12) {
@@ -1391,8 +1405,8 @@ static void tls_send_finished(struct l_tls *tls)
 				tls->server ? "server finished" :
 				"client finished",
 				seed, seed_len,
-				ptr, tls->cipher_suite[1]->verify_data_length);
-	ptr += tls->cipher_suite[1]->verify_data_length;
+				ptr, vdl);
+	ptr += vdl;
 
 	tls_tx_handshake(tls, TLS_FINISHED, buf, ptr - buf);
 }
@@ -1400,14 +1414,14 @@ static void tls_send_finished(struct l_tls *tls)
 static bool tls_verify_finished(struct l_tls *tls, const uint8_t *received,
 				size_t len)
 {
-	uint8_t expected[tls->cipher_suite[0]->verify_data_length];
+	size_t vdl = tls_verify_data_length(tls, 0);
+	uint8_t expected[vdl];
 	uint8_t *seed;
 	size_t seed_len;
 
-	if (len != (size_t) tls->cipher_suite[0]->verify_data_length) {
+	if (len != vdl) {
 		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
-				"TLS_FINISHED length not %i",
-				tls->cipher_suite[0]->verify_data_length);
+				"TLS_FINISHED length not %zu", vdl);
 
 		return false;
 	}
@@ -1428,8 +1442,7 @@ static bool tls_verify_finished(struct l_tls *tls, const uint8_t *received,
 				tls->server ? "client finished" :
 				"server finished",
 				seed, seed_len,
-				expected,
-				tls->cipher_suite[0]->verify_data_length);
+				expected, vdl);
 
 	if (memcmp(received, expected, len)) {
 		TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
-- 
2.35.1

