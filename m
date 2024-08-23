Received: from mail-oo1-f44.google.com (mail-oo1-f44.google.com [209.85.161.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E7F3318BC2E
	for <ell@lists.linux.dev>; Fri, 23 Aug 2024 16:15:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724429759; cv=none; b=YGRODqpclANRE7ixBflQoq9G8R7K2ukVziijwCeXLpC6u9zOt0EpF1/ddopFYoxefeVjEbbxuhPJIUOTL/k/YNeqLZXDEZvC7dWkdraDdYMXogwBRXvhUHZ8cnmWYcRh4hBCg3VERWZangYibp02LK4wiU/uzq74SJhUEkQ4q2U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724429759; c=relaxed/simple;
	bh=54KVPL2jbEaF7pVSk0BT+5BpPNnmujeRsM+hi2JHpQs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=iZJroMYkLKoum3et5WKsrrrgVI7nuRGkOYyq3+IyRnEVm6s6Rc76Pi+dNSXFI8TL553DS9CkJgJsAzyBfl5INtKXDL5YCzgbjoJQY8aOB3yjl0G+ekj8aVZbhJpW3ASHELSQJsTBER5uA1lKaCp0F/GetPrP9S75Xt3Kq9opJ8s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=aWQEK63b; arc=none smtp.client-ip=209.85.161.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aWQEK63b"
Received: by mail-oo1-f44.google.com with SMTP id 006d021491bc7-5d5e1c86b83so1697702eaf.3
        for <ell@lists.linux.dev>; Fri, 23 Aug 2024 09:15:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724429757; x=1725034557; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=caLvEP4uqOkSjUVG14X4mzjxCuPiPLM9F/FntgMV0ho=;
        b=aWQEK63bVnNDsGBrxsnhfrOgFSj19ZMNjSgBRdrh2zQ9uIsz+fZpbVszujtjm6CsAN
         WrUTnmKLrJp1iDN2EJys1VRZm10WOufFGq0HNetM+i4ZuzJ7rh8VI+lSyW4EkWEKse72
         BkDrmsUXv6bg49KJ6CWRs8Lchx7QUn23mwg0Ye9YCS10FaoEwGiASGUcomnVFVyctpJW
         kqYWxfdlJ1yo3YRACLOLpEhYOoSW5eRXNwhjF8T/XW85tMqgsZ2eRgKVNpAsaZK6s8eW
         7ZmncgYS3mrr78fBYMqFrJmAv0OCfHqqSws/SNXLMCJKHS+ZcDDHIrAi+0dPmJOKNToq
         mcrg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724429757; x=1725034557;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=caLvEP4uqOkSjUVG14X4mzjxCuPiPLM9F/FntgMV0ho=;
        b=AnUGwDIy7Eza4beZdh62FS8i5Nmbz/gxNqa+EF+E9PkXar0s3nd7sKQlmCUN3vfjR0
         4qUz7LuGxtk5+PFSEcvlgGEvtIIPJVudVr5Fx82zlVkmHgEtwPLBOchCHLdd880HpU4z
         j3v4MkzIx4E4Ik7/QyOMptqoBAOjQXPAuOhg+Teoa7YEikUZj44JpSCbxdaKnA/l3+MI
         rdmwBYUudzV6roJ6Du3V/6bfILqdJHm5V9WPc0CuhV2SLVNLW8QMx9LMLO32Qt3iZRnU
         RxLblxFOiU87illfZVngOPtVNw3NWUr7STq+fPa92/oFUM2Xtj9i8tNjf4j1dFF2zfmw
         XcMA==
X-Gm-Message-State: AOJu0Yyjrs5ywpqABPYh1AjfqptyXC9DBzRBsRjXL11ppVZAjMoRIQh1
	mvlvHih3anYyaCLpnCzHJCSZL1k5LLzq3IMOSLBzQBMZnzOBNAV0QujDZA==
X-Google-Smtp-Source: AGHT+IFyxcVqIHep68mVCObySLM0nQEG8Jvfkqb6FjQy59jdsDysLl2khtgvcm560pzt/ZB5m4arUQ==
X-Received: by 2002:a05:6820:1607:b0:5da:b29a:3c84 with SMTP id 006d021491bc7-5dcc625a882mr3102674eaf.5.1724429756771;
        Fri, 23 Aug 2024 09:15:56 -0700 (PDT)
Received: from archdev.attlocal.net (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5dcb5de7c83sm750222eaf.14.2024.08.23.09.15.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 23 Aug 2024 09:15:56 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 3/6] netlink: Add l_netlink_message_append_string
Date: Fri, 23 Aug 2024 11:15:47 -0500
Message-ID: <20240823161553.479576-3-denkenz@gmail.com>
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

---
 ell/netlink.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/ell/netlink.h b/ell/netlink.h
index f09d42043675..b51748195ca6 100644
--- a/ell/netlink.h
+++ b/ell/netlink.h
@@ -10,6 +10,7 @@
 
 #include <stdbool.h>
 #include <stdint.h>
+#include <string.h>
 
 #ifdef __cplusplus
 extern "C" {
@@ -119,6 +120,14 @@ static inline int l_netlink_message_append_mac(struct l_netlink_message *message
 	return l_netlink_message_append(message, type, mac, 6);
 }
 
+static inline int l_netlink_message_append_string(
+					struct l_netlink_message *message,
+					uint16_t type,
+					const char *str)
+{
+	return l_netlink_message_append(message, type, str, strlen(str) + 1);
+}
+
 struct l_netlink_attr {
 	const struct nlattr *data;
 	uint32_t len;
-- 
2.45.2

