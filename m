Received: from mail-pj1-f46.google.com (mail-pj1-f46.google.com [209.85.216.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F0B60A48B
	for <ell@lists.linux.dev>; Fri, 18 Nov 2022 21:16:43 +0000 (UTC)
Received: by mail-pj1-f46.google.com with SMTP id q1-20020a17090a750100b002139ec1e999so6220187pjk.1
        for <ell@lists.linux.dev>; Fri, 18 Nov 2022 13:16:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=noSpRLIm8x9UjqoiqGwbEMBQch6vT/oyXTLlibiFOys=;
        b=YIVFLqBP3mgqcYZzpkJYr9j7+cBhxvIz8Q4vYwtalfl+qJdjo8eu5c27Jw9/i9C6Md
         D6pANUix2SCl3wUt7gdy6AwUqJ7RPcTbrCuU0q9Sh2T2DsdrrsT4nu4tshFxOkUwwBQZ
         ftrG2tp/zqXMhlqyCBLUBn3lm63ww6nhYQC/DP1VIVhATre18H5SAMVLwved1BmtynKC
         xxzvj82AO/TRTSDC3MNfhCCHnHkLWhIInvs0qLJwVBmzJeArHN4neuq+5UIvrIMn053T
         RR7tHKT4R/nKNYG6n0b5XSxefROLZaW/psMw+Py/b2gHG8RHPcjntRPCgQceswoBdHds
         mHOQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=noSpRLIm8x9UjqoiqGwbEMBQch6vT/oyXTLlibiFOys=;
        b=ZzHkeBTGCD4y4FNY4Sap/ZR68Ti0Z2xmXk/TfKA+lHp2D+I4P7TeTqPVVN+C/erVN+
         Za0FHuhmjBdHfcLmhGQjhvCD3zSneeQe7QR4ViuAJiEgZ388PB3Ny5lArs0uifEclGhq
         //GT+STt1MBVkM1JKEcF4+ngn8CXC4ogG+K3qZ9XojUfCYx+mIh4CJZZk37i5E1jgurR
         /HIRWjGNsN7fvBOKVPT39Ogoa76eTP2hSj98V/5kmHJKZ16W5oRy7V7CjjECkPutNOn3
         xNuDoaV2Xkwh8msRgrDlej0vkk4Y7iDUrE+LlvogxvTx81WIUdLszMRXxNXhRA59OqKD
         Qy5Q==
X-Gm-Message-State: ANoB5pm2sLSMKEvvpetSg5+Jt4KxlpuidMeWkT3x2qWPOMoxTOqFstjm
	+81pIumCV5LtkDGd1IqRFvn+rT5ViaI=
X-Google-Smtp-Source: AA0mqf7r/Fv17O+32rHxw7a872vtHC7ha/tFqKGgelQD9q8V8wYRosf7rnqs3L69+XJFHnffhqr+Pg==
X-Received: by 2002:a17:902:da84:b0:185:3ecb:d464 with SMTP id j4-20020a170902da8400b001853ecbd464mr1297333plx.78.1668806203294;
        Fri, 18 Nov 2022 13:16:43 -0800 (PST)
Received: from jprestwo-xps.none ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id y12-20020aa79aec000000b0056ee49d6e95sm3630142pfp.86.2022.11.18.13.16.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Nov 2022 13:16:43 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [RFC 7/8] cert: add explicit length to l_cert_pkcs5_pbkdf2
Date: Fri, 18 Nov 2022 13:16:23 -0800
Message-Id: <20221118211624.19298-8-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.3
In-Reply-To: <20221118211624.19298-1-prestwoj@gmail.com>
References: <20221118211624.19298-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Rather than assume the password/key is a NULL terminated string pass
the length in too. This is more flexible in case of a binary key.
---
 ell/cert-crypto.c | 7 ++++---
 ell/cert.h        | 1 +
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
index 42f602e..ec14c04 100644
--- a/ell/cert-crypto.c
+++ b/ell/cert-crypto.c
@@ -175,7 +175,7 @@ static bool cert_pkcs5_pbkdf2(struct l_checksum *checksum, const uint8_t *salt,
 
 /* RFC8018 section 5.2 */
 LIB_EXPORT bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type,
-					const char *password,
+					const char *password, size_t pass_len,
 					const uint8_t *salt, size_t salt_len,
 					unsigned int iter_count,
 					uint8_t *out_dk, size_t dk_len)
@@ -188,7 +188,7 @@ LIB_EXPORT bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type,
 	if (!h_len)
 		return false;
 
-	checksum = l_checksum_new_hmac(type, password, strlen(password));
+	checksum = l_checksum_new_hmac(type, password, pass_len);
 	if (!checksum)
 		return false;
 
@@ -648,7 +648,8 @@ static struct l_cipher *cipher_from_pkcs5_pbes2_params(
 
 	/* RFC8018 section 6.2 */
 
-	if (!l_cert_pkcs5_pbkdf2(prf_alg, password, salt, salt_len, iter_count,
+	if (!l_cert_pkcs5_pbkdf2(prf_alg, password, strlen(password), salt,
+					salt_len, iter_count,
 					derived_key, key_len))
 		return NULL;
 
diff --git a/ell/cert.h b/ell/cert.h
index ce430fa..8ad57b6 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -73,6 +73,7 @@ bool l_cert_pkcs5_pbkdf1(enum l_checksum_type type, const char *password,
 				unsigned int iter_count,
 				uint8_t *out_dk, size_t dk_len);
 bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type, const char *password,
+				size_t pass_len,
 				const uint8_t *salt, size_t salt_len,
 				unsigned int iter_count,
 				uint8_t *out_dk, size_t dk_len);
-- 
2.34.3

