Received: from mail-ot1-f43.google.com (mail-ot1-f43.google.com [209.85.210.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0CEC5132470
	for <ell@lists.linux.dev>; Tue, 16 Apr 2024 14:25:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713277503; cv=none; b=DnkM8ImwzLnUTY7d1R1xm1av6ZqLj0w/CSMfberrDQJXehk1d8vRIGdWTlVpYsPR8oNROxJQIlGY9EgV+z9nZKnyeAX69CgQ8Id2cbo/191WPdVCpKpDUK9mQRnQ6+N2IJRw0ggvcg6Tn6Rdnb9G5FTPx803bkNFURn+imPeL+E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713277503; c=relaxed/simple;
	bh=Qg0sWfUZ1Y5AVACzSwVOzRzIU+95KW5HJ95s5ihX/OA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=spk4qoYJ8m6+lxaTm+YCJwuwHMNo18HFsPDlz6Wmm95VCKjdPMx+V1kPkdmCxckqQIHK0PV6SKzIQgzvPASdUFiSVTgJOf9FQC4pDqKbWQUAnLx3fUdKOexGfYoxsQ7k5oyDuvYJQLD8xI8ApdafCcSfcqTy/MVRMR4b/pxAUpY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=cz889umz; arc=none smtp.client-ip=209.85.210.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cz889umz"
Received: by mail-ot1-f43.google.com with SMTP id 46e09a7af769-6eb7500abe3so1495376a34.2
        for <ell@lists.linux.dev>; Tue, 16 Apr 2024 07:25:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1713277501; x=1713882301; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=0qCR6qBAYBIAganQSNYamaCuGyGHoQ+XWEWbUy/9fgI=;
        b=cz889umz5htv9bSLoCb/72PbiXP1K1C0ymAhxX/AUhqtja/AHTQIkUKzTkfcA3PSZ8
         XsHD3b/XC4G8MIE9i3Yu4yrcgzaRbdTgekG1fmtQI0UtTQSik1M3xB64SQn4l1i54kxL
         uB1IOmYsWOPZ12EPCy1e9xos8mzlY4ef9AGxDDN1N7L1y/sh3DqDMf8r9Pi+MJCjNPi9
         rVPWMMyTNmHmq3Twumqh2kKCawPx8tibJkGLQ6zE0a7PlsjpqQfsdXo2rq79A+Qj4T1p
         s1kj6G2dN9Tg29CnTxaq7jhYG1dvmmQbAxqs+JIDQI3hzrro4qrElYvvax4BokbuWXp/
         bcYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713277501; x=1713882301;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=0qCR6qBAYBIAganQSNYamaCuGyGHoQ+XWEWbUy/9fgI=;
        b=Vr5QgbkgvI5YCnXFSW/D978wtz2z0VOC2H+hoE9rw3xLaxU8trAD+lTJxT5WwHkWsa
         u70NbFXmmooXRbXaZ7W5cXLJf1cCIHsN+7RxELzCVQhHC9cFivfZ7KgqrN0YO7vY+dRe
         11wepcuuKvItgNIYeokS6mJo/32ixJphY/JHOUBar/NdIewYYMSZwpQskSkIwrqIZoJk
         6xMcdHWv/vhQuLr5lozXDQY+aqLIz2Sr9lyIUOnJftIhPlZRHZ3Zxj3SSz+Q0IQQ08yq
         yUSrmScu2rS2/+HtLCZwt/aogtGqKElUCLa7yHskqhiUc2BShxHr7o6b1wkRR5HOEXOx
         vAlQ==
X-Gm-Message-State: AOJu0YyT+ez3MissEbCPzgboAx4ZgIRq05IZnZLNF6BafxM/pmc/1kgE
	RyibfuldQCQTC3s8QRTelxjFlCOw8y8HMH0aNQyMyZQYBfFoDPzEgPuiIQ==
X-Google-Smtp-Source: AGHT+IGiVH5ZwRsa9tZD+KtfyRGkoIoFiYR65vYfIuEYnDNz4zvQwONcpATxf12P+1ycv+BksdrVvQ==
X-Received: by 2002:a05:6830:2059:b0:6eb:7c4e:70c1 with SMTP id f25-20020a056830205900b006eb7c4e70c1mr6060355otp.37.1713277500948;
        Tue, 16 Apr 2024 07:25:00 -0700 (PDT)
Received: from localhost.localdomain ([70.114.247.242])
        by smtp.gmail.com with ESMTPSA id r33-20020a05683044a100b006eb892647dasm526999otv.79.2024.04.16.07.25.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 16 Apr 2024 07:25:00 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH v2 1/4] util: Remove confusing static keyword use
Date: Tue, 16 Apr 2024 09:24:52 -0500
Message-ID: <20240416142458.3353383-1-denkenz@gmail.com>
X-Mailer: git-send-email 2.44.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

'__n' is declared as static const which is confusing since it
would imply that __n is only initialized once.  This works out in the
end since the macro used in a separate anonymous block, but some compilers
(i.e. clang) will generate a symbol table entry for '__n'.  This is not
needed since the expression is always constant.

Declare '__n' as a const size_t instead since that is the type produced
by the sizeof() operation used by L_ARRAY_SIZE.

While here, also declare '__i' as size_t to match '__n'.

Fixes: 4a9f6388dd7f ("util: Add L_IN_SET macros")
---
 ell/util.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/util.h b/ell/util.h
index 80b29b7bb6e3..237ea4824b06 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -349,8 +349,8 @@ inline __attribute__((always_inline)) void _l_close_cleanup(void *p)
 #define _L_IN_SET_CMP(val, type, cmp, ...) __extension__ ({		\
 		const type __v = (val);					\
 		const typeof(__v) __elems[] = {__VA_ARGS__};		\
-		unsigned int __i;					\
-		static const unsigned int __n = L_ARRAY_SIZE(__elems);	\
+		size_t __i;						\
+		const size_t __n = L_ARRAY_SIZE(__elems);			\
 		bool __r = false;					\
 		for (__i = 0; __i < __n && !__r; __i++)			\
 			__r = (cmp);					\
-- 
2.44.0

