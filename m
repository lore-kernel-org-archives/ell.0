Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C82055E226
	for <ell@lists.linux.dev>; Thu,  1 Feb 2024 16:20:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.53
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706804451; cv=none; b=YJ9OG53hbwL+0yl75BZg+xqjIfK7Djnu6xaG/lq+HKLIGIJ0Tkfdt1U3U4TtZh0Qar/bnHZHLIKav1phmatvSP4e4tNnUt9iIgEjkuK7/fHO2mHpy52cBAN+MB4BhajQEShM8MtDi/m6HhkROb1CnBtVCWqZ5LGjl7TKYNNv6bg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706804451; c=relaxed/simple;
	bh=qORh15RAcPBrpTQhGYzJPoFV+0SI2SoLG2r2+nljKzU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=lw3tVsTJnkE+5M4uMljpVVOvyFe8ktVSKsqhbnfB77dlLq2Jj2KxCJ/0HPn6uFbH6kfluo0qByAFcpT9GGDWe7szj26BNuXpw3hb4KEc1azL90Do6J+sc4zyFi67e8EGZP2HI6eky2rxIoDt7WoXCFTl1Ts6xIdu4hjCMlVP+JQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=je+U150v; arc=none smtp.client-ip=209.85.210.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="je+U150v"
Received: by mail-ot1-f53.google.com with SMTP id 46e09a7af769-6dc8b280155so674351a34.0
        for <ell@lists.linux.dev>; Thu, 01 Feb 2024 08:20:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1706804448; x=1707409248; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=OCJWyfSBEYz5AIMDMiZgPygJJaCVWTOeyZBDHfchIMY=;
        b=je+U150vEywp5CasTCzblISyeH2WswQsz+qEcVNIxbQDoQJ8Tf0MCyMak+Sbh/5q0b
         B3HOElEjrv27zVIXcAagYT1zcliJaM1eA0Qq9nXjKcelPmENIbZquu7aoniBbPmH0DnR
         OUvk1wIeJasDdHALFG2f6/eCtUu82KB8ONbui5hC/oLHkoy1siv/HAL/d5jYDDb9WdsT
         cHH/euyKahSUuGgKMcW9Ha5F3OuDJY+qgwfmEb3RH4bhcCgK/4jwHh2KL/UzUMQms+iE
         K7gm51tZm2xqMjMgAJOmhDRBLYEn3yWjpAjCnOs8EhjsSrCQqh30xzb2O1lD2RCD5itE
         x7Gw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1706804448; x=1707409248;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=OCJWyfSBEYz5AIMDMiZgPygJJaCVWTOeyZBDHfchIMY=;
        b=MdkcX1VQY2A85PVNn/b61YFZXGm89MXz7pAn9A0Y7B2/tTmuJCZCX1cNFx35o89OG7
         EuefvGPprdEj4Bv6X0u/3e29HOwLSzvHwe3pnLF12cux76uCgbuUHiCjEldA37I6rfvf
         COF4G5FYbS9vVzC1iTE5ZIdwcZxIZfe9Go9XxnujxpLuNDDQszoBFUw58Q7DLCFSJz7t
         0XwTS9pIJsWj4GhViKezd5NBaAM+kU0SZgtLhJ3v+JjSu2D+LW+cNjOewceW9Rh2gtIG
         XfCYG2/1NO9zQ70VRJJC/WeXnelABoDv+F5aIKZq8kQqLlbQAzNw2cr7hSfOkmQD5HY2
         c5Pw==
X-Gm-Message-State: AOJu0YyQJZ1ZcdTztrx9iqkB1wU4m3llml+ez/fBxMM+vOZ5bNChfT70
	PwopG3IRHKSC6yIS8utlGACWIUrB//cpSeQILtM76RUy2A7mUozxH9iurIlG
X-Google-Smtp-Source: AGHT+IGl1giP7mkrQx+gzgEPFwyg1XO6KAhNIlnR15Qxmn5ZHPQgXbVpwDj64QYkphdFgPCIk3nGcA==
X-Received: by 2002:a05:6870:449:b0:214:88e5:9ba3 with SMTP id i9-20020a056870044900b0021488e59ba3mr6034433oak.19.1706804448486;
        Thu, 01 Feb 2024 08:20:48 -0800 (PST)
Received: from localhost.localdomain (070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id c5-20020a05687091c500b00214aaff3632sm12249oaf.26.2024.02.01.08.20.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 01 Feb 2024 08:20:48 -0800 (PST)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [RFC PATCH] build: Move autodestruct macro definition
Date: Thu,  1 Feb 2024 10:19:46 -0600
Message-ID: <20240201162000.913015-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

_auto_ syntax is widely used by ell and iwd, however it isn't part of
the public ell API.  Currently it is defined in ell/useful.h, but this
header isn't distributed with other public ell headers.  iwd has special
hacks in its build system to enable use of useful.h, but this may not be
sustainable if multiple ell based projects would like to use this
facility.

Move the _auto_ macro definition out of useful.h and into the build
system.  Any project can thus enable the _auto_ syntax by adding a 1
liner to 'configure.ac'
---
 configure.ac | 2 ++
 ell/useful.h | 3 ---
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 0dd569570a75..8d88f1c2a022 100644
--- a/configure.ac
+++ b/configure.ac
@@ -150,4 +150,6 @@ AC_SUBST(OPENSSL_PROVIDER)
 
 AC_CONFIG_FILES(Makefile ell/ell.pc)
 
+AC_DEFINE([_auto_], [__L_AUTODESTRUCT], [autodestruct syntax])
+
 AC_OUTPUT
diff --git a/ell/useful.h b/ell/useful.h
index ab88f52556f5..a3d5ad916bd8 100644
--- a/ell/useful.h
+++ b/ell/useful.h
@@ -59,9 +59,6 @@ static inline unsigned char bit_field(const unsigned char oct,
 	_x / _d;					\
 })
 
-#define _auto_(func)					\
-	__L_AUTODESTRUCT(func)
-
 /*
  * Trick the compiler into thinking that var might be changed somehow by
  * the asm
-- 
2.43.0

