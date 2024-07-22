Received: from mail-ot1-f44.google.com (mail-ot1-f44.google.com [209.85.210.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD79716EC00
	for <ell@lists.linux.dev>; Mon, 22 Jul 2024 19:04:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1721675093; cv=none; b=mBPB+U21KeHqqkNf0i2OOqnMMh3qIAK7cVrhY3Wn1cZjpeF6A97JFYAvuXAIWFBRlCEtV74SYeYqRftpHc6IBKW8OGy+4CHA3ONj0Lt9fvBuA9Rse0bOsk+F6Oj9HPkOjXLkBiBca6BJEE7ykepk9avsqCG5JIH59Of5cxRVjnY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1721675093; c=relaxed/simple;
	bh=JTOKlvnHXKQP7X0qSl5f+r4NTRUFOVQuadEzm1D2zVg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fJl4bnNFvsIjVRJ5rllJusuO9IB2YOO5k8onsQ6cM6+hvuidDMEg8/3pC0vlsRe3ILSlwJKW2p7JG0yqqQ0WmJVLfts65YcyfEvGNvPx7XR7MYqaP7gugZ6vi3O6vW/wuKObiUSrAGPAV24FlGiUPuRgF4cRev3kDGJotQDlWb4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Av3oAjF6; arc=none smtp.client-ip=209.85.210.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Av3oAjF6"
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-704473c0698so1922251a34.3
        for <ell@lists.linux.dev>; Mon, 22 Jul 2024 12:04:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1721675091; x=1722279891; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=6Ar9oa9Y7D9VTC3vGfK+ZeqCQMwFCA81nm2GNev4SuE=;
        b=Av3oAjF6NKmnnPL89BjnydIZo33o8PY3DobIGu1N8L0e8hNgO1vzQwo6VWKigWth7x
         oPfcqIOgAAFhLYT05VpbMGUu82+W7282Brm7Wx52HbctHnpdtmnj8ZzTNm6lT08FegHt
         UTHRpUF85U5UmL6GZUehfkI3M5t5OLMy8mAuroBhd8ulnp/4icxyzuiCyk+jnPpqZqU4
         JwQ2aCfA7mjC+KQ8NSwnTTfa2rZieuA1DTGhQX+AQcbKHc4T4LRQY1lihgtuOydFz/kT
         4Xsh2iq/ARy+1G//3IcxhKCwawHG+bjlPZ5crrxMWCEcfrwgDiXBZBR8sMkeXDh2OjW6
         7IFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1721675091; x=1722279891;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=6Ar9oa9Y7D9VTC3vGfK+ZeqCQMwFCA81nm2GNev4SuE=;
        b=IuRo71B9lW1nJLB5N7YWEn7jepR79ts1F6ztMrJUCoZ3S49FkVv4BVzGpbMwgd4Vw7
         /nnYRvf+gCN2EVSXjiE+KkqQY7HP1Np2WrTEZtOqXG+u2nksFDpjrxxwcFRvsnvfHMpE
         k7OhDCksqi+y1CkNfRI2ktcDkXEtHgIpi8jzIHnZ2U2O1hSIZ1GZi4R/pmtX194jylSt
         B+kA/v0wVSHdq0/FfNJwmoWjajcDx3/OHt6Z03eX2seCy0icllbVVN4dqSp0cYfbW8gW
         Gox9IA9BmNE9yCF5PDLOOtciMjGPQt5tAud8Rs8U3fTzwd+2QHPY+yN9oeNRELQvOvD0
         xGtQ==
X-Gm-Message-State: AOJu0YxVvP/rDFZ0JGSXk5Ecjr6J8ZpHQ/h0nwh5Tm0vVWA+zfSG3g4b
	mn6QjPTp1ZgWB2wcYovedbuYm6j3xSPxIPeitVMqdPLVQDbLOZbrYGZMbA==
X-Google-Smtp-Source: AGHT+IEqm0khNybxLCHAXP2u62aDbSJjZTD72H1mQPuzCzWesBJMaMwYLMzyXbKmcqSOESd5GxzDKg==
X-Received: by 2002:a05:6830:621a:b0:708:e969:e0d9 with SMTP id 46e09a7af769-709009258edmr7395081a34.17.1721675090598;
        Mon, 22 Jul 2024 12:04:50 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5d55aaee1fasm1411186eaf.42.2024.07.22.12.04.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Jul 2024 12:04:50 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 07/12] netlink: support appending using scatter / gather
Date: Mon, 22 Jul 2024 14:04:24 -0500
Message-ID: <20240722190443.43196-7-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240722190443.43196-1-denkenz@gmail.com>
References: <20240722190443.43196-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This version builds the attribute using scatter / gather semantics
(iovs) in order to minimize the number of copies required to build the
message.
---
 ell/ell.sym   |  1 +
 ell/netlink.c | 34 ++++++++++++++++++++++++++++++++++
 ell/netlink.h |  3 +++
 3 files changed, 38 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 247786d5ee98..b99b6e552eaa 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -439,6 +439,7 @@ global:
 	l_netlink_message_ref;
 	l_netlink_message_unref;
 	l_netlink_message_append;
+	l_netlink_message_appendv;
 	l_netlink_message_add_header;
 	/* path */
 	l_basename;
diff --git a/ell/netlink.c b/ell/netlink.c
index 39c5bc335e19..d7294a95f20d 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -821,6 +821,40 @@ LIB_EXPORT int l_netlink_message_append(struct l_netlink_message *message,
 	return 0;
 }
 
+LIB_EXPORT int l_netlink_message_appendv(struct l_netlink_message *message,
+					uint16_t type,
+					const struct iovec *iov, size_t iov_len)
+{
+	size_t len = 0;
+	void *dest;
+	size_t i;
+	int r;
+
+	if (unlikely(!message))
+		return -EINVAL;
+
+	for (i = 0; i < iov_len; i++)
+		len += iov[i].iov_len;
+
+	if (len > USHRT_MAX - NLA_HDRLEN)
+		return -ERANGE;
+
+	r = message_grow(message, NLA_HDRLEN + NLA_ALIGN(len));
+	if (r < 0)
+		return r;
+
+	r = add_attribute(message, type, len, &dest);
+	if (r < 0)
+		return r;
+
+	for (i = 0, len = 0; i < iov_len; i++, iov++) {
+		memcpy(dest + len, iov->iov_base, iov->iov_len);
+		len += iov->iov_len;
+	}
+
+	return 0;
+}
+
 int netlink_message_reserve_header(struct l_netlink_message *message,
 					size_t len, void **out_header)
 {
diff --git a/ell/netlink.h b/ell/netlink.h
index 70a55d652560..4d1c4761b3bb 100644
--- a/ell/netlink.h
+++ b/ell/netlink.h
@@ -53,6 +53,9 @@ struct l_netlink_message *l_netlink_message_ref(
 void l_netlink_message_unref(struct l_netlink_message *message);
 int l_netlink_message_append(struct l_netlink_message *message, uint16_t type,
 					const void *data, size_t len);
+int l_netlink_message_appendv(struct l_netlink_message *message,
+					uint16_t type,
+					const struct iovec *iov, size_t iov_len);
 int l_netlink_message_add_header(struct l_netlink_message *message,
 					const void *header, size_t len);
 
-- 
2.45.2

