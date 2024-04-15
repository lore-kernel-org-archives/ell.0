Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B93D15575F
	for <ell@lists.linux.dev>; Mon, 15 Apr 2024 19:14:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713208498; cv=none; b=kKj0ZBKQ8QcfiaorczAjnK/xK0qtga1HmZsTC3aqB46FOecrlcqP6kE1MguwrAK4msDk8QFnXoVpbCrvOw/0QT+amX8zQ+856jAZeREf8jzqtP+rGDy7ghYhcZ/Jwkc6PBt9fs67ncVynP16pCJq4Qb2kBqIGWM4MmCB+gIfhYU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713208498; c=relaxed/simple;
	bh=Zg7Hu1KhKlj1KupyiJ94O57KVPpipYFIPIf5MgSTY94=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=RYc1SYS6mK4DF4WCyCzTdzyr1KdXLbZ3jfyk60oCfvYMMiOYGz+F2zr6yWMkxYztwSLxrqg7zKW41J8wVB+vzvhJP3+2ZFfOAlbyPQ/ykhQIkpCVy4dQq7YEq3oqrDOVHv7W864FzG9ipFNwkmIQUeWK70uhxF5/bg9bhHPiEhg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=IHaSqIfU; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IHaSqIfU"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-5a522ae3747so1601033eaf.1
        for <ell@lists.linux.dev>; Mon, 15 Apr 2024 12:14:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1713208496; x=1713813296; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=zdJvczNucGwJm49momo3YBbWLY1Ibf9EQ5Z5pwzZsIw=;
        b=IHaSqIfUhA8AnwomuKGRrGpsDA+SxWP0Qae9r2HmpB85Y/3OfFwB1JHGgSwfSIcqPb
         LjcCvFnDC9Y/smOw3IbUV1b9AEXkJ0WwyRtpCQO3FyEMDXptvg9Js2fCJlCq923vbCXp
         O2P5ZkwK0HXDunKUraFUTcuOGR98LuX5Gxm2qDrW1RiEHqwjJ5JFG+WKO7deA3BB139G
         JJqqMPmBsyqJBlKKa6u8lQS2624wPLU5t+SmceGntRQkthyZgM50Ik4ALVbjIvwg2nz8
         4Ovi2M7dGFlV9fxc/lupEhk3vnBpKKn5oQRi00LD7cqZ2RTDI8mNBkQfcMt7QrGe3iDc
         gsPA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713208496; x=1713813296;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=zdJvczNucGwJm49momo3YBbWLY1Ibf9EQ5Z5pwzZsIw=;
        b=UF6ImmyG2Qu4XokwjGE11vqrX0ZQFX9+B0EhdBosSgVi1S3p1vzdHstkaA6C7CbawV
         VVHtnBRD8RmsBR0iGqkEPLmznI2DojBbg/Wb0OK9DjborGVRfHgaH3Iuo+UUqbK2mOqK
         yZ4aJd41Iny5SRjEozqIFBhrIXrwf5aGh/fcrpaOvblryeQp+u5TQxpBgVks18NJBYQ7
         MZGBrY79c0EoyCajkk1tiU53WWIdOKV7/tVIVA2F8woyGKHzvf/jxcoegcK19sx3NIXY
         ZAGBWRxkl/DA92EnwSkHRdpmN5qD7GHoKX6aNkuXrBNSH4+9rmCBbHFKuETlbLda5v98
         Gb6g==
X-Gm-Message-State: AOJu0Yw3GVW8wrzdPTps0vDG968E3CgfiSkZXiUuGYN+byr3mzjaXYVI
	5d3I4HzU+6dVKXBuWLMZAsH7a0QNxwF6fDEiQAZI1YpOG8/9s65ZepVTzQ==
X-Google-Smtp-Source: AGHT+IExmQdSQ2RaE1SAFey1EXWF0PTGAeHwfyuFsbv3qB1YOh7uFiLDsh2d6JNjc5LYmVGq4NM7dA==
X-Received: by 2002:a4a:ad4a:0:b0:5ac:6891:ce56 with SMTP id s10-20020a4aad4a000000b005ac6891ce56mr206566oon.2.1713208496621;
        Mon, 15 Apr 2024 12:14:56 -0700 (PDT)
Received: from localhost.localdomain ([70.114.247.242])
        by smtp.gmail.com with ESMTPSA id w8-20020a4ae9e8000000b005a586b0906esm2206526ooc.26.2024.04.15.12.14.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 15 Apr 2024 12:14:56 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 1/4] util: Remove confusing static keyword use
Date: Mon, 15 Apr 2024 14:14:33 -0500
Message-ID: <20240415191454.3259243-1-denkenz@gmail.com>
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
index 80b29b7bb6e3..b5d96754e8ae 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -349,8 +349,8 @@ inline __attribute__((always_inline)) void _l_close_cleanup(void *p)
 #define _L_IN_SET_CMP(val, type, cmp, ...) __extension__ ({		\
 		const type __v = (val);					\
 		const typeof(__v) __elems[] = {__VA_ARGS__};		\
-		unsigned int __i;					\
-		static const unsigned int __n = L_ARRAY_SIZE(__elems);	\
+		size_t __i;						\
+		size_t __n = L_ARRAY_SIZE(__elems);			\
 		bool __r = false;					\
 		for (__i = 0; __i < __n && !__r; __i++)			\
 			__r = (cmp);					\
-- 
2.44.0

