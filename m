Received: from mail-ot1-f46.google.com (mail-ot1-f46.google.com [209.85.210.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A35AC1CAA6
	for <ell@lists.linux.dev>; Fri, 31 May 2024 21:24:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717190653; cv=none; b=J8RcLU8CCnS3PF4LftRkQWtG05IG0aB2zJZw8mAH4wKTqzsA1UyoRrDbeGh0M18lUX0qpMT1Y7DBi+uV6JKHT34Ci0JsQcDGJ/L9AG9t+b+WIldg4g63A24bLcpJrn01Phh5DXDSxpK2YT/sCe9H82YWKHBUhAQtBfRfLOlafR8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717190653; c=relaxed/simple;
	bh=FNby+LfJDqWCWRmINe6WPUbg5K6BSzEXXVj+jtOkhRM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=C6/Bd6I3hK2NweWIw2otHBAB7ZbKPnz6/4lrxKR8lzID1cMyk9Kc1XaukE6OIPw3HbyilOauhsH+pGk5QucF+DIXOnocC2Y9V4AJnPvR+bjNABF0oS65uK3iH1MxXhntsJyvOqLGlynGNyfHyEEQpWaiZq5RjKefu4b1g18Sjkw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=DOIg0Zql; arc=none smtp.client-ip=209.85.210.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DOIg0Zql"
Received: by mail-ot1-f46.google.com with SMTP id 46e09a7af769-6f8e9d4dff3so1620903a34.0
        for <ell@lists.linux.dev>; Fri, 31 May 2024 14:24:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1717190650; x=1717795450; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=6OrN6vYOOU100zAhE0ees9jLxnt04LFtvK7HXvtwLx8=;
        b=DOIg0ZqlKdfdquAeCNPQSHlkwElDykJLLcQoHsUCzXS94sGfMozYjyefGuTSmISzKW
         yk6se/AUX1PXi01kiZHYV2skDw9MECC+CDNNUcAluMkMkJEhb+Jdu5KS5fgWCg8Cripo
         /8bP/5btPxLu3OXGCQ5HIP+tlcRksKDJryBhNJrSI2kCzZ8DNjP0H6sQlCvOabYcaYMe
         +EojJ74fn7H2soscPzkhtRDNRHr88xg4HTv9qn2X/hgvzG1+QLj8FCCNTQdMHlfxh3Ij
         gJfXpWNAMciPksF1qHW2o1vHjj82LQwoO6knaf0WgZse5sQMc6bD8nHvxiiwSwTHgPO3
         Lzkw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1717190650; x=1717795450;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=6OrN6vYOOU100zAhE0ees9jLxnt04LFtvK7HXvtwLx8=;
        b=LF5Gn5nPmBHpIAsBGszO9RpO+DD3e+GsC+E3pujm2T+P5lg/aJ64YuMrIm3kMpLsoG
         ggI+TtKLFqGfnrP3cBP4fK7p0eNmv9Odq/32yMZKPbH5Ld4E7ocbKwib+PqRS5rPP/Og
         2DmnAwcPSLRJhAImAg8baRYEkl8+h2yDiTWTVJ7uidNCDH9R55Jdk2PUM2yX0UYkeLoq
         F7L0L8NtBE2xClz3/96hccfNmKRYAVdosNxICzt2kIphdKNIy7nXNfz9QW/ZKu4skb2Y
         P5mBxpgbqus4Ljbt3sI5ddlm0Iy32yUlpplYDE4T6nkruztsktrJet6EKTncrXQTTNtH
         lQXA==
X-Gm-Message-State: AOJu0Yz1vhC+XXm+qUnEqQIcBawBs8sTaKiwI1FNFBfeEOCrexU7hQ4u
	IQkJXTqeEz9/04tuSE0H15I5D/tYxe01V1K/K2FiY7/Bl8D++VgdZww2Ew==
X-Google-Smtp-Source: AGHT+IG5zLi1CCXrA369zCER/Vf50Ht2R7n8sjcC7GazdDXVFveVGpjHXNAoVCrmielZ+u4JVTpY/w==
X-Received: by 2002:a05:6870:9109:b0:23c:ffe8:a80c with SMTP id 586e51a60fabf-2508c04916amr3530082fac.52.1717190650495;
        Fri, 31 May 2024 14:24:10 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-250853be999sm738902fac.51.2024.05.31.14.24.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 31 May 2024 14:24:10 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH] genl: re-implement unicast_watch using l_notifylist
Date: Fri, 31 May 2024 16:23:59 -0500
Message-ID: <20240531212408.738767-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/genl.c | 122 ++++++++++++++++++-----------------------------------
 1 file changed, 40 insertions(+), 82 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index 33ecc4d41256..c6c863ebf88d 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -20,6 +20,7 @@
 #include "io.h"
 #include "private.h"
 #include "netlink-private.h"
+#include "notifylist.h"
 #include "genl.h"
 
 #define MAX_NESTING_LEVEL 4
@@ -33,11 +34,9 @@ struct nest_info {
 };
 
 struct unicast_watch {
-	uint32_t id;
+	struct l_notifylist_entry super;
 	char name[GENL_NAMSIZ];
 	l_genl_msg_func_t handler;
-	void *user_data;
-	l_genl_destroy_func_t destroy;
 };
 
 struct family_watch {
@@ -69,7 +68,7 @@ struct l_genl {
 	unsigned int next_notify_id;
 	struct genl_discovery *discovery;
 	uint32_t next_watch_id;
-	struct l_queue *unicast_watches;
+	struct l_notifylist *unicast_watches;
 	struct l_queue *family_watches;
 	struct l_queue *family_infos;
 	struct l_genl_family *nlctrl;
@@ -449,32 +448,38 @@ LIB_EXPORT uint32_t l_genl_family_info_get_version(
 	return info->version;
 }
 
-static void unicast_watch_free(void *data)
+static void unicast_watch_free(struct l_notifylist_entry *e)
 {
-	struct unicast_watch *watch = data;
-
-	if (watch->destroy)
-		watch->destroy(watch->user_data);
-
+	struct unicast_watch *watch =
+			l_container_of(e, struct unicast_watch, super);
 	l_free(watch);
 }
 
-static bool unicast_watch_match(const void *a, const void *b)
+static void unicast_watch_notify(const struct l_notifylist_entry *e,
+						int type, va_list args)
 {
-	const struct unicast_watch *watch = a;
-	uint32_t id = L_PTR_TO_UINT(b);
+	struct unicast_watch *watch =
+			l_container_of(e, struct unicast_watch, super);
 
-	return watch->id == id;
+	if (!watch->handler)
+		return;
+
+	watch->handler(va_arg(args, struct l_genl_msg *),
+			watch->super.notify_data);
 }
 
-static void unicast_watch_prune(struct l_genl *genl)
+static struct l_notifylist_ops unicast_watch_ops = {
+	.free_entry = unicast_watch_free,
+	.notify = unicast_watch_notify,
+};
+
+static bool unicast_watch_match_name(const struct l_notifylist_entry *e,
+					const void *user)
 {
-	struct unicast_watch *watch;
+	struct unicast_watch *watch =
+			l_container_of(e, struct unicast_watch, super);
 
-	while ((watch = l_queue_remove_if(genl->unicast_watches,
-						unicast_watch_match,
-						L_UINT_TO_PTR(0))))
-		unicast_watch_free(watch);
+	return !strncmp(watch->name, user, GENL_NAMSIZ);
 }
 
 static void family_watch_free(void *data)
@@ -870,39 +875,6 @@ static bool match_request_seq(const void *a, const void *b)
 	return request->seq == seq;
 }
 
-static void dispatch_unicast_watches(struct l_genl *genl, uint16_t id,
-							struct l_genl_msg *msg)
-{
-	const struct l_queue_entry *entry;
-	struct l_genl_family_info *info = l_queue_find(genl->family_infos,
-							family_info_match,
-							L_UINT_TO_PTR(id));
-
-	if (!info)
-		return;
-
-	genl->in_unicast_watch_notify = true;
-
-	for (entry = l_queue_get_entries(genl->unicast_watches);
-						entry; entry = entry->next) {
-		struct unicast_watch *watch = entry->data;
-
-		if (!watch->id)
-			continue;
-
-		if (!watch->handler)
-			continue;
-
-		if (strncmp(watch->name, info->name, GENL_NAMSIZ))
-			continue;
-
-		watch->handler(msg, watch->user_data);
-	}
-
-	genl->in_unicast_watch_notify = false;
-	unicast_watch_prune(genl);
-}
-
 static void process_unicast(struct l_genl *genl, const struct nlmsghdr *nlmsg)
 {
 	struct l_genl_msg *msg;
@@ -914,8 +886,15 @@ static void process_unicast(struct l_genl *genl, const struct nlmsghdr *nlmsg)
 
 	msg = msg_create(nlmsg);
 	if (!nlmsg->nlmsg_seq) {
-		if (msg)
-			dispatch_unicast_watches(genl, nlmsg->nlmsg_type, msg);
+		struct l_genl_family_info *info =
+			l_queue_find(genl->family_infos, family_info_match,
+					L_UINT_TO_PTR(nlmsg->nlmsg_type));
+
+		if (info && msg)
+			l_notifylist_notify_matches(genl->unicast_watches,
+						unicast_watch_match_name,
+						info->name, 0, msg);
+
 		goto done;
 	}
 
@@ -1107,7 +1086,7 @@ LIB_EXPORT struct l_genl *l_genl_new(void)
 	genl->notify_list = l_queue_new();
 	genl->family_watches = l_queue_new();
 	genl->family_infos = l_queue_new();
-	genl->unicast_watches = l_queue_new();
+	genl->unicast_watches = l_notifylist_new(&unicast_watch_ops);
 
 	l_queue_push_head(genl->family_infos, build_nlctrl_info());
 
@@ -1150,7 +1129,7 @@ LIB_EXPORT void l_genl_unref(struct l_genl *genl)
 
 	l_genl_family_free(genl->nlctrl);
 
-	l_queue_destroy(genl->unicast_watches, unicast_watch_free);
+	l_notifylist_free(genl->unicast_watches);
 	l_queue_destroy(genl->family_watches, family_watch_free);
 	l_queue_destroy(genl->family_infos, family_info_free);
 	l_queue_destroy(genl->notify_list, mcast_notify_free);
@@ -1285,12 +1264,10 @@ LIB_EXPORT unsigned int l_genl_add_unicast_watch(struct l_genl *genl,
 	watch = l_new(struct unicast_watch, 1);
 	l_strlcpy(watch->name, family, GENL_NAMSIZ);
 	watch->handler = handler;
-	watch->destroy = destroy;
-	watch->user_data = user_data;
-	watch->id = get_next_id(&genl->next_watch_id);
-	l_queue_push_tail(genl->unicast_watches, watch);
+	watch->super.destroy = destroy;
+	watch->super.notify_data = user_data;
 
-	return watch->id;
+	return l_notifylist_add(genl->unicast_watches, &watch->super);
 }
 
 /**
@@ -1306,29 +1283,10 @@ LIB_EXPORT unsigned int l_genl_add_unicast_watch(struct l_genl *genl,
 LIB_EXPORT bool l_genl_remove_unicast_watch(struct l_genl *genl,
 							unsigned int id)
 {
-	struct unicast_watch *watch;
-
 	if (unlikely(!genl))
 		return false;
 
-	if (genl->in_unicast_watch_notify) {
-		watch = l_queue_find(genl->unicast_watches, unicast_watch_match,
-							L_UINT_TO_PTR(id));
-		if (!watch)
-			return false;
-
-		watch->id = 0;
-		return true;
-	}
-
-	watch = l_queue_remove_if(genl->unicast_watches, unicast_watch_match,
-							L_UINT_TO_PTR(id));
-	if (!watch)
-		return false;
-
-	unicast_watch_free(watch);
-
-	return true;
+	return l_notifylist_remove(genl->unicast_watches, id);
 }
 
 /**
-- 
2.45.0

