Received: from mail-pl1-f180.google.com (mail-pl1-f180.google.com [209.85.214.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 047B885645
	for <ell@lists.linux.dev>; Tue,  5 Mar 2024 13:28:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1709645293; cv=none; b=cBplH+MmdQwJfdkCc6fo4dXy7hPdS1nsIYJiEjjipmyVySWqpkNdJGbnuCV9esglfAwyvGxCA7YVYhx0wTvr7A8kb95miW5zFJa9nW+dQwL6eq+u936UrVdnxNqihTLyF9sdSTAV0JjulM/yb8A/JOf6uwH088VdgNW84TymUf4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1709645293; c=relaxed/simple;
	bh=Tp+ANjtGrfyd7VlK+KV0wZAZbfTgmPCogOTb5Bn5iSQ=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=u8GKvz7KIsdrSXUimPqxLe/F+SenG21brGXLQ4z5JfJp7ba6fIkUsY69dbtbQD2EQxZhwV2AGANxlaOPdgJ14o5P2o2bTbCPioZxnnq5vMrC8gz4FLOCSChZTgikkplRrAaiG9ezEbbB0xEWvrHVf9hgX/fEwBkvVcV9mDSILCw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=RCblxtdA; arc=none smtp.client-ip=209.85.214.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RCblxtdA"
Received: by mail-pl1-f180.google.com with SMTP id d9443c01a7336-1dc29f1956cso44381875ad.0
        for <ell@lists.linux.dev>; Tue, 05 Mar 2024 05:28:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1709645291; x=1710250091; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=+x/WqBrbPSzfFYVPpjZkKT07an++eB2M422wbN+o4cA=;
        b=RCblxtdAElfDU0Gc6Kb8254msHTcwZ3iIR3FBMQq6D0JbIuSU4RaH8GwYSeZGG3/Fb
         F0Mfa2dos78HW+9SThdvmrX+4eyZI7lHnimTIaNFRs00+TR6jhzC2rNtBcJcYVtU2moe
         FnVccjQ+pjjLWmePykt1+G2zJ5wTp7o6yjh2DXJqhVEwqkzFM2a/1/B5VvTkNCrASXMP
         G3rxDaan8Kso13RsWLqp5dfhv3lRknJmdu+/F8Oh+mIb0VRPcjdttlROpCqi59BizppA
         P6sf1+T93fXy3tDqCBk9X/i01Ted/y0RI5xEEYbX1dBfOMlZKlXfEqd0YrQq1PaLoGi8
         EzPg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1709645291; x=1710250091;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=+x/WqBrbPSzfFYVPpjZkKT07an++eB2M422wbN+o4cA=;
        b=m+jJbmEUYRTYXKxNHXox0MBgV/yOHcMIansIfy6RzicDELY9NVegnaEzp0DldxMwdK
         gEb6P22PHOQGuQ9jlub3Nu/VL3IQLeGQE1CVBXN/1N3fHCbIebY7uUUVg+4NrXZjhu0j
         sP51N1Y28j3iyivBWU4OPt4cts8CXR2PuXtbHv8TWQ+9O28IcWKZ9J4+L7AX2tV2xipn
         mc+7QdyKEqS067PILXVQ27+OndVxxdFjEogkFnciGjWeQR9hWEilyZK9VswS/4CX8VOg
         ZYtqV73KxnuVzEeEeu2p2VLHfJYOb/oh7rASPxDZOqtSFnkTk77GAAUkMWncW9V40O5+
         P5MA==
X-Gm-Message-State: AOJu0YycIDPWg777dHz3vyKZ0C8w4bg2fIjcCC4tPymPN75IHEFN0Jub
	7q5/8SowilrmKi8cqXuaj7bImK3UQReDbl35HIKfD4rMWewouI1EESV7+pMN
X-Google-Smtp-Source: AGHT+IFKB1J411dP+mpMzcWKA7+BVLPErjoF17ay1NSGFzOx2ZKkJZpjm8VBDcqS75P/EnEzlFB3Xw==
X-Received: by 2002:a17:903:41cc:b0:1dc:abe7:a1a6 with SMTP id u12-20020a17090341cc00b001dcabe7a1a6mr1907970ple.17.1709645290783;
        Tue, 05 Mar 2024 05:28:10 -0800 (PST)
Received: from LOCLAP699.. ([50.39.172.77])
        by smtp.gmail.com with ESMTPSA id 4-20020a170902e9c400b001d7252fef6bsm10489493plk.299.2024.03.05.05.28.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 05 Mar 2024 05:28:10 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 3/5] gvariant-util: remove unneeded initializer
Date: Tue,  5 Mar 2024 05:28:05 -0800
Message-Id: <20240305132807.85724-3-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20240305132807.85724-1-prestwoj@gmail.com>
References: <20240305132807.85724-1-prestwoj@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

'i' is initialized inside the for loop, so remove this extra
initialization prior.
---
 ell/gvariant-util.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 6a695d4..6482e24 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -843,7 +843,6 @@ static void container_append_struct_offsets(struct container *container,
 
 	offset_size = offset_length(builder->body_pos,
 						container->offset_index);
-	i = container->offset_index - 1;
 
 	start = grow_body(builder, offset_size * container->offset_index, 1);
 
-- 
2.34.1

