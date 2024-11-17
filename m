Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4540B1392
	for <ell@lists.linux.dev>; Sun, 17 Nov 2024 00:18:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731802707; cv=none; b=sEI98HIoTeDemLsVwZnvR69mi3zgFKDviG85PqsQMGR6W7GB9xePBCV3xyu1mrof4cVb3gtY9++xZTMRrb5WQodCikyuerypUJj2BZWi3W55k01ZmhxpSJMaeonbwlaYC9MZP6xAK4BDyMT157XG0Rf4TqbzV0uJg9ujpH2k2Rc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731802707; c=relaxed/simple;
	bh=vsR21quUTOJLW464jrRoGiPe9Hs3o6bh9dyjkgqdQXo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=G0ELB7ngf0+P7jJ80N192YcP5R5jpwetT5q8X5XZ7xtIkcUIpYIoLaYHBJF5B0Gyl8SS1CMI6ESBW7so85t/lbYw/TW1jEhgm57axXgxMlV7YH8v8FMXEAw6WhELGr2IxuVY51wQd+ZIGIWekxjKrygvYt1ykdEApJDLR/FAar8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=QVuPh1ub; arc=none smtp.client-ip=209.85.128.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QVuPh1ub"
Received: by mail-wm1-f48.google.com with SMTP id 5b1f17b1804b1-4315baa51d8so16620475e9.0
        for <ell@lists.linux.dev>; Sat, 16 Nov 2024 16:18:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1731802704; x=1732407504; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=1HNksHPS/PVzynqLjSZAhH4fgavacgEjSKFz97rob00=;
        b=QVuPh1ubRUHvST+/4aD3JC8vwBU5HS6aKMIGl9JH3H9+NFc2yF3j3P6YEiSv/sZ39Y
         JSI2CX+y3SgocV7z9S4Vx/qpN9jqm5bLPEa6ULskUblmkypu5gyEQaujooQt3H8QKiPU
         hkgaI3VP63v4LY/zaernutjFGqtlb3DvnBDCus/sRVpIccl09QAJIjDovSReqYQHn01+
         p9ITQvDdQJyXWCHMjskN74p7+Pp397Q+sm7St+TNsvtbGrKts0j1HqBqKgdQg87hDo+N
         wUXB8x3qsdDwxpuJcT36XRLNMiACAOKzz/zpbZliwV16W9ecFpMhkwvyEBmwvHn4fzmW
         v3xg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1731802704; x=1732407504;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=1HNksHPS/PVzynqLjSZAhH4fgavacgEjSKFz97rob00=;
        b=M5ZUDJa/iruwOpLK1SExcJAgXsYz2Gp3P07jbNQ/sFQAoDco/Qnzo7ymfxNA12/4Yr
         xWU9PyxqAOm5d+1PHqPvKO68tA+9dLivLZFGWm6Z9ghFMJXnEWzE8HYX/epiQ7i/noL7
         zWXaYPCaDg06qPP1pmSMMVnZCcXZpHyLNURt+yCdGZA/HlDGOI77rtR7k44h9I4AGDlB
         Z/pCxHfrfcL9NdxMVmDYIWO5Lwmg3Z+pS69EbzOqumY6gXRdHkyjD9sHVdTxozEYMCC8
         vgL1zCklPCRYfg4J5E4KYTuMi+qJQUZ3+qmnbG8rV4JPQ2UrNIi2vEhQEXpQQTYkamhQ
         30YQ==
X-Gm-Message-State: AOJu0Yww55lkYvQ5xdBGHcYR+Qe32hx7SZlR3VysdlOuluCRCVupfMn2
	bJ+0EosQc3KBTr/4O9D8DwY3hWzP3RoMkjYm6Kw61wWR7GvMCKFi
X-Google-Smtp-Source: AGHT+IFEHZds+Km+CoGuImOx4m5jjis0NwvJ5nI+5lySOqP80nidbhAO+6csAK6HxiVd7/yhpKRBag==
X-Received: by 2002:a05:600c:46c8:b0:431:58cd:b259 with SMTP id 5b1f17b1804b1-432df790731mr64906095e9.31.1731802704362;
        Sat, 16 Nov 2024 16:18:24 -0800 (PST)
Received: from nz.home (host109-156-56-74.range109-156.btcentralplus.com. [109.156.56.74])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-432da27fbd2sm106719105e9.19.2024.11.16.16.18.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 16 Nov 2024 16:18:23 -0800 (PST)
Received: by nz.home (Postfix, from userid 1000)
	id 42F2524A077F18; Sun, 17 Nov 2024 00:18:23 +0000 (GMT)
From: Sergei Trofimovich <slyich@gmail.com>
To: ell@lists.linux.dev
Cc: Sergei Trofimovich <slyich@gmail.com>
Subject: [PATCH 3/4] dbus: fix -std=c23 build failure
Date: Sun, 17 Nov 2024 00:18:13 +0000
Message-ID: <20241117001814.2149181-3-slyich@gmail.com>
X-Mailer: git-send-email 2.47.0
In-Reply-To: <20241117001814.2149181-1-slyich@gmail.com>
References: <20241117001814.2149181-1-slyich@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

gcc-15 switched to -std=c23 by default:

    https://gcc.gnu.org/git/?p=gcc.git;a=commitdiff;h=55e3bd376b2214e200fa76d12b67ff259b06c212

As a result `ell` fails the build as:

    ell/dbus.c:1700:24: error: incompatible types when returning type '_Bool' but 'void *' was expected
     1700 |                 return false;
          |                        ^~~~~
---
 ell/dbus.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index bd6e1b8..1ab4ded 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1697,10 +1697,10 @@ LIB_EXPORT void *l_dbus_object_get_data(struct l_dbus *dbus, const char *object,
 					const char *interface)
 {
 	if (unlikely(!dbus))
-		return false;
+		return NULL;
 
 	if (unlikely(!dbus->tree))
-		return false;
+		return NULL;
 
 	return _dbus_object_tree_get_interface_data(dbus->tree, object,
 							interface);
-- 
2.47.0

