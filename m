Received: from mail-oi1-f182.google.com (mail-oi1-f182.google.com [209.85.167.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1607216F83D
	for <ell@lists.linux.dev>; Fri, 31 May 2024 15:08:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1717168138; cv=none; b=MS7H00nazR23FxU/pS+ekC6PpYwwiA7sPmT4IGMVfnFTJhcKQ6GoIOkExBUtKr3oe7gCgH4kbhCwOv2+LtOktVv4f/o6/LbnDesZwQo5GEhkCWreoG4qc+i4ImvVCf94gXjjLo/OWEU23ebI7hkxzn3E84iI8y1sCtymnKSEPuY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1717168138; c=relaxed/simple;
	bh=3FVLVbQUwHkM/DmayQ1aD8J1+b4/cFIDEAGIAR/q4Qc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ncvgm0pH0XAIbUnT006OcE56obFKL/5ydzFjrdgCCUn1HHlmKobCXrnx3Agy9dUoUV5GSG4kZHxc5SilheHbBBCIMw+n9WVpfgtwF857rcO6DVtEeW2+9yewhDkreCZJ1auMDiQnoUucUvNMBBQ79sxIyas9DAPWLlXHAhBOS4k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Cbhlfz/t; arc=none smtp.client-ip=209.85.167.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Cbhlfz/t"
Received: by mail-oi1-f182.google.com with SMTP id 5614622812f47-3c9c36db8eeso1134053b6e.0
        for <ell@lists.linux.dev>; Fri, 31 May 2024 08:08:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1717168136; x=1717772936; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=23I3Di8l8cfcbbbIexbmo74K3yVqX6HKpsCAx/PJReg=;
        b=Cbhlfz/tT/e2CsqZE1jB3OEBI99+lTIu9P9aCdvPaNn2aFQLAVsdYwHcRDYXlLCL8g
         z0Abd1ARmYhwdmqaPAlFfxz4GvkG19N1BgzTejmM7widqRgl5GGLMHNGmk99SQVJLzyh
         PGNh0nw771zYn+Wj5LGcIbP9465s5meWhwtNb/1pkzJ0veJNsBLFcrB2b1wdM52Ms+BK
         2Ddta7yD4XaDmAtJ9lxFVKoxrnha/4H84JtgwsYpEN/AvbHN7SinMsDbpO11XLtCh31S
         gnrOueR7elA1cqt/V2WgOetxhoahpHNMa3KhnjoFvkBVHqL3vrEfQOEfVuEHMHl+uOuC
         Y67w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1717168136; x=1717772936;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=23I3Di8l8cfcbbbIexbmo74K3yVqX6HKpsCAx/PJReg=;
        b=PbXjRS8FsLZ58b2gH6wdkxPh1naNVKU6g7pazBLwcjLOAylkzE063oK3sxfPqRpJy1
         AobIHS67Yzh3qenycjLzu5QGfOEb6lSRNCFKbssYDHResXz3r3lz67+48GhN5sqd5z37
         mYSVnwem6YG80iWqKi8BiI3PLOdL9yixbaqMXNBLMZO7sLAQZ6MfPbx2ouLqqQQva9fx
         kcLLCqgZfmkqOQhmC0v54OkLeqZPemQaU/viFOZulMLhTj9RdmKMEpKbQ19bSHmFgc9u
         B4GV+i/0fAEKLZ40rDgOM2h2rXzgmRWDzOTTtAZeokCNTDa/Que7FQ/cejoAbBjnnKxT
         VIRw==
X-Gm-Message-State: AOJu0YzTu6bIEMAmNn1mrP1XB3xjJ7wSAc64gXgbKs4VEjdlwCLXSav+
	TLbTYtfuMkEtDplMhLfBytaBJ2Z7h1T0BYV1gI4WmB9wGQNXwBfuCynjEw==
X-Google-Smtp-Source: AGHT+IFcctm2OWDAmdfNxQKtYLys+ZsqZy388Cb4d7hSJca/Qy1jXxdxXa0EZ/TF+tJjVTR0NhU5SA==
X-Received: by 2002:aca:2b14:0:b0:3c9:924c:8304 with SMTP id 5614622812f47-3d1e31eafd4mr2135800b6e.0.1717168135995;
        Fri, 31 May 2024 08:08:55 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-3d1e1a4637esm359030b6e.36.2024.05.31.08.08.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 31 May 2024 08:08:55 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 2/2] unit: Add notifylist unit tests
Date: Fri, 31 May 2024 10:08:41 -0500
Message-ID: <20240531150852.390412-2-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.0
In-Reply-To: <20240531150852.390412-1-denkenz@gmail.com>
References: <20240531150852.390412-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 Makefile.am            |   5 +-
 unit/test-notifylist.c | 206 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 210 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-notifylist.c

diff --git a/Makefile.am b/Makefile.am
index 77a6e81a9766..fc7683397b6a 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -207,7 +207,8 @@ unit_tests = unit/test-unit \
 			unit/test-path \
 			unit/test-net \
 			unit/test-sysctl \
-			unit/test-minheap
+			unit/test-minheap \
+			unit/test-notifylist
 
 dbus_tests = unit/test-hwdb \
 			unit/test-dbus \
@@ -360,6 +361,8 @@ unit_test_sysctl_LDADD = ell/libell-private.la
 
 unit_test_minheap_LDADD = ell/libell-private.la
 
+unit_test_notifylist_LDADD = ell/libell-private.la
+
 unit_test_data_files = unit/settings.test unit/dbus.conf
 
 if EXAMPLES
diff --git a/unit/test-notifylist.c b/unit/test-notifylist.c
new file mode 100644
index 000000000000..10e105d60ef9
--- /dev/null
+++ b/unit/test-notifylist.c
@@ -0,0 +1,206 @@
+/*
+ * Embedded Linux library
+ * Copyright (C) 2011-2014  Intel Corporation
+ *
+ * SPDX-License-Identifier: LGPL-2.1-or-later
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <assert.h>
+#include <ell/ell.h>
+
+enum notify_state_flags {
+	CALLED = 0x1,
+	DESTROYED = 0x02,
+};
+
+static uint32_t notify1_flags;
+static uint32_t notify2_flags;
+static uint32_t notify3_flags;
+static uint32_t notify1_id;
+static uint32_t notify2_id;
+static uint32_t notify3_id;
+static struct l_notifylist *list;
+
+struct simple_watch_entry {
+	struct l_notifylist_entry super;
+	void (*callback)(int, uint32_t *);
+};
+
+static void set_called(int arg1, uint32_t *flags)
+{
+	assert(arg1 == 42);
+	*flags |= CALLED;
+}
+
+static void destroy(void *user)
+{
+	uint32_t *flags = user;
+	*flags |= DESTROYED;
+}
+
+static void simple_notify(const struct l_notifylist_entry *e,
+						int type, va_list args)
+{
+	const struct simple_watch_entry *swe =
+		l_container_of(e, struct simple_watch_entry, super);
+	uint32_t *flags = swe->super.notify_data;
+	int arg1;
+
+	assert(type == 0);
+	arg1 = va_arg(args, int);
+
+	if (swe->callback)
+		swe->callback(arg1, flags);
+}
+
+static void simple_free_entry(struct l_notifylist_entry *e)
+{
+	struct simple_watch_entry *swe =
+		l_container_of(e, struct simple_watch_entry, super);
+
+	l_free(swe);
+}
+
+static struct l_notifylist_ops simple_ops = {
+	.free_entry = simple_free_entry,
+	.notify = simple_notify,
+};
+
+static bool id_matches(const struct l_notifylist_entry *e, const void *user)
+{
+	return e->id == L_PTR_TO_UINT(user);
+}
+
+static void make_notifylist(void (*cb)(int, uint32_t *))
+{
+	struct simple_watch_entry *swe;
+
+	list = l_notifylist_new(&simple_ops);
+
+	swe = l_new(struct simple_watch_entry, 1);
+	swe->super.notify_data = &notify1_flags;
+	swe->super.destroy = destroy;
+	swe->callback = cb;
+	notify1_id = l_notifylist_add(list, &swe->super);
+
+	swe = l_new(struct simple_watch_entry, 1);
+	swe->super.notify_data = &notify2_flags;
+	swe->super.destroy = destroy;
+	swe->callback = cb;
+	notify2_id = l_notifylist_add(list, &swe->super);
+
+	swe = l_new(struct simple_watch_entry, 1);
+	swe->super.notify_data = &notify3_flags;
+	swe->super.destroy = destroy;
+	swe->callback = cb;
+	notify3_id = l_notifylist_add(list, &swe->super);
+
+	notify1_flags = 0;
+	notify2_flags = 0;
+	notify3_flags = 0;
+}
+
+static void test_notify(const void *test_data)
+{
+	make_notifylist(set_called);
+
+	l_notifylist_notify(list, 0, 42);
+	assert(notify1_flags == CALLED);
+	assert(notify2_flags == CALLED);
+	assert(notify3_flags == CALLED);
+
+	l_notifylist_free(list);
+	assert(notify1_flags & DESTROYED);
+	assert(notify2_flags & DESTROYED);
+	assert(notify3_flags & DESTROYED);
+}
+
+static void test_notify_matches(const void *test_data)
+{
+	make_notifylist(set_called);
+
+	l_notifylist_notify_matches(list, id_matches, L_UINT_TO_PTR(notify2_id),
+					0, 42);
+	assert(!notify1_flags);
+	assert(notify2_flags == CALLED);
+	assert(!notify3_flags);
+
+	l_notifylist_free(list);
+	assert(notify1_flags & DESTROYED);
+	assert(notify2_flags & DESTROYED);
+	assert(notify3_flags & DESTROYED);
+}
+
+static void remove_second(int arg1, uint32_t *flags)
+{
+	*flags |= CALLED;
+
+	if (flags == &notify2_flags)
+		l_notifylist_remove(list, notify2_id);
+}
+
+static void test_notify_and_remove(const void *test_data)
+{
+	make_notifylist(remove_second);
+
+	l_notifylist_notify(list, 0, 42);
+	assert(notify1_flags == CALLED);
+	assert(notify2_flags == (CALLED | DESTROYED));
+	assert(notify3_flags == CALLED);
+
+	l_notifylist_free(list);
+}
+
+static void remove_third(int arg1, uint32_t *flags)
+{
+	*flags |= CALLED;
+
+	if (flags == &notify2_flags)
+		l_notifylist_remove(list, notify3_id);
+}
+
+static void test_notify_and_remove_other(const void *test_data)
+{
+	make_notifylist(remove_third);
+
+	l_notifylist_notify(list, 0, 42);
+	assert(notify1_flags == CALLED);
+	assert(notify2_flags == CALLED);
+	assert(notify3_flags == DESTROYED);
+
+	l_notifylist_free(list);
+}
+
+static void free_list(int arg1, uint32_t *flags)
+{
+	*flags |= CALLED;
+	l_notifylist_free(list);
+}
+
+static void test_notify_and_free(const void *test_data)
+{
+	make_notifylist(free_list);
+	l_notifylist_notify(list, 0, 42);
+
+	assert(notify1_flags == (CALLED | DESTROYED));
+	assert(notify2_flags == DESTROYED);
+	assert(notify3_flags == DESTROYED);
+}
+
+int main(int argc, char *argv[])
+{
+	l_test_init(&argc, &argv);
+
+	l_test_add("notifylist/notify", test_notify, NULL);
+	l_test_add("notifylist/notify_matches", test_notify_matches, NULL);
+	l_test_add("notifylist/notify_and_remove", test_notify_and_remove, NULL);
+	l_test_add("notifylist/notify_and_remove_other",
+			test_notify_and_remove_other, NULL);
+	l_test_add("notifylist/notify_and_free", test_notify_and_free, NULL);
+
+	return l_test_run();
+}
-- 
2.45.0

