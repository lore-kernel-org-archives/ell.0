Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B1A24A35
	for <ell@lists.linux.dev>; Fri,  7 Oct 2022 18:02:37 +0000 (UTC)
Received: by mail-wr1-f47.google.com with SMTP id a3so8441242wrt.0
        for <ell@lists.linux.dev>; Fri, 07 Oct 2022 11:02:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=z5ThAi79LDcZYaqfvRsU6YuxtuA3g8+/uq2xvgcY+NI=;
        b=yOgQV5DIlsk6DhEd8jEcltQwti/p9mys0IDPFtE14y+9W+v9XkUMFY+2EIv9xO8WlH
         bPKRragoGGJgtMyfWhSYdu5cZq4tCdmSNUse7acpXuxJ4cpoPk82NpVS9nhIEMtZ0to9
         usDpoR0Nkp9aKUaRDI3p6RnKbZGoEIsMPoEfdWk3Ulm7C1IIvhv66gKLZacJ8T1BpjLF
         cb/88firOpNGY2cnS6hEn7+mtOA7NCCh7Xo5Kbe6WTAvoqJ6purYJ1y8i0s7G2ZzjvCi
         Xz86yzxrYTP9oq3KTZUL30j+Jmcj5U6YQ+bMJvukPOwNI8OFl7HwkPPWjhDQixMfFtGZ
         F91g==
X-Gm-Message-State: ACrzQf1W3cOtm5q+grjX+ZdPbUsDpjWc3r0fVy/rjotIYUdWOueUWKfb
	CT9TK1NL3vUPqLVk04r1Z4QpHchNmzY=
X-Google-Smtp-Source: AMsMyM4WdOehKlIvkU9YeHkBlVFpWxjoPgATNrCMzODS+FtugfOg7u/KaO72qgI2JpXUhh79HtZlLw==
X-Received: by 2002:a5d:530b:0:b0:22e:3e8c:45aa with SMTP id e11-20020a5d530b000000b0022e3e8c45aamr4382593wrv.321.1665165755350;
        Fri, 07 Oct 2022 11:02:35 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id m14-20020adff38e000000b0022c906ffedasm2477078wro.70.2022.10.07.11.02.30
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 07 Oct 2022 11:02:32 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/2] dhcp: Simplify check in BPF filter
Date: Fri,  7 Oct 2022 20:02:09 +0200
Message-Id: <20221007180209.1069526-2-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221007180209.1069526-1-andrew.zaborowski@intel.com>
References: <20221007180209.1069526-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Instead of separately loading and testing the low 4 bits and the high 4
bits of the IP Version+Header length byte in the DHCP frame, test both
in one operation.  The filter can be further shortened but with some
loss of readability.
---
 ell/dhcp-transport.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index c4cf0ca..41b582d 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -389,18 +389,8 @@ static int kernel_raw_socket_open(uint32_t ifindex, uint16_t port, uint32_t xid)
 		BPF_STMT(BPF_RET + BPF_K, 0),
 		/* A <- IP version + Header length */
 		BPF_STMT(BPF_LD + BPF_B + BPF_ABS, 0),
-		/* A <- A & 0xf0 (Mask off version */
-		BPF_STMT(BPF_ALU + BPF_AND + BPF_K, 0xf0),
-		/* A == IPVERSION (shifted left 4) ? */
-		BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K, IPVERSION << 4, 1, 0),
-		/* ignore */
-		BPF_STMT(BPF_RET + BPF_K, 0),
-		/* A <- IP version + Header length */
-		BPF_STMT(BPF_LD + BPF_B + BPF_ABS, 0),
-		/* A <- A & 0x0f (Mask off IP Header Length */
-		BPF_STMT(BPF_ALU + BPF_AND + BPF_K, 0x0f),
-		/* A == 5 ? */
-		BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K, 5, 1, 0),
+		/* IP version == IPVERSION && Header length == 5 ? */
+		BPF_JUMP(BPF_JMP + BPF_JEQ + BPF_K, (IPVERSION << 4) | 5, 1, 0),
 		/* ignore */
 		BPF_STMT(BPF_RET + BPF_K, 0),
 		/* A <- IP protocol */
-- 
2.34.1

