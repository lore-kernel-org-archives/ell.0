Received: from mail-ot1-f51.google.com (mail-ot1-f51.google.com [209.85.210.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1367829A5
	for <ell@lists.linux.dev>; Fri, 26 Jul 2024 16:12:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722010356; cv=none; b=Y06la8+1LaKUswHmT9OZQ2wqPxuO5JxHz8JhORiUh9dSzcq00aRzfaeJYhmSyso2/xKlTS4j2ghZ9qeunE9HSEmT7yIacwB/obhbOvvXs1VuiIwYt6P4ST8gxhLDq+lX5HjccrRooyfgna+iy1QJQ3XI6Xf89pc2vcVvtG5IlrU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722010356; c=relaxed/simple;
	bh=ASW8Oiawmb6X/F32LpMEy2Un7XoWwFaJyR/LvbxS1j4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=DGyMfmlu1mwej4uR3H2iKQi1/lPJBqomgM4sQJDs+R/AUxT+VP36c0aGVD72KevOPcoFwVri9TPjQTm+g04wSoasEybnFNa53oVwuAzffujSJq8qBiaWtPhGrciL8TMET0KylOYgKWDnLX1dZn1bXTHjQG1+X82wr9NBpztPx0g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=KcxCFRv2; arc=none smtp.client-ip=209.85.210.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KcxCFRv2"
Received: by mail-ot1-f51.google.com with SMTP id 46e09a7af769-7093705c708so1101629a34.1
        for <ell@lists.linux.dev>; Fri, 26 Jul 2024 09:12:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722010354; x=1722615154; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=qHAh5ly47GWdHNN0RH2ogz2zlpMBhuZ/VAG+zQXtU1M=;
        b=KcxCFRv20MHWy7a2Qs3PjK/vcHIka3xeb4g9djQY0pJqP2e+jLP42V6t72RTrMVf9B
         eW0kJaw7O7jI2z837Yrv5X3f+i8ztfA/fQhqHpAw+Z7xLQhB4TungTJGMYL8+dYo3M/f
         n2EsFbItOrnrchlaFK1QerPHXXhPpJD386PvBVmfye4a7sgSm8FIQtnvBbFy4Ye8XUio
         OOAZ6pA1R/b45jtBEV6EtwSF3lOJfLJxjxjc9fxuq047Uc9m7wap3/ZLd7ZQ2/vDFZw9
         Bzm6Mx+AlnmCRSKDnGw3CR/o/Fw2Nlas18V1mgGZj08WhMWceCV6yhsm/DvQ95yaO9zD
         ZVCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722010354; x=1722615154;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=qHAh5ly47GWdHNN0RH2ogz2zlpMBhuZ/VAG+zQXtU1M=;
        b=bTYiFVKsqfnzybPOCAx5JsBlRbuJ4ZGsg809SH8L0JNQYWmJ7qintkckoW7mA/Oil+
         aWbemfVkxB1NWjE+JyrpELyogB1xv6i7vVasCWEuBplwI71r4cRJzi7BGigSKQaxSidi
         Gkfm5KRQAbCKlHUiFzdMETvKm/u7Ur3CTRwAEINYmwlh7D7lghTFSwA9vICN1AeC7Cn3
         MHVl3jfVX8ljPTu95wmREl8XHOpfxaxGI778tHLmWWRLTLNBS+OPO9pZBGf3cVZv7oxn
         sjbiEd33dNwiK55qh/BcY9RUyhCS6xb6QfaWurxJ5cOjcot6X76j45c+lYrI93qcCYF1
         xizQ==
X-Gm-Message-State: AOJu0YwgYl9p81rPhWpDp7uZqkd/TbjyT4UxNNNIplx29mPkhPtb5QWG
	syweGGFHNds3KEia3gtfQmBW/rHFUfdGE4KrM41dboHTz3GojdKr5HMX/g==
X-Google-Smtp-Source: AGHT+IHzJb9FLOTkgfwTG5BOiP7Acp2bM864K1D614+hy4oTTmkfXXk8n7VWB71C04vrUO0yxNwcfw==
X-Received: by 2002:a9d:4d87:0:b0:709:3772:8c31 with SMTP id 46e09a7af769-70940c71118mr46142a34.31.1722010354005;
        Fri, 26 Jul 2024 09:12:34 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-70930718ec9sm792997a34.30.2024.07.26.09.12.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 26 Jul 2024 09:12:33 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/7] netlink: Remove pointless checks
Date: Fri, 26 Jul 2024 11:12:13 -0500
Message-ID: <20240726161232.146982-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

command_queue, command_pending and command_lookup structures are always
initialized at construction time and are not destroyed until l_netlink
destruction.  There's no need to check whether they ar valid.
---
 ell/netlink.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/ell/netlink.c b/ell/netlink.c
index 024740b62fc3..26c31679e4c7 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -410,10 +410,6 @@ LIB_EXPORT unsigned int l_netlink_send(struct l_netlink *netlink,
 	if (unlikely(!netlink))
 		return 0;
 
-	if (!netlink->command_queue || !netlink->command_pending ||
-						!netlink->command_lookup)
-		return 0;
-
 	if (flags & 0xff)
 		return 0;
 
@@ -471,10 +467,6 @@ LIB_EXPORT bool l_netlink_cancel(struct l_netlink *netlink, unsigned int id)
 	if (unlikely(!netlink || !id))
 		return false;
 
-	if (!netlink->command_queue || !netlink->command_pending ||
-						!netlink->command_lookup)
-		return false;
-
 	command = l_hashmap_remove(netlink->command_lookup, L_UINT_TO_PTR(id));
 	if (!command)
 		return false;
-- 
2.45.2

