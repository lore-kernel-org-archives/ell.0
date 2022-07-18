Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com [209.85.160.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 766EA33DE
	for <ell@lists.linux.dev>; Mon, 18 Jul 2022 18:07:14 +0000 (UTC)
Received: by mail-oa1-f50.google.com with SMTP id 586e51a60fabf-10c0430e27dso25869121fac.4
        for <ell@lists.linux.dev>; Mon, 18 Jul 2022 11:07:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=P8es6darHQSIrKvCc3RqVOFWWjrBgz6LjZJJi9XhwmQ=;
        b=Qp6TSvyXgvbr3mdTOrD9objpPcgNU7tOkKs5pJ0ZIpNCkpNHDDnno4PTEt0RArCL6d
         FsDHHefTXewFdF5i2w+0WzFMyoq9C6Th3NU1iocQg54VDVNSQPHTFtDlwFhZ7x61QP+j
         QTwO26wzxRxBJ3b5o5WOsk2kDUD9E7octw33D4+BYfghQsE9CUpWtCSRMKPdXo1yWwtr
         6KlNvjzNaXds4kmFTq1OI7IhktkbmFMqxenBOJlPfmUq+BbiKMdqQ9JU4AjCHHxc0u38
         8XsZmX8NDh4D2nSpAMpPuPOAMo8GvxLNPhMaLXfias92EIFjPeJ5EiHQKMoSMo5r7RBC
         nSGw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=P8es6darHQSIrKvCc3RqVOFWWjrBgz6LjZJJi9XhwmQ=;
        b=3cJxsaUoncQYd0sEm/F0TqdKZIRxoHPIB4SptvBhbeYhuAQL2tb//iK+HRCCygpmPe
         gBNguaAPPq4AoKOoCOPK7vMJpzKpKYwK1Q6J/a0SsbEGZjSohwG1V+pHhFSHLyDuFNDt
         SiFIE42hdEtriV/a/wsn++M7S9lss3MQbLeL8fDTACyXayGqaahF95Yapo0qIa4V5g7+
         z5tQDQn/Hi4aJZJwjc7G6hgA1e30w16apWvk9WopaudWYhyN6Taw+32vpnGf8rIo5P7R
         f2/a8MrhRLX56nP0aO/I20rTBXnlqiol4rJbh/7/GAUVauBvrnpkkZglFwdegupxeftu
         QFDA==
X-Gm-Message-State: AJIora9QcfKC3dI/uibArMaDoliOUEbLOEOC6z0uK6pRzSZN5qlTBV4N
	fZ6Oh9lrzPS9OHDLdIa/FmlYv+9pBOU=
X-Google-Smtp-Source: AGRyM1tr3gjrLlhOy4Eel4VMfVbum6IIHtKUdMU177I8POox1LAnOlhncOa2Wu1d37qkR/fCAGFxgQ==
X-Received: by 2002:a54:4105:0:b0:33a:3de4:3316 with SMTP id l5-20020a544105000000b0033a3de43316mr9827830oic.145.1658167633455;
        Mon, 18 Jul 2022 11:07:13 -0700 (PDT)
Received: from localhost.localdomain (216.106.68.145.reverse.socket.net. [216.106.68.145])
        by smtp.gmail.com with ESMTPSA id n23-20020a056870559700b0010c727a3c79sm6808467oao.26.2022.07.18.11.07.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 18 Jul 2022 11:07:13 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 06/10] tls: Add helper to find hash function by id
Date: Mon, 18 Jul 2022 13:00:41 -0500
Message-Id: <20220718180045.5845-6-denkenz@gmail.com>
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

Instead of open-coding a loop to map the hash id from
SignatureAndHashAlgorithm structure to a supported hash function.
---
 ell/tls-suites.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/ell/tls-suites.c b/ell/tls-suites.c
index d5d2ec8f741f..bc6a756422b3 100644
--- a/ell/tls-suites.c
+++ b/ell/tls-suites.c
@@ -47,6 +47,17 @@ enum signature_algorithm {
 	SIGNATURE_ALGORITHM_ECDSA = 3,
 };
 
+static enum handshake_hash_type find_hash_by_id(uint8_t id)
+{
+	enum handshake_hash_type hash;
+
+	for (hash = 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
+		if (tls_handshake_hash_data[hash].tls_id == id)
+			break;
+
+	return hash;
+}
+
 /*
  * Sanitize DigitallySigned struct input, making sure the lengths
  * are valid and correspond to what we expect.
@@ -182,11 +193,7 @@ static bool tls_rsa_verify(struct l_tls *tls, const uint8_t *in, size_t in_len,
 	}
 
 	if (tls->negotiated_version >= L_TLS_V12) {
-		enum handshake_hash_type hash;
-
-		for (hash = 0; hash < __HANDSHAKE_HASH_COUNT; hash++)
-			if (tls_handshake_hash_data[hash].tls_id == in[0])
-				break;
+		enum handshake_hash_type hash = find_hash_by_id(in[0]);
 
 		if (hash == __HANDSHAKE_HASH_COUNT) {
 			TLS_DISCONNECT(TLS_ALERT_DECRYPT_ERROR, 0,
-- 
2.35.1

