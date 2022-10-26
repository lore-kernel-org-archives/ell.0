Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 324821374
	for <ell@lists.linux.dev>; Wed, 26 Oct 2022 13:16:11 +0000 (UTC)
Received: by mail-wr1-f48.google.com with SMTP id v1so26253371wrt.11
        for <ell@lists.linux.dev>; Wed, 26 Oct 2022 06:16:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=2vpkRb4tBAOLWpqjQSO7elJhPPYkoNXrzJ3CPJYah7I=;
        b=HL1SmlhE96Hex7sTMC3yCJYAGe+NZG8xvB46Xq3SnjkVq6o1ReDCp9yeOkvEggeN1N
         wDKGlEcNWu19Xs3vuth4eX6iHQpQ8P6A5CaGgOAyqKjCX6DoypMjsheVNa6HDlOPxMc8
         lDlNUtCVlDiY8LFUkJvdFZ8GKC/vq+y/iG7Opu3nslZPtPdpsInTDDMkcMO4PRO7hlfl
         xrvSfxU+eyU0vI/kAP/ETkCeORx0GuDvLzA6RfDsF7X6J0Y2ytdeLY7kUUqZeaXq4IVO
         2/WHqlIX4lH0DAObhEfgyIuo71Utsb6Zo+vI4Pm9XKAy5jGvOH39D6fpXNq+z/FogTwB
         2mXQ==
X-Gm-Message-State: ACrzQf115ZpLrOhTQup4RTIm6ajpOteg7xx6QLiGqcBIvhqF9dqXr05j
	aU6+Xllk7lQwD28qAnt0Dp/FMhYEiso=
X-Google-Smtp-Source: AMsMyM7Db+4BFDAkI4+kjBWGtzBNqKlStmdQh6ghMAzS8DG7XhChubI87zDZmr9H46GPUeR80W0acw==
X-Received: by 2002:a05:6000:1052:b0:236:6e8e:8403 with SMTP id c18-20020a056000105200b002366e8e8403mr11966019wrx.178.1666790168582;
        Wed, 26 Oct 2022 06:16:08 -0700 (PDT)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id x23-20020a05600c21d700b003a83ca67f73sm1934771wmj.3.2022.10.26.06.16.07
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 26 Oct 2022 06:16:07 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/6] time: Add time_realtime_now
Date: Wed, 26 Oct 2022 15:15:53 +0200
Message-Id: <20221026131558.2393488-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/time-private.h | 1 +
 ell/time.c         | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/ell/time-private.h b/ell/time-private.h
index 83c23dd..e107503 100644
--- a/ell/time-private.h
+++ b/ell/time-private.h
@@ -24,3 +24,4 @@ uint64_t _time_pick_interval_secs(uint32_t min_secs, uint32_t max_secs);
 uint64_t _time_fuzz_msecs(uint64_t ms);
 uint64_t _time_fuzz_secs(uint32_t secs, uint32_t max_offset);
 uint64_t _time_realtime_to_boottime(const struct timeval *ts);
+uint64_t time_realtime_now(void);
diff --git a/ell/time.c b/ell/time.c
index 41e5725..2eac6c4 100644
--- a/ell/time.c
+++ b/ell/time.c
@@ -58,6 +58,14 @@ LIB_EXPORT uint64_t l_time_now(void)
 	return _time_from_timespec(&now);
 }
 
+uint64_t time_realtime_now(void)
+{
+	struct timespec now;
+
+	clock_gettime(CLOCK_REALTIME, &now);
+	return _time_from_timespec(&now);
+}
+
 /**
  * l_time_after
  *
-- 
2.34.1

