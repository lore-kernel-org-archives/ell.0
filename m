Received: from mail-qt1-f177.google.com (mail-qt1-f177.google.com [209.85.160.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A31C26BB4B
	for <ell@lists.linux.dev>; Wed,  7 Aug 2024 17:59:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1723053591; cv=none; b=M8pAz1a/ktVRHNRuDkYKN/pqyXOBtEl1HK5SuEjMxWzeYHmx1vME5MDHstLn9v5gI/FnMAlyQ+HtaBIM6nWvIe/2Bt7l1TGaS8gE8GST7gbmUq6mAuotJu4eRCcFS06w0d1jNMHCCu7t6V4igYd6GTLr8bvJPKG0Y7ahC+uIJNk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1723053591; c=relaxed/simple;
	bh=7vth9M4EySSmW1+zWbXukfuS7HApI9Sdh2PLRS05I+I=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=tcMO2q5PXmPNFTKMGtL2GDh4IJMCw63UZ4R3adyOrZPHBkCOQry8NBWNoXwxWkm90u0KWQ7HbCsHOZx8qAbTSiLsemiaHWhkXwCx6E0KnEelQzZLGbw+TqfA6xQJN4hjC0LSd6daKPLylKCWG7OUu4cPH4Iggcymunk04bHbeVc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=IQh4dH8M; arc=none smtp.client-ip=209.85.160.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IQh4dH8M"
Received: by mail-qt1-f177.google.com with SMTP id d75a77b69052e-44ff9281e93so841071cf.2
        for <ell@lists.linux.dev>; Wed, 07 Aug 2024 10:59:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1723053588; x=1723658388; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=2O9sA3owkei6azfZ0+Cz1LMOMUxBWOus5CNl0rNHtkU=;
        b=IQh4dH8M1plNmMUzsDFDa8FiAQWANZd4wKc36V2Rm7jWYOES4q8qejv7e9W+5Lw/co
         ZZfCfUfoxmMzE2Q2Md+KtvKwShnzFwW/Q3ocQ4vfKekCqcB2AfuO7W4DsTsCY9eanBVq
         gUo5zLdJdPik0HsJONqFO2ULOy4ZLCmBbH21a11G/TkhKe9sTW8MWXS2W9AgIb6u2/KQ
         Ge/9lNPxirFsYW/gY7wfGoEk9hcy7KXbnleHOvyw0hVzpB8V7D6B1ztVf2IiafUC049F
         gSy0TXunc2rmJ3DjwvzoVGOS6RyQfkz9oq1fzjoh0T6EDVtUjzKqH8oaDbiTdhDcxQXc
         12Ug==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1723053588; x=1723658388;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=2O9sA3owkei6azfZ0+Cz1LMOMUxBWOus5CNl0rNHtkU=;
        b=HO4OUsgfxXu1WV1YWuOvgxhaxXeOBppt4H44wswr9TcC7yaXhjiKR6+3w9b0yG6IAU
         hZZmEeQcldQH2jRD3VJNUMgVavqwdiGh1z85BXBE8mUUk6g+Cwz8tYOF+qeROXs4RsME
         UPCezaUeePWjdbXG2MvyukBH1tCqmEbuxdJ9JCK45/6/E5ElKDWLPdC9+aADrKv1/fOm
         TjA5j77YUlGiy2PYDzebDI6Xe5pbernGcESnET9FJ5yEw3F/rGRGRFKY+Zrk3ReKeHNW
         jPzFQT32q0odvot7rCkESqv9GZrQ0HfhW1xF1/IecSvoHGxB6sz5JMUrFybkH76mX31i
         ojbA==
X-Gm-Message-State: AOJu0YzLL19sRuYHx/v57sbvd6FZhP9yq2dhnndnMTz6rNlLoVx16JtE
	WxYTRMSe+fvZNRzFUoRgaW08AR8nqRX0agPKt2LnQmK82lp1bRygXra8XA==
X-Google-Smtp-Source: AGHT+IHmPNWWlJeDfCMR05uyecVDAxdaraQA8k2aQwaNgimQOKpsiea34H6uaHufmhgNlM1jruDDjg==
X-Received: by 2002:a05:622a:1914:b0:450:4788:ac94 with SMTP id d75a77b69052e-45189288104mr245132391cf.16.1723053588107;
        Wed, 07 Aug 2024 10:59:48 -0700 (PDT)
Received: from LOCLAP699.localdomain ([152.193.78.90])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-451c87d95e1sm6596471cf.76.2024.08.07.10.59.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Aug 2024 10:59:47 -0700 (PDT)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/2] dbus: add _dbus_object_tree_set_interface_data
Date: Wed,  7 Aug 2024 10:59:42 -0700
Message-Id: <20240807175943.170002-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This is to prep for l_dbus_object_set_data(), i.e. modifying the
user_data of an existing dbus object.
---
 ell/dbus-private.h |  4 ++++
 ell/dbus-service.c | 33 +++++++++++++++++++++++++++++----
 2 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index fd5d099..0c06410 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -207,6 +207,10 @@ bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
 void *_dbus_object_tree_get_interface_data(struct _dbus_object_tree *tree,
 						const char *path,
 						const char *interface);
+bool _dbus_object_tree_set_interface_data(struct _dbus_object_tree *tree,
+						const char *path,
+						const char *interface,
+						void *user_data);
 
 void _dbus_object_tree_introspect(struct _dbus_object_tree *tree,
 					const char *path, struct l_string *buf);
diff --git a/ell/dbus-service.c b/ell/dbus-service.c
index d4466de..0300bfe 100644
--- a/ell/dbus-service.c
+++ b/ell/dbus-service.c
@@ -1568,25 +1568,50 @@ bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
 	return true;
 }
 
-void *_dbus_object_tree_get_interface_data(struct _dbus_object_tree *tree,
+static struct interface_instance *_dbus_object_tree_find_interface(
+						struct _dbus_object_tree *tree,
 						const char *path,
 						const char *interface)
 {
 	struct object_node *object;
-	struct interface_instance *instance;
 
 	object = l_hashmap_lookup(tree->objects, path);
 	if (!object)
 		return NULL;
 
-	instance = l_queue_find(object->instances, match_interface_instance,
-				(char *) interface);
+	return l_queue_find(object->instances, match_interface_instance,
+				interface);
+}
+
+void *_dbus_object_tree_get_interface_data(struct _dbus_object_tree *tree,
+						const char *path,
+						const char *interface)
+{
+	struct interface_instance *instance;
+
+	instance = _dbus_object_tree_find_interface(tree, path, interface);
 	if (!instance)
 		return NULL;
 
 	return instance->user_data;
 }
 
+bool _dbus_object_tree_set_interface_data(struct _dbus_object_tree *tree,
+						const char *path,
+						const char *interface,
+						void *user_data)
+{
+	struct interface_instance *instance;
+
+	instance = _dbus_object_tree_find_interface(tree, path, interface);
+	if (!instance)
+		return false;
+
+	instance->user_data = user_data;
+
+	return true;
+}
+
 static bool match_object_manager_path(const void *a, const void *b)
 {
 	const struct object_manager *manager = a;
-- 
2.34.1

