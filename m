Received: from mail-ed1-f41.google.com (mail-ed1-f41.google.com [209.85.208.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 173B6217F22
	for <ell@lists.linux.dev>; Sat, 26 Oct 2024 11:01:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1729940507; cv=none; b=Jw3Cj9yNhsGmhLr+DHHZsyTpvl8RiA/xwQgZ3Q3kmYB9gU04txDIppc1q5O/fArEhe5Igq/e2KHRNyxFyWH7ctGAA5eDWZOteZHs8Mf/nm7/5oqtBx9G7nYefH+Pxa3DTaGSLOlt3HO+Y0rJR+9ZH63vzucoA65e7gF7MY8VZdw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1729940507; c=relaxed/simple;
	bh=PyddCprS0cjcnc53TOxHjVmIuX6orZHmSwPIZSBiKdY=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=n467mpcEI9IRFzQegTcEuBi2ac9AAZrzRAXHJ+mR0q4DpzNNl5tX4P3VJq3yv6Rq0bWDYNiSfhask7rICmIxd6zURliOR4Z5KVa7cBZhEkFEyB1dZb1xpGoTwIP+cp4BdAmh5h/VomEdfDLIdX1RCzL+C1zNFEXj9/EQw8qFFLQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=YPoevR8T; arc=none smtp.client-ip=209.85.208.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YPoevR8T"
Received: by mail-ed1-f41.google.com with SMTP id 4fb4d7f45d1cf-5c96936065dso3154353a12.3
        for <ell@lists.linux.dev>; Sat, 26 Oct 2024 04:01:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1729940503; x=1730545303; darn=lists.linux.dev;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=m0iekHj37lcjq/XLuOSnarSzWH1K/YFp1fLgkE/hxCs=;
        b=YPoevR8Tj5b1pHJ00WR/vOuZK0IWcUpqtow7L78wGc7F6BLm5rZKOLzf8bmVgKPiuY
         dR3SU45oa+IAUG7AMoJUCPmXsm8+hptnzMDTG3YhuzvV/PzhXyzLSLZqHiDanHtIQcLE
         8oHbtP0F2mkgWwPYT7ezvTkDdk7PFd58W+OsCZD+Nxxxun7AJqEgJq1F6/zy0bQZQDMd
         sea8FxIsltxeYHSQCgzuEY/tb3CYpJ04l762oyFrOYkN5/E9KHOAn8xmFxuQZyLw0yjX
         lyK70Oa7Pb+4LNGO2jKAoiQsk5pmFtNSaRHcXflIzHbwm0aSrJU+7xTJr4ACOrCzIwU/
         MsnA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1729940503; x=1730545303;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=m0iekHj37lcjq/XLuOSnarSzWH1K/YFp1fLgkE/hxCs=;
        b=ezYCvgYKvc4dV9Awkrvio/JIta+o3j9HakD7tEko/i6vjgCRcAn77vHX0iq7IPOdgs
         cu1x5X2mHSQSGFrG91YVwVsWNqjnRaBa4dVQ8L1cVdsQXj8nBbCicTGkocfqLUuksG/c
         BYay2WkL77Ji9RQmXG0hUG8vnTvfaINbipNRu6p84VytNG1xzzvpMSFfC1ls5Mo09V29
         5U0hQcqb4v1LPocMMSPbvsjy5NRZNTWynjeqKXyxBWJtU7gnUL8k+/blYOaaSGKGFBO0
         1fF8D+9hl2ItT7A8JWFuOtt93eKaM4TEx7MDqnhACGhfqGqMRPGXQCmfieDm4L2SwboQ
         ftdw==
X-Gm-Message-State: AOJu0YwZWstbv8toRDidn6bVZ9v3ldRcypTQYbDAdX0VIgQvzTzWH6or
	+5aOjNVgU+U8VrLhZcfiZQuTF9adQPgTfMRttNpc2vSXQ48jXGkwvUHjNDD0DtWno3RIgpfGxAE
	0GH2QPNjjFbCBIV124OSEYEsz69gA9mIr
X-Google-Smtp-Source: AGHT+IH08Q/gnR9i3+goOtqRkeLDgS9/Xbp6WzthbMclaLgmAOf8rBT75FCNC2+gNIjoz77MBS35h/aHFrV4ammTC4U=
X-Received: by 2002:a05:6402:26c4:b0:5c9:3f2:6ea7 with SMTP id
 4fb4d7f45d1cf-5cbbfa54851mr1354308a12.27.1729940502938; Sat, 26 Oct 2024
 04:01:42 -0700 (PDT)
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Aditya <vortexilation@gmail.com>
Date: Sat, 26 Oct 2024 18:01:32 +0700
Message-ID: <CAL5LfdR_mL+LZ4APgLbWcptAvqnFvTJqgmE6Ryaj4gyquJYN3g@mail.gmail.com>
Subject: [PATCH] ell: Inclusion of netlink.h in genl.h because of recent changes
To: ell@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

I have found out that because recent changes, compilation of mptcpd
will failed with the following errors :

In file included from path_manager.c:21:
/home/user/works/openwrt/staging_dir/target-x86_64_glibc_custom/usr/include/ell/genl.h:
In function 'l_genl_attr_next':
/home/user/works/openwrt/staging_dir/target-x86_64_glibc_custom/usr/include/ell/genl.h:98:16:
error: implicit declaration of function 'l_netlink_attr_next'; did you
mean 'l_genl_attr_next'? [-Wimplicit-function-declaration]
   98 |         return l_netlink_attr_next((struct l_netlink_attr *) attr,
      |                ^~~~~~~~~~~~~~~~~~~
      |                l_genl_attr_next
/home/user/works/openwrt/staging_dir/target-x86_64_glibc_custom/usr/include/ell/genl.h:
In function 'l_genl_attr_recurse':
/home/user/works/openwrt/staging_dir/target-x86_64_glibc_custom/usr/include/ell/genl.h:105:16:
error: implicit declaration of function 'l_netlink_attr_recurse'; did
you mean 'l_genl_attr_recurse'? [-Wimplicit-function-declaration]
  105 |         return l_netlink_attr_recurse((struct l_netlink_attr *) attr,
      |                ^~~~~~~~~~~~~~~~~~~~~~
      |                l_genl_attr_recurse

This is compilation for glibc and by using gcc 14.2.0, the solution is
fairly simple :

diff -Naur a/ell/genl.h b/ell/genl.h
--- a/ell/genl.h
+++ b/ell/genl.h
@@ -11,6 +11,7 @@
 #include <stdbool.h>
 #include <stddef.h>
 #include <stdint.h>
+#include "netlink.h"

 #ifdef __cplusplus
 extern "C" {
