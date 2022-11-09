Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8BAC5EC1B
	for <ell@lists.linux.dev>; Wed,  9 Nov 2022 17:48:02 +0000 (UTC)
Received: by mail-wr1-f52.google.com with SMTP id cl5so26874597wrb.9
        for <ell@lists.linux.dev>; Wed, 09 Nov 2022 09:48:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=KKOsLauaZv+1Ccf0V8LccBIDTPwkceWTujrA1bhUyK4=;
        b=iCweGwaVnBpn9cOESRkFGvtuJ/ibB4QT9FJDodtTV21tIS5UZU0ozKNAT4Za+Bd4wv
         Ga0zUe0U0Dy3sLeiDd0HbhZdr4uo3fsVfFoTc7a8Njv0qWxQK9gADyDI16IrMJpr7ugc
         kLSdfU5rh1hq7vI0rqe8Vskfg92L4drO8bxtoNfXwvnM7eVpFNVrJKMR4GOMbAziPt8n
         hgBPqClmkHvhE3nzLU6JTGdOb685h5dN5oTPkw9Us0GajmGqLD4JaFxvhc9AUZypuD4H
         aqqfaT6uRehAHMDQ6hbpdSFg621gpQjIWIQcuDL3xt2TfCcTRpMG6UPj/1+7QeNHJE4O
         6wwQ==
X-Gm-Message-State: ACrzQf1vxYKf+RUDuH84DjVSusi52t7XGxKB0W5YeWOVCKoC7ZXbMoFI
	/RiUY4ND9UiomB0geGPnaSskYF2mNT0=
X-Google-Smtp-Source: AMsMyM5RLVQKamJD5liN/w5Yr3g3v5c8tQ9Y+vhC1EbH0Deq+RhbMk+QJPJKiMY6Uuna92agn+3YNQ==
X-Received: by 2002:a5d:4ecb:0:b0:236:be56:1a6 with SMTP id s11-20020a5d4ecb000000b00236be5601a6mr38056535wrv.252.1668016080018;
        Wed, 09 Nov 2022 09:48:00 -0800 (PST)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id bh2-20020a05600005c200b002366d1cc198sm13934567wrb.41.2022.11.09.09.47.58
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Nov 2022 09:47:58 -0800 (PST)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 3/4] tls: Implement RFC 5746 Secure Renegotiation
Date: Wed,  9 Nov 2022 18:47:45 +0100
Message-Id: <20221109174746.569046-3-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221109174746.569046-1-andrew.zaborowski@intel.com>
References: <20221109174746.569046-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Implement the renegotiation_info extension to prevent some types of
attacks using renegotiation (describen in the RFC) and make the l_tls
server compatible with more clients.

Move the tls_verify_data_length declaration to tls.h for use in
tls-extensions.c.

Due to an assertion in tls_save_verify_data(), tls_send_finished() now
returns a bool so its callers are also changed to check the return value.
---
 ell/tls-extensions.c | 133 +++++++++++++++++++++++++++++++++++++++++++
 ell/tls-private.h    |   9 +++
 ell/tls.c            |  79 +++++++++++++++++++++++--
 3 files changed, 216 insertions(+), 5 deletions(-)

diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index d03c331..bc8fc3d 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -850,6 +850,130 @@ static bool tls_signature_algorithms_client_absent(struct l_tls *tls)
 	return true;
 }
 
+/* RFC 5746, Section 3.2 */
+static ssize_t tls_renegotiation_info_client_write(struct l_tls *tls,
+						uint8_t *buf, size_t len)
+{
+	/*
+	 * Section 4.2 implies we should send the client_verify_data on
+	 * renegotiation even if .secure_renegotiation is false, if we want
+	 * to go through with the renegotiation in the first place.
+	 */
+	if (tls->ready) {
+		size_t vdl = tls_verify_data_length(tls, 1);
+
+		if (len < vdl + 1)
+			return -ENOMEM;
+
+		buf[0] = vdl;
+		memcpy(buf + 1, tls->renegotiation_info.client_verify_data,
+			vdl);
+		return 1 + vdl;
+	} else {
+		if (len < 1)
+			return -ENOMEM;
+
+		buf[0] = 0x00;	/* Empty "renegotiated_connection" */
+		return 1;
+	}
+}
+
+static ssize_t tls_renegotiation_info_server_write(struct l_tls *tls,
+						uint8_t *buf, size_t len)
+{
+	if (tls->ready) {
+		size_t rx_vdl = tls_verify_data_length(tls, 0);
+		size_t tx_vdl = tls_verify_data_length(tls, 1);
+
+		if (len < rx_vdl + tx_vdl + 1)
+			return -ENOMEM;
+
+		buf[0] = rx_vdl + tx_vdl;
+		memcpy(buf + 1,
+			tls->renegotiation_info.client_verify_data, rx_vdl);
+		memcpy(buf + 1 + rx_vdl,
+			tls->renegotiation_info.server_verify_data, tx_vdl);
+		return 1 + rx_vdl + tx_vdl;
+	} else {
+		if (len < 1)
+			return -ENOMEM;
+
+		buf[0] = 0x00;	/* Empty "renegotiated_connection" */
+		return 1;
+	}
+}
+
+static bool tls_renegotiation_info_client_handle(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	if (tls->ready) {
+		size_t vdl = tls_verify_data_length(tls, 0);
+
+		return len >= 1 + vdl &&
+			tls->renegotiation_info.secure_renegotiation &&
+			!memcmp(tls->renegotiation_info.client_verify_data,
+				buf + 1, vdl);
+	}
+
+	/*
+	 * RFC 5746 Section 3.6: "The server MUST then verify that the length
+	 * of the "renegotiated_connection" field is zero, ..."
+	 */
+	if (len < 1 || buf[0] != 0x00)
+		return false;
+
+	tls->renegotiation_info.secure_renegotiation = true;
+	return true;
+}
+
+static bool tls_renegotiation_info_server_handle(struct l_tls *tls,
+						const uint8_t *buf, size_t len)
+{
+	if (tls->ready) {
+		size_t rx_vdl = tls_verify_data_length(tls, 0);
+		size_t tx_vdl = tls_verify_data_length(tls, 1);
+
+		return len >= 1 + rx_vdl + tx_vdl &&
+			tls->renegotiation_info.secure_renegotiation &&
+			!memcmp(tls->renegotiation_info.client_verify_data,
+				buf + 1, tx_vdl) &&
+			!memcmp(tls->renegotiation_info.server_verify_data,
+				buf + 1 + tx_vdl, rx_vdl);
+	}
+
+	/*
+	 * RFC 5746 Section 3.4: "The client MUST then verify that the length
+	 * of the "renegotiated_connection" field is zero, ..."
+	 */
+	if (len < 1 || buf[0] != 0x00)
+		return false;
+
+	tls->renegotiation_info.secure_renegotiation = true;
+	return true;
+}
+
+static bool tls_renegotiation_info_absent(struct l_tls *tls)
+{
+	/*
+	 * RFC 5746 Section 4.2: "It is possible that un-upgraded servers
+	 * will request that the client renegotiate.  It is RECOMMENDED
+	 * that clients refuse this renegotiation request." and Section 4.4:
+	 * "It is RECOMMENDED that servers not permit legacy renegotiation."
+	 *
+	 * This may need to be made configurable, for now follow the
+	 * recommendation and don't renegotiate.
+	 */
+	if (tls->ready)
+		return false;
+
+	/*
+	 * The normal policy otherwise is that the extension must be
+	 * present in renegotation if the previous Client or Server Hello
+	 * did include this extension, or the SCSV in the Client Hello case.
+	 */
+	return !tls->ready || !tls->renegotiation_info.secure_renegotiation;
+}
+
 const struct tls_hello_extension tls_extensions[] = {
 	{
 		"Supported Groups", "elliptic_curves", 10,
@@ -873,6 +997,15 @@ const struct tls_hello_extension tls_extensions[] = {
 		tls_signature_algorithms_client_absent,
 		NULL, NULL, NULL,
 	},
+	{
+		"Secure Renegotiation", "renegotiation_info", 0xff01,
+		tls_renegotiation_info_client_write,
+		tls_renegotiation_info_client_handle,
+		tls_renegotiation_info_absent,
+		tls_renegotiation_info_server_write,
+		tls_renegotiation_info_server_handle,
+		tls_renegotiation_info_absent,
+	},
 	{}
 };
 
diff --git a/ell/tls-private.h b/ell/tls-private.h
index a3a9393..6a9bd29 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -267,6 +267,13 @@ struct l_tls {
 	uint8_t session_compression_method_id;
 	char *session_peer_identity;
 
+	struct {
+		bool secure_renegotiation;
+		/* Max .verify_data_length over supported cipher suites */
+		uint8_t client_verify_data[12];
+		uint8_t server_verify_data[12];
+	} renegotiation_info;
+
 	/* SecurityParameters current and pending */
 
 	struct {
@@ -341,6 +348,8 @@ void tls_generate_master_secret(struct l_tls *tls,
 				const uint8_t *pre_master_secret,
 				int pre_master_secret_len);
 
+size_t tls_verify_data_length(struct l_tls *tls, unsigned int index);
+
 const struct tls_named_group *tls_find_group(uint16_t id);
 const struct tls_named_group *tls_find_ff_group(const uint8_t *prime,
 						size_t prime_len,
diff --git a/ell/tls.c b/ell/tls.c
index 14c8550..2a8d509 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -1234,6 +1234,7 @@ void tls_disconnect(struct l_tls *tls, enum l_tls_alert_desc desc,
 
 	tls->negotiated_version = 0;
 	tls->ready = false;
+	tls->renegotiation_info.secure_renegotiation = false;
 
 	if (forget_session) {
 		tls_forget_cached_session(tls, NULL, tls->session_id,
@@ -1749,7 +1750,7 @@ static void tls_send_change_cipher_spec(struct l_tls *tls)
 	tls_tx_record(tls, TLS_CT_CHANGE_CIPHER_SPEC, &buf, 1);
 }
 
-static size_t tls_verify_data_length(struct l_tls *tls, unsigned int index)
+size_t tls_verify_data_length(struct l_tls *tls, unsigned int index)
 {
 	/*
 	 * RFC 5246, Section 7.4.9:
@@ -1762,7 +1763,34 @@ static size_t tls_verify_data_length(struct l_tls *tls, unsigned int index)
 	return maxsize(tls->cipher_suite[index]->verify_data_length, 12);
 }
 
-static void tls_send_finished(struct l_tls *tls)
+static bool tls_save_verify_data(struct l_tls *tls, bool txrx,
+					const uint8_t *vd, size_t vdl)
+{
+	uint8_t *buf;
+
+	if (tls->server == txrx) {
+		if (vdl > sizeof(tls->renegotiation_info.server_verify_data))
+			goto error;
+
+		buf = tls->renegotiation_info.server_verify_data;
+	} else {
+		if (vdl > sizeof(tls->renegotiation_info.client_verify_data))
+			goto error;
+
+		buf = tls->renegotiation_info.client_verify_data;
+	}
+
+	memcpy(buf, vd, vdl);
+	return true;
+
+error:
+	TLS_DISCONNECT(TLS_ALERT_INTERNAL_ERROR, 0,
+			"tls->renegotiation_info.*verify too small for %s, "
+			"report an ell bug", tls->cipher_suite[txrx]->name);
+	return false;
+}
+
+static bool tls_send_finished(struct l_tls *tls)
 {
 	uint8_t buf[512];
 	uint8_t *ptr = buf + TLS_HANDSHAKE_HEADER_SIZE;
@@ -1785,9 +1813,14 @@ static void tls_send_finished(struct l_tls *tls)
 				"client finished",
 				seed, seed_len,
 				ptr, vdl);
+
+	if (!tls_save_verify_data(tls, 1, ptr, vdl))
+		return false;
+
 	ptr += vdl;
 
 	tls_tx_handshake(tls, TLS_FINISHED, buf, ptr - buf);
+	return true;
 }
 
 static bool tls_verify_finished(struct l_tls *tls, const uint8_t *received,
@@ -1830,6 +1863,9 @@ static bool tls_verify_finished(struct l_tls *tls, const uint8_t *received,
 		return false;
 	}
 
+	if (!tls_save_verify_data(tls, 0, received, vdl))
+		return false;
+
 	return true;
 }
 
@@ -1992,6 +2028,10 @@ static void tls_server_resume_error(struct l_tls *tls)
 	l_free(l_steal_ptr(tls->session_peer_identity));
 }
 
+/* RFC 5746 */
+static const uint8_t tls_empty_renegotiation_info_scsv[2] = { 0x00, 0xff };
+static const uint16_t tls_renegotiation_info_id = 0xff01;
+
 static void tls_handle_client_hello(struct l_tls *tls,
 					const uint8_t *buf, size_t len)
 {
@@ -2100,6 +2140,30 @@ static void tls_handle_client_hello(struct l_tls *tls,
 		goto cleanup;
 	}
 
+	if (!tls->renegotiation_info.secure_renegotiation || tls->ready) {
+		for (i = 0; i < cipher_suites_size; i += 2)
+			if (l_get_be16(cipher_suites + i) == l_get_be16(
+					tls_empty_renegotiation_info_scsv))
+				break;
+
+		if (i < cipher_suites_size) {
+			if (unlikely(tls->ready)) {
+				TLS_DISCONNECT(TLS_ALERT_ILLEGAL_PARAM, 0,
+						"Empty renegotiation_info in "
+						"renegotiation Client Hello");
+				goto cleanup;
+			}
+
+			/*
+			 * RFC 5746 Section 3.6, act as if we had received an
+			 * empty renegotiation_info extension.
+			 */
+			tls->renegotiation_info.secure_renegotiation = true;
+			l_queue_push_tail(extensions_offered, L_UINT_TO_PTR(
+						tls_renegotiation_info_id));
+		}
+	}
+
 	/* Select a cipher suite according to client's preference list */
 	while (cipher_suites_size) {
 		struct tls_cipher_suite *suite =
@@ -2243,7 +2307,9 @@ static void tls_handle_client_hello(struct l_tls *tls,
 			return;
 		}
 
-		tls_send_finished(tls);
+		if (!tls_send_finished(tls))
+			return;
+
 		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 		return;
 	}
@@ -2721,7 +2787,8 @@ static void tls_handle_server_hello_done(struct l_tls *tls,
 		return;
 	}
 
-	tls_send_finished(tls);
+	if (!tls_send_finished(tls))
+		return;
 
 	TLS_SET_STATE(TLS_HANDSHAKE_WAIT_CHANGE_CIPHER_SPEC);
 }
@@ -3222,7 +3289,9 @@ static void tls_handle_handshake(struct l_tls *tls, int type,
 						error);
 				break;
 			}
-			tls_send_finished(tls);
+
+			if (!tls_send_finished(tls))
+				break;
 		}
 
 		/*
-- 
2.34.1

