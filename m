Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E2FB233D6
	for <ell@lists.linux.dev>; Fri, 30 Sep 2022 13:53:15 +0000 (UTC)
Received: by mail-wm1-f44.google.com with SMTP id iv17so2968655wmb.4
        for <ell@lists.linux.dev>; Fri, 30 Sep 2022 06:53:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=zfQrYDdRxoyURg/S7DaWn6z2piQ7bNf26UxoiAoEFUQ=;
        b=UUVOkEsLYxklHFbbA3PhXJtJtlBJEaSROXRIqdX/l5BR/2/L4m1lmm5jJ2DDS+HSLB
         HsT3EkbfgX66iZHLb9oqQGte4sk0TgfYt7i+yH2cgTRi8L3mhtSAB/f69PbZkGF7oHnB
         4c2XGiBzqY7FsuPub1W5v9oXFzzzSaAyKmOwhVQBkkRtHk6DTte2Ed3xEgurqmCD1ZNT
         qbz7lNqH2hG/xc/QB1XFATipucmUE0hJPGozUy9mhAEfIsdKntEF6LS1HlGThtPMU3dx
         H/EeSkXNNM0Glma4IctK9TQyCNRfbsLTZkwawBogbVlDZsBWBrNet/Z8FYbtpn0ssXqY
         BGQg==
X-Gm-Message-State: ACrzQf0DYg9TpsASqhqOu9Vy0poLFR99f2Akpm1bwyxOmttI9catjChy
	vqJIqSQcQEY++Idm5I6mNGdK7FnAcRM=
X-Google-Smtp-Source: AMsMyM6V3Y/tMU7PtV/ps/9yKMkqSfES6YWhIyl3La8/ImSZp0/1hZYBLXP/HSVXT0nOJ+cvC6QXBw==
X-Received: by 2002:a05:600c:548b:b0:3b5:95b:57d3 with SMTP id iv11-20020a05600c548b00b003b5095b57d3mr14527823wmb.153.1664545993995;
        Fri, 30 Sep 2022 06:53:13 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id p5-20020a05600c1d8500b003b492b30822sm2249801wms.2.2022.09.30.06.53.13
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Sep 2022 06:53:13 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/5] dhcp6: Fix emitting LEASE_OBTAINED in stateless mode
Date: Fri, 30 Sep 2022 15:52:47 +0200
Message-Id: <20220930135250.534296-2-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20220930135250.534296-1-andrew.zaborowski@intel.com>
References: <20220930135250.534296-1-andrew.zaborowski@intel.com>
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
index 0705a7b..a4c13ee 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -973,8 +973,9 @@ static void dhcp6_client_setup_lease(struct l_dhcp6_client *client,
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
@@ -1387,7 +1388,8 @@ static void dhcp6_client_rx_message(const void *data, size_t len,
 	case DHCP6_STATE_BOUND:
 		return;
 	case DHCP6_STATE_REQUESTING_INFORMATION:
-		if (dhcp6_client_receive_reply(client, message, len) < 0)
+		r = dhcp6_client_receive_reply(client, message, len);
+		if (r < 0)
 			return;
 
 		break;
@@ -1529,7 +1531,6 @@ LIB_EXPORT struct l_dhcp6_client *l_dhcp6_client_new(uint32_t ifindex)
 
 	client->state = DHCP6_STATE_INIT;
 	client->ifindex = ifindex;
-	client->request_na = true;
 
 	client->icmp6 = l_icmp6_client_new(ifindex);
 	l_icmp6_client_add_event_handler(client->icmp6,
@@ -1805,6 +1806,8 @@ LIB_EXPORT bool l_dhcp6_client_start(struct l_dhcp6_client *client)
 	else
 		client_duid_generate_addr_plus_time(client);
 
+	client->request_na = !client->stateless;
+
 	if (!client->transport) {
 		client->transport =
 			_dhcp6_default_transport_new(client->ifindex,
-- 
2.34.1

