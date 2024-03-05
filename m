Received: from mail-pl1-f182.google.com (mail-pl1-f182.google.com [209.85.214.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41B6343AB0
	for <ell@lists.linux.dev>; Tue,  5 Mar 2024 13:28:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709645292; cv=none; b=Zu3sn4qkDT6wDz28OwAW2EtVvpJDjNi59fQPg3Z2AmcXr771jpHT8GueLY68rANsi41FgHjj7sXq6p7UgkCVV86rzXPOlHS5OMLD6ULDdHYL9Iz+l7qmKfv/GiHBSBVcPry9sgaEqeN+U72PBg/LXHieMSaaoeISQ+ja8d685N8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709645292; c=relaxed/simple;
	bh=6j98bvrjC1+NNisRDXENnTK39qGosH6ABglUJuv0NdM=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=aKQ7lOkNME1zzNKFJXiJZ4M/lcKd4CCE2Pq7mtCnAaEchHOL7tI8+IyRXSV1dAfPO7aKILn8QNfmQSJ5LURDGLa07/3VqYm781CYknOZu3nt7J8scoEjnumyFW5xImJzc2RHPJjU60X2a9obtEfU/FjLLCQm0S3xLGi8Cx+/nL8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=iQReyKDG; arc=none smtp.client-ip=209.85.214.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iQReyKDG"
Received: by mail-pl1-f182.google.com with SMTP id d9443c01a7336-1dc1ff3ba1aso42936825ad.3
        for <ell@lists.linux.dev>; Tue, 05 Mar 2024 05:28:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1709645290; x=1710250090; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=RtFV3wS5Erf96aY7Nr0XYLChlZBBHrnmq5Ei7fR5b94=;
        b=iQReyKDG+go6Q13tw+zA5u3b+9Olw67/DYR0zWbozysCi9bkV7DEBZpgc32RTrT40F
         8W8ov1SdIaZMdvAQ7RMjLg7xtYIcmTVAoBik6PZedEU5OAYxrQow2nleCwSfRhsboQol
         60gsS9dR+Lh4qi/bo6mUE1wCCSTzkGNXdxuZHTe43bYWshsv7GCapAsRN62FtJdMJnzM
         W/NPVEu6IHB1NmoT45O5t49Cl2hjahj26pmgBzlbJ8VxjKqL9oBj8V+qIKzkwh82Erb8
         3VomHT/OQN0w/oKQ+xUWzooqoKw8XXaYVZyb9jIVSdHwNZwj7va1dH5/G9jPCS8SpCeJ
         pOlA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1709645290; x=1710250090;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=RtFV3wS5Erf96aY7Nr0XYLChlZBBHrnmq5Ei7fR5b94=;
        b=RCzZ3ouGktDN2QR9xCmZ3dSoG0VlAD2TAjY/sAdzEE1UZqayZpU6AqkFHAt1OYJgrn
         PdgGBS7/JYakGmn1f9HI94cw48107yp7uWVa1fWKYNL2brqOYIigv9Okcz2GoDz/BccJ
         7GBXW3XmBZILrL3OhX88ahElVh4+gVtLboM5c/GW/50llWO7k0Zu9YqErOum++DjcC4b
         uaHNdx99tbcWMZ2S3rHkys2GDuyVU0nibWad0eMqsrfEMuPCIfdpNTiDOIx8NUIbrdb4
         Y1gAOyDK/1zuu04zZkpGQ+X8vWJHL765cVw1rPe6+bY2/nnfuGvV2a+PVvD9CWPK6Pdf
         Sawg==
X-Gm-Message-State: AOJu0Yw7xVZli37/uyJNG68O6sGZAREfj/3V8Jx8KwIww+RlMCdB8vSU
	4CE3AuOaUejWWT7aaYu44dm9fIamM0N7M/RU39QzezeJ6KZuE+6fNuk/MY4I
X-Google-Smtp-Source: AGHT+IHrLHEnr3/YhP2Y/b9X6e+TOQZpMPDa/8iHqZx6QxlOM0sf+H3t+dQDfbJTAlkDgp6JXSo17w==
X-Received: by 2002:a17:902:e544:b0:1db:7195:5fca with SMTP id n4-20020a170902e54400b001db71955fcamr2106055plf.34.1709645290219;
        Tue, 05 Mar 2024 05:28:10 -0800 (PST)
Received: from LOCLAP699.. ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id 4-20020a170902e9c400b001d7252fef6bsm10489493plk.299.2024.03.05.05.28.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 05 Mar 2024 05:28:09 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 2/5] dbus: remove unused 'type' variable
Date: Tue,  5 Mar 2024 05:28:04 -0800
Message-Id: <20240305132807.85724-2-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240305132807.85724-1-prestwoj@gmail.com>
References: <20240305132807.85724-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This was being set in the if block but never used afterwards.
---
 ell/dbus.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 532e07b..d610532 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1689,8 +1689,7 @@ LIB_EXPORT unsigned int l_dbus_add_signal_watch(struct l_dbus *dbus,
 	va_start(args, member);
 
 	rule_len = 0;
-	while ((type = va_arg(args, enum l_dbus_match_type)) !=
-			L_DBUS_MATCH_NONE)
+	while (va_arg(args, enum l_dbus_match_type) != L_DBUS_MATCH_NONE)
 		rule_len++;
 
 	va_end(args);
-- 
2.34.1

