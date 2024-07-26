Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9607D17BB3B
	for <ell@lists.linux.dev>; Fri, 26 Jul 2024 16:12:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1722010360; cv=none; b=dS5c/e7B81F8IwJJWc3NxjcfqFoMzWYJ00UTNf43YJbxAP53bkvVZugDb7CBs0CDO2dnCNU4mbI1wy4f3EAIYvBJqiq8UjFRBQBZqcrCZwnnB10yty0sQFn+mplkYxs5SwM+61vLXYes+xBoUqx/TGf1wKR+jK+tHfREzVAVmls=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1722010360; c=relaxed/simple;
	bh=d6I6HLsIb1hMKfhNqL01nz/LfcHbLkdgDk9SbOo3U1I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Pf0LxgB+1qrbeDYzWX6e6Aa07oiSR9kv7ZJbIY1VU94yjxp1UDUczEZFiqOqmHMBKUSwnAnm+Mo9ZcdymfdyJ7aenvjO4I9AbtfRH5i2/INTla2urY33EB30tAPx5DsjdXGRorL+0XDiF7dUoYDD/NUXHvWN9pGvv1K/yE46zvo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=dEyCx1i5; arc=none smtp.client-ip=209.85.210.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dEyCx1i5"
Received: by mail-ot1-f41.google.com with SMTP id 46e09a7af769-7093705c708so1101705a34.1
        for <ell@lists.linux.dev>; Fri, 26 Jul 2024 09:12:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1722010357; x=1722615157; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=tfn2YMD8l/x6G2rpYxzrQt/bBERQh2kasx22+0W/fu0=;
        b=dEyCx1i5KIDXI81L9NY15zKCLOZ+Y/M4Qbvzs71Yhpkb6aCVUt0EaDplJJkMjyZFU4
         VUJmdOEcOb84CvP6/gVjOS4yaPfNMNlnwX1JFKUxVuNvARhlyWUWGfFhR2w2lnlMTQac
         EpJEfJxTkXd0O2hh/tozR5IulH+EObnXGY0B3uPP8lc63/7eJhWg5L02MxH8LaTvvQT4
         /j04Up8aptJW3lYGcdV5gE+Lr89eUM23ruF6FHVtTit0yiEIF9P7m9sQLArNRgUwpvIf
         aZoBdYxr2FAxRiC2vVceZAflhGikaVRRI7/8axkJ0OgdU8fvhLOq2uRvcS0o0rY4wV3q
         ZHgg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1722010357; x=1722615157;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=tfn2YMD8l/x6G2rpYxzrQt/bBERQh2kasx22+0W/fu0=;
        b=NE9ZvWp8PUGIeqEPQ8ELDiyajOBVLmgMnu1rHEeJWWDAojzizjEONcgoPGIZiZJYAL
         aEkSSPiB/3zfOEJh3zNlHFU+xGnMqLjeecPlyvbfvDVekMireUa8Cuhc42GJIdCG478q
         SwvsB41el8/wfYMJaLuqzKsfnacL89MXVtiyG2tD4VMvPlU7MIoiiQloOgvoq4/L5XHR
         5OCOGKFHUfz8eo0na5bntJdV7Xbn/Qj7FcYceuC7EwbRiUyPa3dsSwXY002Z0m6meyeH
         mC/wjAJyzsOS53ofl6laTu+2rw19KRvcy9LtJH+uLABWqiY9Tl+iDClitS71DzgGgmu4
         qXlQ==
X-Gm-Message-State: AOJu0YzZB+/KkQZRl9PyOwsK6BC/n3a7GVbQi3308W7F5nDbBYvS2236
	QsAlzzFbVP4qZvvOZsSZZrFtWS+WV2xym2Yjdn0ZpO3iJW4vPVM5ET7B2A==
X-Google-Smtp-Source: AGHT+IHuJrwLm3/0N13NUUsR4zwYRK5dIOY45LdwujlcKLhJbKaykZXewypyjpZCBGCC9PPT7S9tgA==
X-Received: by 2002:a05:6830:6b05:b0:703:6847:3ab8 with SMTP id 46e09a7af769-70940c5e151mr78975a34.25.1722010357643;
        Fri, 26 Jul 2024 09:12:37 -0700 (PDT)
Received: from localhost.localdomain (syn-070-114-247-242.res.spectrum.com. [70.114.247.242])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-70930718ec9sm792997a34.30.2024.07.26.09.12.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 26 Jul 2024 09:12:37 -0700 (PDT)
From: Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
Cc: Denis Kenzior <denkenz@gmail.com>
Subject: [PATCH 6/7] netlink: Add sealed flag to l_netlink_message
Date: Fri, 26 Jul 2024 11:12:18 -0500
Message-ID: <20240726161232.146982-6-denkenz@gmail.com>
X-Mailer: git-send-email 2.45.2
In-Reply-To: <20240726161232.146982-1-denkenz@gmail.com>
References: <20240726161232.146982-1-denkenz@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

If the sealed flag is set, the message can no longer be modified.  This
is useful when netlink message ownership is taken over by l_netlink_send
to prevent the message from being modified once it has been queued.
---
 ell/netlink-private.h | 1 +
 ell/netlink.c         | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/ell/netlink-private.h b/ell/netlink-private.h
index b114f62f6bf3..f7119f6218e9 100644
--- a/ell/netlink-private.h
+++ b/ell/netlink-private.h
@@ -40,6 +40,7 @@ struct l_netlink_message {
 	};
 	uint32_t nest_offset[4];
 	uint8_t nest_level;
+	bool sealed : 1;
 };
 
 bool netlink_parse_ext_ack_error(const struct nlmsghdr *nlmsg,
diff --git a/ell/netlink.c b/ell/netlink.c
index 58dfd9779875..b6d5fb1fd36d 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -685,6 +685,9 @@ static int message_grow(struct l_netlink_message *message, uint32_t needed)
 {
 	uint32_t grow_to;
 
+	if (message->sealed)
+		return -EPERM;
+
 	if (message->size - message->hdr->nlmsg_len >= needed)
 		return 0;
 
-- 
2.45.2

