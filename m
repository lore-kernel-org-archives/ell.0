Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5897D33D1
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 16:08:38 +0000 (UTC)
Received: by mail-oo1-f41.google.com with SMTP id r193-20020a4a37ca000000b0043578138958so2099973oor.4
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 09:08:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UrbZzJ+osT7V9yxY2YbB20yfocYy/O08Dm5/Dv6Uer0=;
        b=XfupXUzNeQS/azJVWNb2bdFCLp+lbCE332Y7zgGIDrgXLCcLLUn/VVdiXv1K5gBp4K
         yI1Dy8IfhBQ8d5A6K+xWUAHTqVDYQuMwaROtsrogyJ45GbkQCFhT2ibiOdFHS59Eao2d
         2659hfYnxipFqdUveTtK1xzYdTCfq1o8PrTkWH511VIa0tOl7ghHqsqWRw8taGIPDGtt
         DcCFXqDmsLouLO+NJwZLJZkRN78o3J+gj6jU0O3LLFPwnkLWAp+TOTZupbguqWQA263L
         7pbjQacuDdFsanIqEVnblNwECP1IyjZ2fIPMKTH6okD4+xTK6itztiKG2ucx/0u6ikN5
         NzFg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=UrbZzJ+osT7V9yxY2YbB20yfocYy/O08Dm5/Dv6Uer0=;
        b=zJRmsDgbUGEtgqzNtYy+z5QHe0/h36a6dNx68Ds8HSQyEQiUaPg9UH+mgz4kVJurjV
         hKbdtVCkNc2+y9YqMyPVprDgc6S2mYdPrhR3bTcYxoTFagH1UyyN3kxkri8/vnzvR9ly
         UmDjQ0SBvE0OUneNLHZlta5zyPudV67rpYlUZNb1PKdwQ2WcawIibgEzlzY/gnmzjX2l
         6Nlp7PDMRmlD2H3DwRn2OFTKFn817L7YNMtOLZx9kE7Kab6RlZRY8Df1V/cH1QhlQNPB
         Xfda3+59hx41XkjydGB9xC4JQvokI+BuKbvSBZRI7mTvz6I+bVBJfHI1qYpJmuCzG8kW
         NmTA==
X-Gm-Message-State: AJIora/5R+eIwamjFnrLVWznW9T9tmnVXGA1n05vCa49oznsVkraiWrP
	lpLQmmc/10+bnC3cBmXbiJecygTFwuI=
X-Google-Smtp-Source: AGRyM1uSyvx1UX3cdL7FOZGapdsjq18W7Qux6eGb5R/8QOU+3XjbgEb6b7Z+qoPS9O3Pv9W6bXlVAQ==
X-Received: by 2002:a4a:b989:0:b0:425:a72a:c795 with SMTP id e9-20020a4ab989000000b00425a72ac795mr9659812oop.90.1658160517287;
        Mon, 18 Jul 2022 09:08:37 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id t19-20020a9d5913000000b0061cae832e5dsm297941oth.3.2022.07.18.09.08.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 09:08:37 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 5/9] tls: Add helper for DigitallySigned validation
Date: Mon, 18 Jul 2022 11:02:18 -0500
Message-Id: <20220718160222.10634-5-denkenz@gmail.com>
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

To support additional signature algorithms, move the logic
that validates DigitallySigned structure to a helper function.
---
 ell/tls-suites.c | 87 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 60 insertions(+), 27 deletions(-)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index 1c1ca078b3d8..d5d2ec8f741f 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -40,6 +40,57 @@
 #include "ecdh.h"
 #include "missing.h"
 
+enum signature_algorithm {
+	SIGNATURE_ALGORITHM_ANONYMOUS = 0,
+	SIGNATURE_ALGORITHM_RSA = 1,
+	SIGNATURE_ALGORITHM_DSA = 2,
+	SIGNATURE_ALGORITHM_ECDSA = 3,
+};
+
+/*
+ * Sanitize DigitallySigned struct input, making sure the lengths
+ * are valid and correspond to what we expect.
+ *
+ * Returns: start of the opaque portion
+ */
+static const uint8_t *validate_digitally_signed(struct l_tls *tls,
+					const uint8_t *in, size_t in_len,
+					enum signature_algorithm expected_alg,
+					uint16_t *opaque_len)
+{
+	size_t offset = 2;
+	uint16_t len;
+
+	if (tls->negotiated_version < L_TLS_V12)
+		offset = 0;
+
+	if (in_len < offset + 2)
+		goto size_error;
+
+	len = l_get_be16(in + offset);
+	if (len != in_len - offset - 2)
+		goto size_error;
+
+	if (tls->negotiated_version >= L_TLS_V12) {
+		if (in[1] != expected_alg) {
+			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
+					"Unknown signature algorithm %i",
+					in[1]);
+
+			return NULL;
+		}
+	}
+
+	*opaque_len = len;
+	return in + offset + 2;
+
+size_error:
+	TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0, "Signature msg too "
+			"short (%zi) or signature length doesn't match",
+			in_len);
+	return NULL;
+}
+
 static bool tls_rsa_validate_cert_key(struct l_cert *cert)
 {
 	return l_cert_get_pubkey_type(cert) == L_CERT_KEY_RSA;
@@ -112,29 +163,20 @@ static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t in_len,
 	enum l_checksum_type sign_checksum_type;
 	uint8_t expected[HANDSHAKE_HASH_MAX_SIZE + 36];
 	size_t expected_len;
-	unsigned int offset;
+	const uint8_t *opaque;
+	uint16_t opaque_len;
 	bool success;
 
-	/* 2 bytes for SignatureAndHashAlgorithm if version >= 1.2 */
-	offset = 2;
-	if (tls->negotiated_version < L_TLS_V12)
-		offset = 0;
-
-	if (in_len < offset + 2 ||
-			(size_t) l_get_be16(in + offset) + offset + 2 !=
-			in_len) {
-		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0, "Signature msg too "
-				"short (%zi) or signature length doesn't match",
-				in_len);
-
+	opaque = validate_digitally_signed(tls, in, in_len,
+				SIGNATURE_ALGORITHM_RSA, &opaque_len);
+	if (!opaque)
 		return false;
-	}
 
 	/* Only the default hash type supported */
-	if (in_len != offset + 2 + tls->peer_pubkey_size) {
+	if (opaque_len != tls->peer_pubkey_size) {
 		TLS_DISCONNECT(TLS_ALERT_DECODE_ERROR, 0,
-				"Signature length %zi not equal %zi", in_len,
-				offset + 2 + tls->peer_pubkey_size);
+				"Signature length %hu not equal %zi",
+				opaque_len, tls->peer_pubkey_size);
 
 		return false;
 	}
@@ -142,15 +184,6 @@ static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t in_len,
 	if (tls->negotiated_version >= L_TLS_V12) {
 		enum handshake_hash_type hash;
 
-		/* Only RSA supported */
-		if (in[1] != 1 /* RSA_sign */) {
-			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
-					"Unknown signature algorithm %i",
-					in[1]);
-
-			return false;
-		}
-
 		for (hash = 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
 			if (tls_handshake_hash_data[hash].tls_id == in[0])
 				break;
@@ -203,7 +236,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t in_len,
 	}
 
 	success = l_key_verify(tls->peer_pubkey, L_KEY_RSA_PKCS1_V1_5,
-				sign_checksum_type, expected, in + offset + 2,
+				sign_checksum_type, expected, opaque,
 				expected_len, tls->peer_pubkey_size);
 
 	if (!success)
-- 
2.35.1

