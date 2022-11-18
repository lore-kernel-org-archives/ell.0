Received: from mail-pj1-f54.google.com (mail-pj1-f54.google.com [209.85.216.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5759BA48C
	for <ell@lists.linux.dev>; Fri, 18 Nov 2022 21:16:43 +0000 (UTC)
Received: by mail-pj1-f54.google.com with SMTP id w15-20020a17090a380f00b0021873113cb4so5768032pjb.0
        for <ell@lists.linux.dev>; Fri, 18 Nov 2022 13:16:43 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=31QRjXSAHfA4ORht9KleG0HRgqsjkQiBmzqp/g3m96w=;
        b=hCuc2DKwpQAUYTQOT0CayuFw8MGWoLNAVnHtesHapH5Xlggm+DdRip7INx/GxgkA+5
         c2/RcHW+yB1XrK2J3kJe8DXETo1VEMft5k7FHmUDBj1caF0HokWnvPRBDhslj0+PTcJ0
         4JlroM/7uOL8ZiCTiFxJLBYadzrLmgZBqvHGRnwmYMWc7TeYiobcqRav7tnYZlMI6HiE
         bKxoVO923oiWfBbgm4STwZx1xde0aqGOxpti79+7i3Nqzd3bENWkel5G6buIAwI9Tfg8
         0/m2nElVOG/xq3y9qMtplkjK/25NP9opSsATCxnksKdLcxa8WQ2hqxB86DGD92gtPx1Y
         Ky7A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=31QRjXSAHfA4ORht9KleG0HRgqsjkQiBmzqp/g3m96w=;
        b=l5aloQfTaA+jNEG4RlMu4px1EAI7qDO/Z0tI1uZsVnbLmYXdfXEA8+qUw8ew50cp9l
         te5pN8ihJXcb1qH1o6iPjElMyc5S6Wrslhb5d9UR6J64zXod6AdCmLjuag5BjHG88MvW
         gS83hibAW5r3IYi7sE0VZaIBrSl1eKvaNusP5nB2mpDtu2GMYPkRbLEeYWnjkrexJwUZ
         tZb7FYu6peUyUdMCb6GtlEiwQkGY3vmHhfKa845w+aI2TrPTtGxgaB5LV02ukF3qkY4D
         UW8eXSF+HwoW7o3zQmw6Uw3ps18ewv1eubhl7HPKYUlR9xoWqh1H1ujOrzq93GWySbAp
         OMig==
X-Gm-Message-State: ANoB5plIqsWerYDAD6dRigNG+Ps5o18w3JydpWtrid3gd8RZagBUO9LY
	DPSM4K7volMl2cQzWlppTCaGfgzTQ8o=
X-Google-Smtp-Source: AA0mqf7SEAPv/MMTOF1QVi+5hYd9uDCb20Pnd1K56o7iE5kwB818SX6bHccL4A8M22VJP0GOqGTiDA==
X-Received: by 2002:a17:902:ca8d:b0:186:7db1:d294 with SMTP id v13-20020a170902ca8d00b001867db1d294mr1351783pld.68.1668806202747;
        Fri, 18 Nov 2022 13:16:42 -0800 (PST)
Received: from jprestwo-xps.none ([50.39.160.234])
        by smtp.gmail.com with ESMTPSA id y12-20020aa79aec000000b0056ee49d6e95sm3630142pfp.86.2022.11.18.13.16.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Nov 2022 13:16:42 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [RFC 6/8] cert: add l_cert_pkcs5_pbkdf2_from_key_id
Date: Fri, 18 Nov 2022 13:16:22 -0800
Message-Id: <20221118211624.19298-7-prestwoj@gmail.com>
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

The same pbkdf2 algorithm but uses a key ID as the password.
---
 ell/cert-crypto.c | 27 +++++++++++++++++++++++++++
 ell/cert.h        |  6 +++++-
 ell/ell.sym       |  1 +
 3 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/ell/cert-crypto.c b/ell/cert-crypto.c
index bf748b0..42f602e 100644
--- a/ell/cert-crypto.c
+++ b/ell/cert-crypto.c
@@ -200,6 +200,33 @@ LIB_EXPORT bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type,
 	return r;
 }
 
+LIB_EXPORT bool l_cert_pkcs5_pbkdf2_from_key_id(enum l_checksum_type type,
+						int32_t key_id,
+						const uint8_t *salt,
+						size_t salt_len,
+						unsigned int iter_count,
+						uint8_t *out_dk, size_t dk_len)
+{
+	size_t h_len;
+	struct l_checksum *checksum;
+	bool r;
+
+	h_len = cert_checksum_to_length(type);
+	if (!h_len)
+		return false;
+
+	checksum = l_checksum_new_hmac_from_key_id(type, key_id);
+	if (!checksum)
+		return false;
+
+	r = cert_pkcs5_pbkdf2(checksum, salt, salt_len, h_len, iter_count,
+				out_dk, dk_len);
+
+	l_checksum_free(checksum);
+
+	return r;
+}
+
 /* RFC7292 Appendix B */
 uint8_t *cert_pkcs12_pbkdf(const char *password,
 				const struct cert_pkcs12_hash *hash,
diff --git a/ell/cert.h b/ell/cert.h
index f637588..ce430fa 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -76,7 +76,11 @@ bool l_cert_pkcs5_pbkdf2(enum l_checksum_type type, const char *password,
 				const uint8_t *salt, size_t salt_len,
 				unsigned int iter_count,
 				uint8_t *out_dk, size_t dk_len);
-
+bool l_cert_pkcs5_pbkdf2_from_key_id(enum l_checksum_type type,
+					int32_t key_id, const uint8_t *salt,
+					size_t salt_len,
+					unsigned int iter_count,
+					uint8_t *out_dk, size_t dk_len);
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.sym b/ell/ell.sym
index 08252b8..2572989 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -565,6 +565,7 @@ global:
 	l_cert_load_container_file;
 	l_cert_pkcs5_pbkdf1;
 	l_cert_pkcs5_pbkdf2;
+	l_cert_pkcs5_pbkdf2_from_key_id;
 	/* ecc */
 	l_ecc_supported_ike_groups;
 	l_ecc_supported_tls_groups;
-- 
2.34.3

