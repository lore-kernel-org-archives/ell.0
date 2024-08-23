Received: from mail-oo1-f47.google.com (mail-oo1-f47.google.com [209.85.161.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADB6018BC2B
	for <ell@lists.linux.dev>; Fri, 23 Aug 2024 16:15:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724429760; cv=none; b=pY3MMvde/YrlpknRxIAKaoFklGmYe+vHLXmu5Yvo03CqmyAEoyEKEjMlWPDbs1bCPd9Kh+ZzEJZYz0ak2THM4V51mZW32ksKl5Ney4aau0vg9PYFSD8mUaiRhqdmZj4oYrwtjcx76iH6I8J/N7RWSRpq00TAVFGfZvG0p5ShOuI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724429760; c=relaxed/simple;
	bh=S2f4P1wGYdCEeQHUgjA11esFgqPd0ov/6ItqVytAk58=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gVr8LlPimA4/KIMU52iEAZ4ASgEL4cmGfUYKsQuWXoDJqeCkciashmwN8716r0ZIqPdgD+Ivu1fybs8h2qvp6bvbrBrrqtmn2/NpLlIMSisE1QWeBzNsSHwfm57ETicgfgLwcdvlZZ1JSRNHWGmOOOJHTK2AThu3Xl7Y0RfaPrI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=lJu3OVDg; arc=none smtp.client-ip=209.85.161.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lJu3OVDg"
Received: by mail-oo1-f47.google.com with SMTP id 006d021491bc7-5d5f9d68805so1489823eaf.3
        for <ell@lists.linux.dev>; Fri, 23 Aug 2024 09:15:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724429757; x=1725034557; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=4w7wyimAVYwCR9+Zgwizb3qWELx/lJyhNxXQhOkG29k=;
        b=lJu3OVDgpdBD/Nl2QdiLbReO+bo0pYlQTWHSbUorHq9hy2q/D78JcBLFnUU3Vlzw4H
         TCH2zZynwTODSeOKlUXCY9g/iKNujMUm6TD0QkETkyriJTNKKhM2ZZqwgSuB11z9WdK3
         BFBDLCtD032ACT3HbxY2qu+ydqinfFl6zvTAT09TvG7mdQduwnmdDVjLNRQf80QSQqea
         3/kpJ1nyrWxz+8h2dMf9Fgnjtll3+LoEkW74cpCvhL3zd/uHQmaqnGmYrlH+LnwvpE8A
         SMw+WbbYm4Bskm7V9ciBHcJM1Vfd/sTSgJxKyidYddQvy+QP7FVoqi/TlIQWOA/kKnVn
         VOTg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724429757; x=1725034557;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=4w7wyimAVYwCR9+Zgwizb3qWELx/lJyhNxXQhOkG29k=;
        b=ZY4ObfL4DKvdnhQ+7JHl+RhzzUm8unMZoBiZdq57eg1Gw/LgqI68m6BgQgagHWdDbm
         +3zPqYfW56l3YzPpGglAvMw7cfQnY1FXiIGh4l8nfhE92PrVZQ9cugbDNLMuIzUcVypV
         J8D4xQplt0DNSDOBYyyTObbcZxOnsmbO144YgSTixDrW+kA/YpQ1vbFXcXDLprlhk0ai
         6FLIZfGvrsnAj/5eLrCK0shzfVa6U/U/jVubbxfp/QsYdyxoNEhx5QtGKbC0m6OQuxS7
         6PQSvz/cSgKv7cd23WThG+rnxluNkPzavjudkU6y+xr7b7pnu9h/UDYg+TD1DyLRix9Z
         iTAg==
X-Gm-Message-State: AOJu0YzxeqrfEf1BDL7sGAqtDZzeZcTfJhxrZXGxjQeeFmAU4Gk9S5S3
	0NO0Ep8n95vnoPJBH7dJ56HmXABr8DPZq3P12RkZeLfMOrPjXCOSecDdyw==
X-Google-Smtp-Source: AGHT+IEpPDoFycGWvYGu5/WNDmHMjtrz0+ooomdX4bdTJSxR8NcnR1sTv/L9TYINqrAMZH3dz0Y8Xw==
X-Received: by 2002:a05:6820:1e12:b0:5da:b554:b84c with SMTP id 006d021491bc7-5dcc625d655mr2490614eaf.5.1724429757459;
        Fri, 23 Aug 2024 09:15:57 -0700 (PDT)
Received: from archdev.attlocal.net (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5dcb5de7c83sm750222eaf.14.2024.08.23.09.15.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 23 Aug 2024 09:15:57 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 4/6] netlink: Add l_netlink_request_sent
Date: Fri, 23 Aug 2024 11:15:48 -0500
Message-ID: <20240823161553.479576-4-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240823161553.479576-1-denkenz@gmail.com>
References: <20240823161553.479576-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This is similar to l_genl_family_request_sent()
---
 ell/ell.sym   |  1 +
 ell/netlink.c | 18 ++++++++++++++++++
 ell/netlink.h |  1 +
 3 files changed, 20 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 1499081cb25e..cbeb61ff0f46 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -431,6 +431,7 @@ global:
 	l_netlink_destroy;
 	l_netlink_send;
 	l_netlink_cancel;
+	l_netlink_request_sent;
 	l_netlink_register;
 	l_netlink_unregister;
 	l_netlink_set_debug;
diff --git a/ell/netlink.c b/ell/netlink.c
index 0be3009c736f..7e6ef0f760e7 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -467,6 +467,24 @@ LIB_EXPORT bool l_netlink_cancel(struct l_netlink *netlink, unsigned int id)
 	return true;
 }
 
+LIB_EXPORT bool l_netlink_request_sent(struct l_netlink *netlink,
+							unsigned int id)
+{
+	struct command *command;
+	struct nlmsghdr *hdr;
+
+	if (unlikely(!netlink || !id))
+		return false;
+
+	command = l_hashmap_lookup(netlink->command_lookup, L_UINT_TO_PTR(id));
+	if (!command)
+		return false;
+
+	hdr = command->message->hdr;
+	return l_hashmap_lookup(netlink->command_pending,
+					L_UINT_TO_PTR(hdr->nlmsg_seq));
+}
+
 static bool add_membership(struct l_netlink *netlink, uint32_t group)
 {
 	int sk, value = group;
diff --git a/ell/netlink.h b/ell/netlink.h
index b51748195ca6..368f38619155 100644
--- a/ell/netlink.h
+++ b/ell/netlink.h
@@ -37,6 +37,7 @@ unsigned int l_netlink_send(struct l_netlink *netlink,
 				void *user_data,
 				l_netlink_destroy_func_t destroy);
 bool l_netlink_cancel(struct l_netlink *netlink, unsigned int id);
+bool l_netlink_request_sent(struct l_netlink *netlink, unsigned int id);
 
 unsigned int l_netlink_register(struct l_netlink *netlink,
 			uint32_t group, l_netlink_notify_func_t function,
-- 
2.45.2

