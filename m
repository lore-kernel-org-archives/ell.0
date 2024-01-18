Received: from mail-qk1-f178.google.com (mail-qk1-f178.google.com [209.85.222.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EBE631DA39
	for <ell@lists.linux.dev>; Thu, 18 Jan 2024 15:08:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1705590505; cv=none; b=fJABKSmunbDsyCB0JvMsLECuYkGL600sbF2uBX/hnpknqSv2ALvkJcCdWMFYCCuUGia3U/IlTDOh/hzC/3wPkeLIpgtEHXsTCUHsjATo8VwYSIzN/EDO3LVg5aefMym/aRJ/j1XTJwdpemHT64IoyGWb+5ewmY/YNFAuAU33pE4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1705590505; c=relaxed/simple;
	bh=61gmSOlYrqZVT/xR9oMBcTtbX5Zr4/QrLoe6V7K4AdI=;
	h=Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Google-Smtp-Source:X-Received:Received:From:
	 To:Cc:Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding; b=uyW3UX7FX+XPBMnxneuTnxY2GHaPdSHthwk/aLt/E1QXE+i59aW9OZ7dG8X98H+aNNEBcEZM68fpHjAHtRf+duVMTkd4AdXdeHywXeo44E5jyvNpuc3E+NM9wudzxp9Exm/SAvQPXARlAE7KQ6wkP23AoVEc5dWgpAR+SGaQ/vg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=gzdYUJzT; arc=none smtp.client-ip=209.85.222.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gzdYUJzT"
Received: by mail-qk1-f178.google.com with SMTP id af79cd13be357-78313f4d149so1219060485a.1
        for <ell@lists.linux.dev>; Thu, 18 Jan 2024 07:08:23 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1705590502; x=1706195302; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=gaPpdPi7IIxDHy22sVrAw81dv4Lxkb5c6xuX4spiFCs=;
        b=gzdYUJzThvAbtKOgWCdGWiffxs+v5Iz/+SKKfxuRG4kIocgE0gX5raBWQggYLedpa0
         /rHqT6YNKdkj6SwYobZxDNIrhEYfxOZde4X4iQVOe4xe/u6i1whnILBFdONKXgfjEGK/
         1WWH+ROYgWQ7Sw3RA3APDe4tBJrx1mqBNrebWszXXQvPGttrRqrkNeFYNor5Q0L9KtPi
         sW60YrvQ+bntvJm9KgMI2Pt6WzGG1ZgvJcIb0jSs0HCNPg8PC5EkpTSqjJoHDMT15Vp/
         aomfTr/entcv8XFJdJ3V3GW0rXCp+D3g6tdirNkD2gEPuA7TUO5vvIwWwXNwJX9IRP6Q
         Mrkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1705590502; x=1706195302;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=gaPpdPi7IIxDHy22sVrAw81dv4Lxkb5c6xuX4spiFCs=;
        b=Sh8ViknMvJpLsSt3p8Cb3B+z6NpXkDd2Y3zsmHIHcgSIMXXz8CvH+UQnOic1UeV7IB
         6Yid/7Xls/6XPKDRmaLmNXVDYHj4zTnm7ogZJXeYYr4KBsUAwOdGJN7S9rbx5799N7jX
         yxpkBn7VL/MJxcIqC/PITXRASbS6/6SWmewH80mlamAnT5qYPu962C3CfAHTyQFVO/F7
         F0J4fGhr0BxbapXJFUHX6+jkHCDy8SToWHMEX5APspgLUt/VtWVoAzEB/BjcJp57CwKZ
         D6ehqOFsKsH8Lh9d4/NNykhaGSlQimLtTc5960CaSHNYPx/GcuWMmj2OctC0ajKcRLWt
         pjnQ==
X-Gm-Message-State: AOJu0YzuCsQFtsWhJjh+lPEGkX7X8A5+rcXnle1XdXZrfZG3V2FpBp10
	39xdlr9d+O6c3WlzuXt67orL8Nq5uujk2VdjXuutXJziMMAej15Abhr+sWx1
X-Google-Smtp-Source: AGHT+IFYCLeE0ZyjoiDmGvJ78/SNqXVQXg0eshGGsPMPjAhuFzKtcT2PwNd5cUnXI+ZbWA1JZy/mzg==
X-Received: by 2002:ae9:e649:0:b0:783:4260:a080 with SMTP id x9-20020ae9e649000000b007834260a080mr959384qkl.132.1705590502531;
        Thu, 18 Jan 2024 07:08:22 -0800 (PST)
Received: from LOCLAP699.rst-02.locus ([208.195.13.130])
        by smtp.gmail.com with ESMTPSA id x22-20020a05620a099600b00781d3f29215sm5305798qkx.91.2024.01.18.07.08.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 18 Jan 2024 07:08:22 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v3] dhcp: add settable max attempts, fix timeout overflow to zero
Date: Thu, 18 Jan 2024 07:08:18 -0800
Message-Id: <20240118150818.49012-1-prestwoj@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

If DHCP is in a SELECTING/REQUESTING state and the number of attempts
reached a value where 2 << attempts overflowed an unsigned int the
next timeout would become zero, causing DHCP to never retry without
any event notification.

The number of attempts will now be configurable, but limited to
between 3 and 30 which prevents the bit shift from overflowing
'next_timeout' and provides some ultimate threshold where DHCP will
fail instead of try indefinitely.

A new event was added (L_DHCP_CLIENT_EVENT_MAX_ATTEMPTS_REACHED) to
notify netconfig of the situation. Netconfig will then send a failure
event and the consumer can decide how to proceed.

Fixes: f130c448 ("dhcp: Introduce timeout fuzzing")
---
 ell/dhcp.c      | 35 ++++++++++++++++++++++++++++++++---
 ell/dhcp.h      |  3 +++
 ell/ell.sym     |  1 +
 ell/netconfig.c |  6 ++++++
 4 files changed, 42 insertions(+), 3 deletions(-)

v3:
 * Added settable limit for attempts
 * Renamed "retries" to "attempts" for better clarity. "retries" implies
   some limit _after_ the first attmempt where "attempts" is much more
   clear in that it includes the first attempt as part of the limit.
 * DHCP is now limited to 30 attempts by default.

diff --git a/ell/dhcp.c b/ell/dhcp.c
index ece3e23..7d14ede 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -45,6 +45,8 @@
 	client->state = (s)
 
 #define BITS_PER_LONG (sizeof(unsigned long) * 8)
+#define CLIENT_MAX_ATTEMPT_LIMIT 30
+#define CLIENT_MIN_ATTEMPT_LIMIT 3
 
 enum dhcp_state {
 	DHCP_STATE_INIT,
@@ -159,6 +161,7 @@ struct l_dhcp_client {
 	uint32_t rtnl_add_cmdid;
 	struct l_rtnl_address *rtnl_configured_address;
 	uint8_t attempt;
+	uint8_t max_attempts;
 	l_dhcp_client_event_cb_t event_handler;
 	void *event_data;
 	l_dhcp_destroy_cb_t event_destroy;
@@ -558,9 +561,16 @@ static void dhcp_client_timeout_resend(struct l_timeout *timeout,
 		 * "The retransmission delay SHOULD be doubled with subsequent
 		 * retransmissions up to a maximum of 64 seconds.
 		 */
-		client->attempt += 1;
-		next_timeout = minsize(2 << client->attempt, 64);
-		break;
+		if (client->attempt < client->max_attempts) {
+			next_timeout = minsize(2 << client->attempt++, 64);
+			break;
+		}
+
+		CLIENT_DEBUG("Max request/discover attempts reached");
+
+		dhcp_client_event_notify(client,
+				L_DHCP_CLIENT_EVENT_MAX_ATTEMPTS_REACHED);
+		return;
 	case DHCP_STATE_INIT:
 	case DHCP_STATE_INIT_REBOOT:
 	case DHCP_STATE_REBOOTING:
@@ -988,6 +998,7 @@ LIB_EXPORT struct l_dhcp_client *l_dhcp_client_new(uint32_t ifindex)
 
 	client->state = DHCP_STATE_INIT;
 	client->ifindex = ifindex;
+	client->max_attempts = CLIENT_MAX_ATTEMPT_LIMIT;
 
 	/* Enable these options by default */
 	dhcp_enable_option(client, L_DHCP_OPTION_SUBNET_MASK);
@@ -1309,3 +1320,21 @@ LIB_EXPORT bool l_dhcp_client_set_rtnl(struct l_dhcp_client *client,
 	client->rtnl = rtnl;
 	return true;
 }
+
+LIB_EXPORT bool l_dhcp_client_set_max_attempts(struct l_dhcp_client *client,
+						uint8_t attempts)
+{
+	if (unlikely(!client))
+		return false;
+
+	if (unlikely(client->state != DHCP_STATE_INIT))
+		return false;
+
+	if (attempts < CLIENT_MIN_ATTEMPT_LIMIT ||
+				attempts > CLIENT_MAX_ATTEMPT_LIMIT)
+		return false;
+
+	client->max_attempts = attempts;
+
+	return true;
+}
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 6ce4dde..3d15f94 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -41,6 +41,7 @@ enum l_dhcp_client_event {
 	L_DHCP_CLIENT_EVENT_LEASE_EXPIRED,
 	L_DHCP_CLIENT_EVENT_LEASE_RENEWED,
 	L_DHCP_CLIENT_EVENT_NO_LEASE,
+	L_DHCP_CLIENT_EVENT_MAX_ATTEMPTS_REACHED,
 };
 
 enum l_dhcp_server_event {
@@ -73,6 +74,8 @@ bool l_dhcp_client_set_hostname(struct l_dhcp_client *client,
 
 bool l_dhcp_client_set_rtnl(struct l_dhcp_client *client,
 					struct l_netlink *rtnl);
+bool l_dhcp_client_set_max_attempts(struct l_dhcp_client *client,
+					uint8_t attempts);
 
 const struct l_dhcp_lease *l_dhcp_client_get_lease(
 					const struct l_dhcp_client *client);
diff --git a/ell/ell.sym b/ell/ell.sym
index a887b2b..e12fd0e 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -255,6 +255,7 @@ global:
 	l_dhcp_client_set_rtnl;
 	l_dhcp_client_set_hostname;
 	l_dhcp_client_get_lease;
+	l_dhcp_client_set_max_attempts;
 	l_dhcp_client_start;
 	l_dhcp_client_stop;
 	l_dhcp_client_set_event_handler;
diff --git a/ell/netconfig.c b/ell/netconfig.c
index ab59299..06a717f 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -548,6 +548,12 @@ static void netconfig_dhcp_event_handler(struct l_dhcp_client *client,
 		if (!l_dhcp_client_start(nc->dhcp_client))
 			netconfig_failed(nc, AF_INET);
 
+		break;
+	case L_DHCP_CLIENT_EVENT_MAX_ATTEMPTS_REACHED:
+		L_WARN_ON(nc->v4_configured);
+
+		netconfig_failed(nc, AF_INET);
+
 		break;
 	}
 }
-- 
2.34.1

