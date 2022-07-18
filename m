Received: from mail-oa1-f51.google.com (mail-oa1-f51.google.com [209.85.160.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4718433CC
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 18:07:11 +0000 (UTC)
Received: by mail-oa1-f51.google.com with SMTP id 586e51a60fabf-10c0052da61so25823756fac.12
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 11:07:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=KVl4FR/UvUMnUD+PgXmBC9MO7CbdSnwg0TP7pYIG/8M=;
        b=hwhBv7F1KcW+O+HiNC/F71pZNztq0HsbibDOSR1u5QozkBOcp2nnK/uIg2Kxig+yG3
         Wgk6LIJEZqjslv74+M114QgMc3bnv4o1ifydUzy+Xo30XVz6Qm32qNAPYFi1SpFp0Xni
         mQmayqwsCEMX1Yg6Niq7RkDH39PYQQ6UWrnN8r6xKu8u1r0+TrdvsMABrfRepix5JQFc
         Pt3nlyD0RUyt0V2rQ77iWctW9m1RlC2jQQnLtxMyF4ej8ZPHl1YmvfkmN8TIKM/KeDyw
         JVHGCO2t5adaPunl8/ldo3RFfMIHiHPS5L5WnfP5lShijPzKPCvkbqZ8UQz2lxazrew2
         k6fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=KVl4FR/UvUMnUD+PgXmBC9MO7CbdSnwg0TP7pYIG/8M=;
        b=PncmTqUod247LY7MzX5VJxtPU9AQJFuydUIw6NBCXgypg9Ni3OHePoqxSlNYxHK5wD
         zVnjptmbFdzx+/5HlGausk8e2ueepRwxk/YduQCL0kU2GvzaEzGt3dZoNC5a2873obJe
         dy8rF8VKh8eYA0AwhfSVaTlg7V1TdSm158KvzLKy79NFfTOIZ9ozI3WcaWm0BWWGhd7p
         q84YFi1AWyzMkYBWYW/amdL5J/ZUL2Lwip1YF2kLJVvf8cMfOMkUIFHuuV88CsvfE51D
         +i1/cpalBzey0EgGt6Ml/QHK56M6D0u9KNLOl5c3NgAngnPD2IzOFXnsp6HRAfvHpfS0
         IxhA==
X-Gm-Message-State: AJIora8tpGbH7Wo9RZ6qsIJui6jRkBc7MEngvH6aB163TqL8aF8BrQd4
	jQLW99c1n537yR3jfAQdYWyYKaGEA4E=
X-Google-Smtp-Source: AGRyM1szlAGxp7E73GXhkbixMJPJByzArS+3aLBYnjFzIdYa3tdb8QgBGdn3QCiKF4/QWjpugYGjpg==
X-Received: by 2002:a05:6870:e248:b0:10d:215d:1b41 with SMTP id d8-20020a056870e24800b0010d215d1b41mr7936823oac.179.1658167629704;
        Mon, 18 Jul 2022 11:07:09 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id n23-20020a056870559700b0010c727a3c79sm6808467oao.26.2022.07.18.11.07.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 11:07:09 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 01/10] cert/key: Add support for EC based certificates
Date: Mon, 18 Jul 2022 13:00:36 -0500
Message-Id: <20220718180045.5845-1-denkenz@gmail.com>
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

