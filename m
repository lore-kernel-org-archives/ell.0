Received: from mail-oa1-f51.google.com (mail-oa1-f51.google.com [209.85.160.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DEC1320E
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 16:08:35 +0000 (UTC)
Received: by mail-oa1-f51.google.com with SMTP id 586e51a60fabf-10c0430e27dso24956886fac.4
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 09:08:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=rJlGaTt8c3u3xYzawmr81ynKoJj/T5ePwtuRsOr5Qu0=;
        b=d8RTclhwis29hL+rug7N/7WGAiaL7+3DwQx2xMF3FrteJL0a/NT9BYlYKoTpXnp7Lg
         lf0ZbGDHtyYxR5vPv0jBApzibStAlrFRYpQchSZXB91BOSY9QEK4GKN2AUQS4afGPZny
         jxjukKM5uM+/S4NliC3/g5iHBcXfoN4o1vN7tFlqowfTwK7FYmkL3Kv4MMrYsDjDhTDJ
         InsMqwIXfazw5tWfqv9Upe/YYtGNVqh/lfNETAxUTsCrYcv5YKkiKlb5GYW885rF4mjl
         rtIfj8Wj7P04KGExXJ04zYOutbOMtxrVgGmO0s5ydcihCTSdkiAlzxL/+rezpc9E8/l+
         2Oug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=rJlGaTt8c3u3xYzawmr81ynKoJj/T5ePwtuRsOr5Qu0=;
        b=AXz9LH5jZraz3Cr6JBfCyLEJ9uR7LR5260xCEaTK8XAfjH64H6gedpr/L7hv1+t3zL
         FVRqrF2dI/IAQPaAJ5hafTEHTOUtGWrcidkXR4ht2WMV18rBufPa/iUkWmmG5L8jtY1c
         2zYrM3NkwXHNyN8mwoxcMBm/WubEdEZTFOFq2JPP9SNLtwJPcvJ9P9wXKGKc9NVVtFrf
         3uwFjqrwcSvI+fEFuDVsxPwGlCcSJ471K8Cpx7l8EV1SCpEC4PxFbb+qcyvy79Kf8pGB
         ZIOUaWFpDVyYeQIA0y2T/i8Uq+Lh6lBsuGQis0lW7ZKuYAkyosVdQMW7YlIAEy0Mhjh1
         cyqQ==
X-Gm-Message-State: AJIora8ZgaegQ184KqGdRqiG0M+2q/Po29K15mWkw4bg0BN1IDun56wD
	NqsepSMS/xhYXuS2HNJzoYkOmxVhlRw=
X-Google-Smtp-Source: AGRyM1sjm0kWqokyx8CS1xbPkldBXhaHyGJ+zBsRnY1yx22xVZYzkY3BDSEl5zk6tr/kZ+xb0vZ3VQ==
X-Received: by 2002:a05:6808:1247:b0:335:2987:120c with SMTP id o7-20020a056808124700b003352987120cmr13704601oiv.142.1658160514504;
        Mon, 18 Jul 2022 09:08:34 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id t19-20020a9d5913000000b0061cae832e5dsm297941oth.3.2022.07.18.09.08.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 09:08:34 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/9] cert/key: Add support for EC based certificates
Date: Mon, 18 Jul 2022 11:02:14 -0500
Message-Id: <20220718160222.10634-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.35.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Mostly for use with Elliptic Curve (EC) Digital Signature
Algorithm (DSA) based certificates.  Other combinations of EC +
signature algorithms are also possible.

This requires your kernel to be built with CRYPTO_ECDSA support.
---

NOTE: At the time this patch was created, kernel had to be patched with
the following fix in order for ECDSA support to function properly from
userspace:
https://lore.kernel.org/linux-crypto/20220715182810.30505-1-denkenz@gmail.com/

 ell/cert.c | 18 ++++++++++++++++--
 ell/cert.h |  1 +
 ell/key.c  |  1 +
 ell/key.h  |  1 +
 4 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/ell/cert.c b/ell/cert.c
index 141ea1cec038..a158142445ec 100644
--- a/ell/cert.c
+++ b/ell/cert.c
@@ -77,7 +77,15 @@ static const struct pkcs1_encryption_oid {
 } pkcs1_encryption_oids[] = {
 	{ /* rsaEncryption */
 		L_CERT_KEY_RSA,
-		{ 9, { 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01 } },
+		{ .asn1_len = 9, .asn1 = {
+			0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01 }
+		},
+	},
+	{ /* ecPublicKey */
+		L_CERT_KEY_ECC,
+		{ .asn1_len = 7, .asn1 = {
+			0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01 }
+		},
 	},
 };
 
@@ -261,8 +269,14 @@ LIB_EXPORT struct l_key *l_cert_get_pubkey(struct l_cert *cert)
 		return NULL;
 
 	/* Use kernel's ASN.1 certificate parser to find the key data for us */
-	if (cert->pubkey_type == L_CERT_KEY_RSA)
+	switch (cert->pubkey_type) {
+	case L_CERT_KEY_RSA:
 		return l_key_new(L_KEY_RSA, cert->asn1, cert->asn1_len);
+	case L_CERT_KEY_ECC:
+		return l_key_new(L_KEY_ECC, cert->asn1, cert->asn1_len);
+	case L_CERT_KEY_UNKNOWN:
+		break;
+	}
 
 	return NULL;
 }
diff --git a/ell/cert.h b/ell/cert.h
index 605e427c3d05..f637588e6d66 100644
--- a/ell/cert.h
+++ b/ell/cert.h
@@ -36,6 +36,7 @@ struct l_certchain;
 
 enum l_cert_key_type {
 	L_CERT_KEY_RSA,
+	L_CERT_KEY_ECC,
 	L_CERT_KEY_UNKNOWN,
 };
 
diff --git a/ell/key.c b/ell/key.c
index b28bf4dbf085..73f38581f736 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -108,6 +108,7 @@ struct l_keyring {
 static const char * const key_type_names[] = {
 	[L_KEY_RAW] = "user",
 	[L_KEY_RSA] = "asymmetric",
+	[L_KEY_ECC] = "asymmetric",
 };
 
 static long kernel_add_key(const char *type, const char *description,
diff --git a/ell/key.h b/ell/key.h
index d25d09385b6f..f26f7ecb26c3 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -45,6 +45,7 @@ enum l_key_feature {
 enum l_key_type {
 	L_KEY_RAW = 0,
 	L_KEY_RSA,
+	L_KEY_ECC,
 };
 
 enum l_keyring_restriction {
-- 
2.35.1

