Received: from mail-oa1-f54.google.com (mail-oa1-f54.google.com [209.85.160.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C36BE33DF
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 18:07:13 +0000 (UTC)
Received: by mail-oa1-f54.google.com with SMTP id 586e51a60fabf-10c0d96953fso25864830fac.0
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 11:07:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=UrbZzJ+osT7V9yxY2YbB20yfocYy/O08Dm5/Dv6Uer0=;
        b=BsfQHK0NUUcu6srM/jSI38CGzGk8/7qEcdMxgnSgSnoAXf/K8+5DZBqTBJtFQekjeK
         oqOo3V/nFRDTDqxwpplpUW8QOFCbWcach03b0+tWH8wqI+3ZLpkb84wdyb0Pki+wvBiu
         iIXhpiQcWtet4PlW88DIeogHiaovEmzj2AGBS9RWLsrPgxCUYEzSAoIjylJlO+gjMiHh
         qdJiUzddUc5sFij0B8d/FCvc7UXcq6zzR9AWEsv5b85mHGNoyzc2B8UL8ATAK+fMyBbA
         hK+JTBSFo7nhEQzfZlrKHudX+sLjMv7Xpp8tNym8MdSAcs5MnUntCIjsC2WMTq/OcLMw
         4w5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=UrbZzJ+osT7V9yxY2YbB20yfocYy/O08Dm5/Dv6Uer0=;
        b=rqnfFe8Wmbi2m/zSoWLo5YB9uSX3ctnBD4KHwd3ENXM0+9Vu+P5UHkmJaOk64BpBGr
         agdQ4B8BCkT6Uoyz0W5WoPs1KAYcv0j/zW+xR70fwwIxhKvqjFZbYnvQ2RjFfuiHAQ8k
         s07YB0535IYpvpx30tKjWrxU7ZCgPzfO6QNlJL7Aw7OZC1zv1ihXAL1CrTUrQtD+4rHb
         fwoldrmfh0YAsBHUR3NBozxaKAoeIn9KPkx85bkF4MXBH7PHaELyV8sVDgJFfppcM5i2
         Ryu3xPr9TwLnG7qBskZdRsyWpYZMmIPwjlbg85yynj6rGsFhuRxbKC5LTqtlgRxPMq17
         qJ9Q==
X-Gm-Message-State: AJIora+ixmmrbqTWFcUFLelnUQScDgEe6fLcKexox+hQENKZzQ99j+1U
	/rnd+rnBMT8xY7NUUv/uf2nEVisMcek=
X-Google-Smtp-Source: AGRyM1vR23nxpLBc2q0vw4zqbebnlnd85M0agzNd3538uVOh+uHWXskVaQipdL3cJgv+781LtLBzug==
X-Received: by 2002:a05:6808:1da:b0:33a:5174:a06f with SMTP id x26-20020a05680801da00b0033a5174a06fmr7956376oic.246.1658167632721;
        Mon, 18 Jul 2022 11:07:12 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id n23-20020a056870559700b0010c727a3c79sm6808467oao.26.2022.07.18.11.07.12
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 11:07:12 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 05/10] tls: Add helper for DigitallySigned validation
Date: Mon, 18 Jul 2022 13:00:40 -0500
Message-Id: <20220718180045.5845-5-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220718180045.5845-1-denkenz@gmail.com>
References: <20220718180045.5845-1-denkenz@gmail.com>
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

