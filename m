Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B40416F82B
	for <ell@lists.linux.dev>; Fri, 31 May 2024 15:08:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717168138; cv=none; b=LOb0nfge02ykGgkjIEN6/+xTzv0iQRKq8bSoPWdRROoqQdR0/VmASJht+UeEnsqt7L0129Opwpa0WkLmcA3V7OQJo0dK1QzV7py6PJIZJNKJen3ba7X5yJRsc7WToNlbnWO5ebe8RxVtefBUOaaelzaRLzrgUyMu/pCyiqhZW4Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717168138; c=relaxed/simple;
	bh=b9sTwiIDBRgy994DHVKPoP00kN6F4XAe6tuTDdx3rpE=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fpd11YfArJRcUlrdqRS3ghwz+PALjEAqcuXRHAet3XVp+2PYma/cQkclGd+xM+nzdLCMAjNoMje4fv2Z8P4Fobaupttwuh06E/3llOoFbvCYBxCUmrj8cjKSwy16H7xYs/huRfaFguwdjxlqjnhVzqVBQ/cSFiuHAVyZc9jlIM0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=T9H0QyUv; arc=none smtp.client-ip=209.85.167.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="T9H0QyUv"
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-3c9cc681ee4so1130686b6e.0
        for <ell@lists.linux.dev>; Fri, 31 May 2024 08:08:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1717168135; x=1717772935; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=1TO/7EJHiRdzYWKTl3AhVwMZxFWUDW9PLLIC0lj6Atg=;
        b=T9H0QyUvEb+0iGadE+LsD3R0j2EdH4uvqLl3l2YEZRat+aQKRBTXSqMjOE4/4LUkwg
         slLnPzHOjsKT8HYbTcfsxj2PQb1kRVm9GAYYyPi+ZwsX/JcnN0j2I9s+jis/4vgrtM3e
         dXkQEjO0hc+yClbm98G9Auu58utGhsIKsksJDwiVVfpyJ1X9F55Z3D0/8MTS40tINlTn
         hwt4tUpnI55w5iFK6L2+JaTwKPmboCN6+C6qg1+KP0LIPbZVx+ZhxD3RflOSBE+DQmCL
         q0W586xvG92bs0FcGy/ZUrpq6ySlZHg4nwuriTOFSa+jvvtxnpoypF1QiZ+a2lzaPeDT
         P2Aw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1717168135; x=1717772935;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=1TO/7EJHiRdzYWKTl3AhVwMZxFWUDW9PLLIC0lj6Atg=;
        b=tVXKny9vNtDvAz1uinDqFl3bxF8LH7t64GA8/e8uLQR7z7MMTFKhD5s404XK7qiQpZ
         GV/dbjwQ6mN7ZWgUQV+dtSxOXUC7UEkd9ATKNxHb6x24XjBmT6uH/80WfQdTPdXlyNQ7
         OB7T/UsJpq5w/HMYcpdKw9jkI2Z+RMt3lBt8iOgwFXXsmY57bm+M2H7UPiLPWb1/GuPr
         dRy3cu2uaK60HhORiMjfOWaWbIlTnMFIjbWJ6RTI8cK5QMqIuM3MT9/g3FvbumFzGUOh
         WAzhiFT/PCwt7GyyeW26ZOAaFcxXqJOw5a8Zh8aGf11veR3cEjkoFjy8Z0AwF2SaAh2x
         +lcg==
X-Gm-Message-State: AOJu0YzA8ALxKfY3vTzaHCalb0oH03tSq7tylUBZBMNaaPrSQCQeO6wB
	5Ea+qfJHoctdHrnZU9k8ewExaTO3aaIzp1OOKPdFEEki1lMx+3ZEvNjsDA==
X-Google-Smtp-Source: AGHT+IG2giLLulks9SIka69AHQykRzamxSBZhLUf4FCGsHOjEfMyfc6FdMFUaYxsXCLI5uPB34dQOw==
X-Received: by 2002:a05:6808:1784:b0:3c9:cf09:a857 with SMTP id 5614622812f47-3d1e35c1140mr2830123b6e.47.1717168135294;
        Fri, 31 May 2024 08:08:55 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-3d1e1a4637esm359030b6e.36.2024.05.31.08.08.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 31 May 2024 08:08:54 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/2] notifylist: add notifylist class
Date: Fri, 31 May 2024 10:08:40 -0500
Message-ID: <20240531150852.390412-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

oFono and iwd projects use a 'watch' pattern to register clients for
notifications about object events, such as state changes.  This pattern
is quite common and both iwd and oFono implement utilities for
adding, removing and notifying 'watch' clients.  This can be thought of
as a primitive signal / slot framework.

Implementing 'watches' properly, including handling possible call stack
re-entrancy conditions can be tricky.  The notifylist class implements a
generic 'watch' framework and aims to be the shared implementation
for iwd, oFono and other projects.
---
 Makefile.am      |   6 +-
 ell/ell.h        |   1 +
 ell/ell.sym      |   7 ++
 ell/notifylist.c | 208 +++++++++++++++++++++++++++++++++++++++++++++++
 ell/notifylist.h |  53 ++++++++++++
 5 files changed, 273 insertions(+), 2 deletions(-)
 create mode 100644 ell/notifylist.c
 create mode 100644 ell/notifylist.h

diff --git a/Makefile.am b/Makefile.am
index 6c86e94e963e..77a6e81a9766 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -63,7 +63,8 @@ pkginclude_HEADERS = ell/ell.h \
 			ell/cleanup.h \
 			ell/netconfig.h \
 			ell/sysctl.h \
-			ell/minheap.h
+			ell/minheap.h \
+			ell/notifylist.h
 
 lib_LTLIBRARIES = ell/libell.la
 
@@ -153,7 +154,8 @@ ell_libell_la_SOURCES = $(linux_headers) \
 			ell/tester.c \
 			ell/netconfig.c \
 			ell/sysctl.c \
-			ell/minheap.c
+			ell/minheap.c \
+			ell/notifylist.c
 
 ell_libell_la_LDFLAGS = -Wl,--no-undefined \
 			-Wl,--version-script=$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ell.h b/ell/ell.h
index f67339105e8f..7a263e9376de 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -53,3 +53,4 @@
 #include <ell/netconfig.h>
 #include <ell/sysctl.h>
 #include <ell/minheap.h>
+#include <ell/notifylist.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index 803906c586e8..0587beb398bc 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -788,6 +788,13 @@ global:
 	/* sysctl */
 	l_sysctl_get_u32;
 	l_sysctl_set_u32;
+	/* notifylist */
+	l_notifylist_new;
+	l_notifylist_free;
+	l_notifylist_add;
+	l_notifylist_remove;
+	l_notifylist_notify;
+	l_notifylist_notify_matches;
 local:
 	*;
 };
diff --git a/ell/notifylist.c b/ell/notifylist.c
new file mode 100644
index 000000000000..bec251dc6196
--- /dev/null
+++ b/ell/notifylist.c
@@ -0,0 +1,208 @@
+/*
+ * Embedded Linux library
+ * Copyright (C) 2024  Cruise, LLC
+ *
+ * SPDX-License-Identifier: LGPL-2.1-or-later
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include "private.h"
+#include "queue.h"
+#include "notifylist.h"
+#include "useful.h"
+
+struct l_notifylist {
+	uint32_t next_id;
+	struct l_queue *entries;
+	bool in_notify : 1;
+	bool stale_entries : 1;
+	bool pending_destroy : 1;
+	const struct l_notifylist_ops *ops;
+};
+
+static bool __notifylist_entry_match(const void *a, const void *b)
+{
+	const struct l_notifylist_entry *entry = a;
+	uint32_t id = L_PTR_TO_UINT(b);
+
+	return entry->id == id;
+}
+
+static void __notifylist_entry_free(struct l_notifylist *list,
+						struct l_notifylist_entry *e)
+{
+	if (e->destroy)
+		e->destroy(e->notify_data);
+
+	list->ops->free_entry(e);
+}
+
+static void __notifylist_clear(struct l_notifylist *list)
+{
+	struct l_notifylist_entry *entry;
+
+	while ((entry = l_queue_pop_head(list->entries)))
+		__notifylist_entry_free(list, entry);
+}
+
+static void __notifylist_prune_stale(struct l_notifylist *list)
+{
+	struct l_notifylist_entry *e;
+
+	while ((e = l_queue_remove_if(list->entries, __notifylist_entry_match,
+							L_UINT_TO_PTR(0))))
+		__notifylist_entry_free(list, e);
+
+	list->stale_entries = false;
+}
+
+static void __notifylist_destroy(struct l_notifylist *list)
+{
+	__notifylist_clear(list);
+	l_queue_destroy(list->entries, NULL);
+	list->entries = NULL;
+
+	l_free(list);
+}
+
+static void __notifylist_notify(struct l_notifylist *list,
+				l_notifylist_entry_matches_func_t match_func,
+				const void *match_data,
+				int type, va_list args)
+{
+	const struct l_queue_entry *entry = l_queue_get_entries(list->entries);
+
+	list->in_notify = true;
+
+	for (; entry; entry = entry->next) {
+		const struct l_notifylist_entry *e = entry->data;
+		va_list copy;
+
+		if (e->id == 0)
+			continue;
+
+		if (match_func && !match_func(e, match_data))
+			continue;
+
+		va_copy(copy, args);
+		list->ops->notify(e, type, copy);
+		va_end(copy);
+
+		if (list->pending_destroy)
+			break;
+	}
+
+	list->in_notify = false;
+
+	if (list->pending_destroy)
+		__notifylist_destroy(list);
+	else if (list->stale_entries)
+		__notifylist_prune_stale(list);
+}
+
+LIB_EXPORT struct l_notifylist *l_notifylist_new(
+					const struct l_notifylist_ops *ops)
+{
+	struct l_notifylist *list = l_new(struct l_notifylist, 1);
+
+	list->entries = l_queue_new();
+	list->ops = ops;
+	list->next_id = 1;
+
+	return list;
+}
+
+LIB_EXPORT uint32_t l_notifylist_add(struct l_notifylist *list,
+					struct l_notifylist_entry *entry)
+{
+	if (!list)
+		return 0;
+
+	entry->id = list->next_id++;
+
+	if (!list->next_id)
+		list->next_id = 1;
+
+	l_queue_push_tail(list->entries, entry);
+
+	return entry->id;
+}
+
+LIB_EXPORT bool l_notifylist_remove(struct l_notifylist *list, uint32_t id)
+{
+	struct l_notifylist_entry *entry;
+
+	if (!list)
+		return false;
+
+	if (list->in_notify) {
+		entry = l_queue_find(list->entries, __notifylist_entry_match,
+							L_UINT_TO_PTR(id));
+		if (!entry)
+			return false;
+
+		entry->id = 0;	/* Mark stale */
+		list->stale_entries = true;
+
+		return true;
+	}
+
+	entry = l_queue_remove_if(list->entries, __notifylist_entry_match,
+							L_UINT_TO_PTR(id));
+	if (!entry)
+		return false;
+
+	__notifylist_entry_free(list, entry);
+
+	return true;
+}
+
+LIB_EXPORT void l_notifylist_free(struct l_notifylist *list)
+{
+	if (!list)
+		return;
+
+	if (list->in_notify) {
+		list->pending_destroy = true;
+		return;
+	}
+
+	__notifylist_destroy(list);
+}
+
+LIB_EXPORT bool l_notifylist_notify(struct l_notifylist *list,
+							int type, ...)
+{
+	va_list args;
+
+	if (!list)
+		return false;
+
+	va_start(args, type);
+	__notifylist_notify(list, NULL, NULL, type, args);
+	va_end(args);
+
+	return true;
+}
+
+LIB_EXPORT bool l_notifylist_notify_matches(struct l_notifylist *list,
+				l_notifylist_entry_matches_func_t match_func,
+				const void *match_data, int type, ...)
+{
+	va_list args;
+
+	if (!list)
+		return false;
+
+	if (!match_func)
+		return false;
+
+	va_start(args, type);
+	__notifylist_notify(list, match_func, match_data, type, args);
+	va_end(args);
+
+	return true;
+}
diff --git a/ell/notifylist.h b/ell/notifylist.h
new file mode 100644
index 000000000000..1ae54933528b
--- /dev/null
+++ b/ell/notifylist.h
@@ -0,0 +1,53 @@
+/*
+ * Embedded Linux library
+ * Copyright (C) 2024  Cruise, LLC
+ *
+ * SPDX-License-Identifier: LGPL-2.1-or-later
+ */
+
+#ifndef __ELL_NOTIFYLIST_H
+#define __ELL_NOTIFYLIST_H
+
+#include <stdint.h>
+#include <stdbool.h>
+#include <stddef.h>
+#include <stdarg.h>
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+struct l_notifylist_entry;
+
+typedef void (*l_notifylist_destroy_func_t)(void *data);
+typedef bool (*l_notifylist_entry_matches_func_t)(
+				const struct l_notifylist_entry *,
+				const void *);
+
+struct l_notifylist_entry {
+	unsigned int id;
+	void *notify_data;
+	l_notifylist_destroy_func_t destroy;
+};
+
+struct l_notifylist_ops {
+	void (*free_entry)(struct l_notifylist_entry *entry);
+	void (*notify)(const struct l_notifylist_entry *entry,
+						int type, va_list args);
+};
+
+struct l_notifylist *l_notifylist_new(const struct l_notifylist_ops *ops);
+void l_notifylist_free(struct l_notifylist *list);
+uint32_t l_notifylist_add(struct l_notifylist *list,
+					struct l_notifylist_entry *entry);
+bool l_notifylist_remove(struct l_notifylist *list, uint32_t id);
+bool l_notifylist_notify(struct l_notifylist *list, int type, ...);
+bool l_notifylist_notify_matches(struct l_notifylist *list,
+				l_notifylist_entry_matches_func_t match_func,
+				const void *match_data, int type, ...);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_NOTIFYLIST_H */
-- 
2.45.0

