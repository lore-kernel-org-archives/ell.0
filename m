Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com [209.85.221.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 62C3A23AD
	for <ell@lists.linux.dev>; Sun, 17 Nov 2024 00:18:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731802709; cv=none; b=JwQ5Q5MGcDEE8MuZBTODwyrOiaWiA3vXJ21iSU1/LjT3/EIiiVazJ7NmdfUWYNMF9PHmDImxc/qGAtszJKdO+PU2Mej0CxtwYADARTK5+kIlssJSo1SvNFTWjlQM5iMUjzV/j4Z0hTEAZpo7A4DmDQoktkZ0I10PFcEZvZw8XX0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731802709; c=relaxed/simple;
	bh=U8DLua6anqV8E/w4GKAvhQBIU61SH5TpOR6c2dKggLM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=bcx6lw562sZlXwgHG59+ygiTauL01L9NaTle7tMLDrZ5zuEvBkPsGaDjJLLSZ3VS3Pz8EU03e0blM2iQ72BqFx6cN1D0TJJ45laNigC40bQ63jSe2Gzqafxuhr+zDer9uKLTdYtsgfPtsHiacw1GkiT8ELlNBFu0R3JBAjPBHaM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=RfabsiwD; arc=none smtp.client-ip=209.85.221.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RfabsiwD"
Received: by mail-wr1-f41.google.com with SMTP id ffacd0b85a97d-3823cae4be1so425651f8f.3
        for <ell@lists.linux.dev>; Sat, 16 Nov 2024 16:18:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1731802706; x=1732407506; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=gHAZXxDkM9wkQuJM13tdvIAHznsexaLn0Zv9nH84Vks=;
        b=RfabsiwDuOWcADBScO7dbpc7FLnpDayOC5l5T+aWGG/ZWiPmpHgk/gK2RkI5dDtuhp
         C0Y0Jm4P+KvXf8xsHiD0vuXxCTOu84iXHlo6L6yBr+DPxm3a30TJ8KEkJg6+imNRE9PA
         N2mvzs3MhJ9gDou6mrTabrA0AGADePr2DqP5yjWCaRRaHT2hQPIk3ak5/5sPfjvRLdPI
         IkcdfA7t+dY5VjDIB9jm0rxaUo+Aaddm3bRqlNHc1yz5Pxlsq7i3ePNPp7CwksuyV+Ar
         x3aOqGGuTvF+Lj35RV3lDu6i8rZg8UriZnBMKV2sDja3soSb1rRRZ7fP+r5ZNvhXc71u
         q1Rw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1731802706; x=1732407506;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=gHAZXxDkM9wkQuJM13tdvIAHznsexaLn0Zv9nH84Vks=;
        b=VEj9KuANp6/KcZkjFc//ZtVvxrRqmqpdbHGb5HYT1ymrtGpZGqbWF8etf2ZLq4RqH+
         sTQDGpZ9+reeOa5/BDwR5GErbD1ZiIDpEcIFoQ2gQ16+SuwxGkHZATCl7N5lsewm/RWt
         E2X0fJv+32IPfnGbRTnjklCjhrfoYmcX5ITgw/SvYCXVR5PIHqOtdBfKlePExFD6K+ix
         lgd6zHJaIyiXb+B9sgjNOu8ozLobzVbbVyaksghI809gLSJtFhZpZw7jYHMoc3OdyqQw
         9DaD9hCyHFWcIhml1Qi0kSBjK1UAXZwwc3hmsS2Lz3VDBcghGBTJjZNq+JjUag8NoOSw
         9G3Q==
X-Gm-Message-State: AOJu0YwBM2m+BL/BoTuH2M0W1lnjFbP7qpoczd1+BnBPKxiItXU2PHGh
	qUxWM0J86zmLsv3FVaIl0WKmF3EmHGiUDSHnNsfQ6fDD2hcU5o2T
X-Google-Smtp-Source: AGHT+IH9tbJ5yDwxdJX3zTIjHXnGPJBg8xsORO1mFfcCSWEmgrwBkqCAcEKtYdRZwGKmSsN/2wgQ7w==
X-Received: by 2002:a5d:6482:0:b0:37d:501f:483f with SMTP id ffacd0b85a97d-38225acd40bmr5609900f8f.44.1731802705632;
        Sat, 16 Nov 2024 16:18:25 -0800 (PST)
Received: from nz.home ([2a00:23c8:a613:101:729c:d1ff:fe4f:94a3])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-3824259dda3sm357041f8f.77.2024.11.16.16.18.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 16 Nov 2024 16:18:24 -0800 (PST)
Received: by nz.home (Postfix, from userid 1000)
	id 3E6F524A077F14; Sun, 17 Nov 2024 00:18:23 +0000 (GMT)
From: Sergei Trofimovich <slyich@gmail.com>
To: ell@lists.linux.dev
Cc: Sergei Trofimovich <slyich@gmail.com>
Subject: [PATCH 1/4] settings: fix -std=c23 build failure
Date: Sun, 17 Nov 2024 00:18:11 +0000
Message-ID: <20241117001814.2149181-1-slyich@gmail.com>
X-Mailer: git-send-email 2.47.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

gcc-15 switched to -std=c23 by default:

    https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;h=55e3bd376b2214e200fa76d12b67ff259b06c212

As a result `ell` fails the build as:

    ell/settings.c: In function 'l_settings_get_embedded_value':
    ell/settings.c:1521:24: error: incompatible types when returning type '_Bool' but 'const char *' was expected
     1521 |                 return false;
          |                        ^~~~~

The change uses poiter instead of a bool to return the zero value.
---
 ell/settings.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/settings.c b/ell/settings.c
index a5f17d1..b46d00b 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -1518,7 +1518,7 @@ LIB_EXPORT const char *l_settings_get_embedded_value(
 	struct embedded_group_data *group;
 
 	if (unlikely(!settings))
-		return false;
+		return NULL;
 
 	group = l_queue_find(settings->embedded_groups,
 					embedded_group_match, group_name);
-- 
2.47.0

