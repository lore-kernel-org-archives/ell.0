Received: from mail-oo1-f50.google.com (mail-oo1-f50.google.com [209.85.161.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FDF9189B8A
	for <ell@lists.linux.dev>; Fri, 23 Aug 2024 16:15:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724429760; cv=none; b=Dpnp+vlSN4/++b7IYr2W5w55pL229oYWPKCAGXiJb6m1Btco9cLlem7SCirVStZUGvkngh2GYvhcw2iD4B8nDZfUSqpFqraekf6W1jhnZATbAQ/iQs92FRiQxbrdVlZWZGm4s8x8zfrxVOjVibMgLi0BGPb6tVDcA9Ixf3C/K00=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724429760; c=relaxed/simple;
	bh=BV7SeL2/B5lex2MVj42aZr2pI1JPqv+Tuah8jEOjo5w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=EWseYyMlAGmJcbu+UgB8Fx81UtREvRRAHZ/Q6L0cVFK5iODb2VhFO2Y/yjMs54HnZ7oSsdHW+dd01y95bzmhHax/XM7dvBQ+o4JfoIsnXyZQ2cTJqg51u4+DsfLpu8lT8HnsikxIGHRmMvFX1N/esRF66OnqJIuPR+hFqsQ17Bs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=PHpS2NkA; arc=none smtp.client-ip=209.85.161.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PHpS2NkA"
Received: by mail-oo1-f50.google.com with SMTP id 006d021491bc7-5dccc6cdc96so433326eaf.0
        for <ell@lists.linux.dev>; Fri, 23 Aug 2024 09:15:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1724429758; x=1725034558; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=0V77cBuCb4zBLJXH7bpBm49sAAKt6Rv6W1Gs1Jg7D50=;
        b=PHpS2NkAJhlNKaNIiilEh5NcbTPoyCjK+O6/p9oBcmMTXUfCA+gWgaW9og1SnlmvQi
         DcxxY0Ro2KrsgX+3vE3qKSZ+Oew1aAVOH6pdlFS1Dn2VMYnSRlFJP4UWFE/2T+wMCZmx
         bz9iJNNSMNCMpZ8mKj4UluzcUmiGP6Hsh/QQZCzVzwYmzvftv5G8yjplvGYwlaIbXUph
         u/IASQySd4t/3LO3VJ9JUdJ5v1gvOPvUoC+mqAal1CGi87vfUFc2rWq0Dapp/0vVSTwt
         MaWUM9b1LEYBQLNEGA5pNNWYS9YkwK5uQyiQ9ZTemGNlRFwe3M+1Xp4z+nCNpDOO4P6V
         USGQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724429758; x=1725034558;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=0V77cBuCb4zBLJXH7bpBm49sAAKt6Rv6W1Gs1Jg7D50=;
        b=NNhsmkMuIOPXGoOfDYx8Ag8Pf/NqYifllKLLJ3W7zPafcQiEKYd4XxZOZNWNUspXF3
         3j9Z0EFDYZhKyqmzqbBUtETg/UwSHBw0ufp/kQjSLHgZBvz8ASBQAl1aP3or7PiAdAMR
         cE3Prhj9BuQsMiXnKmSmF5uc6AeMAgEI++m03lbgoSX0r4/+ljrhXcLrm8x8jKRUP4hT
         HwKxDB4arHWvFzeT759h4Eua/hyHZP5+3DDbUQ1H/v/9zs3ilFG5Di2OWHpf/FN3xgwV
         qdpGrmuuFFcgavQyR7KiRg3RZbhaRvVLEaFlzfy3K1VbUx8xefnLtjHXri9hU7P+JUWz
         FQDg==
X-Gm-Message-State: AOJu0Yw1DF8tik8+B2grX3RedacgNjq7ZHe0l/oyUw8IGHGY3AGEfWpp
	MR8k1Vt0C8LYzJuKL8lXrhJuXdDOVJbul7GFTXRT7oS7YnrGxngX5t/qSg==
X-Google-Smtp-Source: AGHT+IHLgE4Ih/7qMt/BEdJwKNKXrFG6n6/P5/kv+Ldo6Fda/BbC2wciEkT4RZb1z2MA4mYlUM8qxg==
X-Received: by 2002:a05:6820:1ac6:b0:5c9:d9db:6a51 with SMTP id 006d021491bc7-5dcc5b67513mr3137200eaf.0.1724429758249;
        Fri, 23 Aug 2024 09:15:58 -0700 (PDT)
Received: from archdev.attlocal.net (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-5dcb5de7c83sm750222eaf.14.2024.08.23.09.15.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 23 Aug 2024 09:15:57 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 5/6] util: Handle NULL pointers in l_safe_ato* functions
Date: Fri, 23 Aug 2024 11:15:49 -0500
Message-ID: <20240823161553.479576-5-denkenz@gmail.com>
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
 ell/util.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ell/util.c b/ell/util.c
index 45ec6c8110bc..f474098c082b 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -760,6 +760,9 @@ static int safe_atou(const char *s, int base, unsigned int *out_u)
 
 LIB_EXPORT int l_safe_atou32(const char *s, uint32_t *out_u)
 {
+	if (unlikely(!s))
+		return -EINVAL;
+
 	if (!l_ascii_isdigit(s[0]))
 		return -EINVAL;
 
@@ -808,6 +811,9 @@ LIB_EXPORT int l_safe_atox16(const char *s, uint16_t *out_x)
 
 LIB_EXPORT int l_safe_atox32(const char *s, uint32_t *out_x)
 {
+	if (unlikely(!s))
+		return -EINVAL;
+
 	if (!l_ascii_isxdigit(s[0]))
 		return -EINVAL;
 
-- 
2.45.2

