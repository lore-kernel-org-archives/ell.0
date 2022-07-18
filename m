Received: from mail-oa1-f53.google.com (mail-oa1-f53.google.com [209.85.160.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6121433DF
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 18:07:12 +0000 (UTC)
Received: by mail-oa1-f53.google.com with SMTP id 586e51a60fabf-10d4691a687so10546341fac.10
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 11:07:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=kW99CkzG/sAtLGON6i1sEngEB0b9gBWe/XHcegnda2w=;
        b=amqwidALx/Dv5Ap76dgNn2IUuAhB94SS9DHMmW/7Q9w1Lj1UFnQ+9wjolgy+pJNsR9
         yteplVZrGpaaDpBdHX9j3+jgO7CHiy27uVwC3LP2G7C60rJ2EggeyP/BNG3k7Q4t2Mrf
         cGXgTTEN3upCUR2+Z0Czntfdito4I0R533ivxeTOK6YFp23S4EaqR263pbWf1TR13EwM
         0WDKbdqYxVn3Hm+iNGLeyKs6bNs66iJvZs/iWeHaq1hn3ItinS9CW6TbsjESJJMQwims
         sl5baSufcK9cEZhnD2xILfcfN/fi52ULXFEiesGKfUuMppNdEyBrVCUGZPZJ3r3lgR56
         1oYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=kW99CkzG/sAtLGON6i1sEngEB0b9gBWe/XHcegnda2w=;
        b=PnYqwAAaVeF7B5ZVAzWI6fsmevhHcyH4guvKSeIY3a2IFYd2OKK0b6DwfVBN6CAqo2
         Vk5/lLQc/rJ5PXOCgOxA1KYIsxHXrwyj+Qubygm62+A9FPmXnwACczHp+4d+h3XIRoy8
         VwJDpKPPMVKJcZrFjRNcs5NWd3CkGVSli4exfVdF5HoseDWlIfQpzzYKKYGb60idSQsi
         18dNviaiAVYLGe84Ft+jsxM263ZCezNKU82phpYusXB5Uhwr+MpWC82fGbm7r6vXbI6c
         A2Kzwby3rL8mU0VBzuApTl9B4rNTKLKsU/hLMMEYLx02Ckj/3QjZDGmG971nwsPJIz4O
         ozIQ==
X-Gm-Message-State: AJIora9m7dj9j964wcQGy9uyigdNGwqvAjWHU50EthE03rdbPB+BKYjj
	OuNjLX0kk1Ydw3Rf0R3c6HbuNwtqH5g=
X-Google-Smtp-Source: AGRyM1t/1IYmuGaeDB9zimYVRe35SF8g92IboegT9tnDmaPWUddB2gnUS7qcDu2ykuqAwkxXkiBPLg==
X-Received: by 2002:a05:6870:80ca:b0:10c:4ca:285b with SMTP id r10-20020a05687080ca00b0010c04ca285bmr17420654oab.52.1658167631264;
        Mon, 18 Jul 2022 11:07:11 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id n23-20020a056870559700b0010c727a3c79sm6808467oao.26.2022.07.18.11.07.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 11:07:10 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 03/10] key: ECDSA data is given in x962 format
Date: Mon, 18 Jul 2022 13:00:38 -0500
Message-Id: <20220718180045.5845-3-denkenz@gmail.com>
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

When using the verify operation with ECDSA based public keys, the new
format type must be used.
---
 ell/key.c | 12 +++++-------
 ell/key.h |  1 +
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/ell/key.c b/ell/key.c
index 73f38581f736..24374a5d836d 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -383,18 +383,16 @@ LIB_EXPORT ssize_t l_key_get_payload_size(struct l_key *key)
 
 static const char *lookup_cipher(enum l_key_cipher_type cipher)
 {
-	const char* ret = NULL;
-
 	switch (cipher) {
 	case L_KEY_RSA_PKCS1_V1_5:
-		ret = "pkcs1";
-		break;
+		return "pkcs1";
 	case L_KEY_RSA_RAW:
-		ret = "raw";
-		break;
+		return "raw";
+	case L_KEY_ECDSA_X962:
+		return "x962";
 	}
 
-	return ret;
+	return NULL;
 }
 
 static const char *lookup_checksum(enum l_checksum_type checksum)
diff --git a/ell/key.h b/ell/key.h
index f26f7ecb26c3..68971052ffde 100644
--- a/ell/key.h
+++ b/ell/key.h
@@ -56,6 +56,7 @@ enum l_keyring_restriction {
 enum l_key_cipher_type {
 	L_KEY_RSA_PKCS1_V1_5,
 	L_KEY_RSA_RAW,
+	L_KEY_ECDSA_X962,
 };
 
 struct l_key *l_key_new(enum l_key_type type, const void *payload,
-- 
2.35.1

