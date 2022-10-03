Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 948297B
	for <ell@lists.linux.dev>; Mon,  3 Oct 2022 22:29:02 +0000 (UTC)
Received: by mail-wr1-f47.google.com with SMTP id j7so13342628wrr.3
        for <ell@lists.linux.dev>; Mon, 03 Oct 2022 15:29:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date;
        bh=CrKNBnXAILvA9Ci9v32Smok3Yxnp1wH8M9yG7seoSF0=;
        b=7NDXXKRICiWXnTeQXTkWmyhHubJbs/pmcfuH6mXve6FjEz1F6pUHqel9V/Lz0EoXUW
         MQ/HQpKhS36rqOVEu90NQsFuPXgvpVngdz/SKiYmuQ19BsrUatDZhznpd5C0xOoIyl1E
         +ZyQ4jTPtgGlcKPKBGdjH/LeQ9oDoxTM4DEkXCkMiLIgL+0buPf68yXYq/V9X49a4CiQ
         EvY739v+S3gTUKPfrfK/WnYN/KOAfrJikZb2MGfB2eR07aydN3A9DZC/ywirZgUXXh8W
         SRACmR4bjniTa8cV8t63Znl0Wm3TNnHWGfhC1aGoGyq5r1M1DJXYF3TN+KyR7gX9Voji
         Cp+g==
X-Gm-Message-State: ACrzQf09dJgtlwv+uWeqFmZbafYwsUY8pBnV1exOeT4sVbipoo9Dilg+
	fBbjjUbkhK1ewQprupmZbcYN6d/4f1NVkQ==
X-Google-Smtp-Source: AMsMyM63QKMED2wdCgJXWQGiRfEVhRMda4K1OHJCV9kLXMemJDh8Ir/lZSGzpuCkh+ABjUyv41b4rg==
X-Received: by 2002:a05:6000:1566:b0:22e:2d99:76c3 with SMTP id 6-20020a056000156600b0022e2d9976c3mr7580478wrz.328.1664836140404;
        Mon, 03 Oct 2022 15:29:00 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id l9-20020a056000022900b0022b315b4649sm10434207wrz.26.2022.10.03.15.28.59
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 03 Oct 2022 15:28:59 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/5] dhcp6: Fix emitting LEASE_OBTAINED in stateless mode
Date: Tue,  4 Oct 2022 00:28:43 +0200
Message-Id: <20221003222847.699047-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Make sure we emit the LEASE_OBTAINED and not LEASE_RENEWED event after
obtaining a reply to an Information-Request.  Only set
client->request_na in stateful mode so as not to require the NA in the
lease object when we're later validating it.  Fix switching to BOUND
state after dhcp6_client_receive_reply() returns BOUND.
---
 ell/dhcp6.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 2792ff2..3dbd0cd 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -971,8 +971,9 @@ static void dhcp6_client_setup_lease(struct l_dhcp6_client *client,
 	client->lease->start_time = timestamp;
 
 	/* TODO: Emit IP_CHANGED if any addresses were removed / added */
-	if (client->state == DHCP6_STATE_REQUESTING ||
-			client->state == DHCP6_STATE_SOLICITING)
+	if (L_IN_SET(client->state, DHCP6_STATE_REQUESTING,
+				DHCP6_STATE_SOLICITING,
+				DHCP6_STATE_REQUESTING_INFORMATION))
 		event = L_DHCP6_CLIENT_EVENT_LEASE_OBTAINED;
 	else
 		event = L_DHCP6_CLIENT_EVENT_LEASE_RENEWED;
@@ -1385,7 +1386,8 @@ static void dhcp6_client_rx_message(const void *data, size_t len,
 	case DHCP6_STATE_BOUND:
 		return;
 	case DHCP6_STATE_REQUESTING_INFORMATION:
-		if (dhcp6_client_receive_reply(client, message, len) < 0)
+		r = dhcp6_client_receive_reply(client, message, len);
+		if (r < 0)
 			return;
 
 		break;
@@ -1527,7 +1529,6 @@ LIB_EXPORT struct l_dhcp6_client *l_dhcp6_client_new(uint32_t ifindex)
 
 	client->state = DHCP6_STATE_INIT;
 	client->ifindex = ifindex;
-	client->request_na = true;
 
 	client->icmp6 = l_icmp6_client_new(ifindex);
 	l_icmp6_client_add_event_handler(client->icmp6,
@@ -1803,6 +1804,8 @@ LIB_EXPORT bool l_dhcp6_client_start(struct l_dhcp6_client *client)
 	else
 		client_duid_generate_addr_plus_time(client);
 
+	client->request_na = !client->stateless;
+
 	if (!client->transport) {
 		client->transport =
 			_dhcp6_default_transport_new(client->ifindex,
-- 
2.34.1

