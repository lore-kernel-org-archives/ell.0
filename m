Received: from mail-wm1-f51.google.com (mail-wm1-f51.google.com [209.85.128.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 69B7233C7
	for <ell@lists.linux.dev>; Fri, 30 Sep 2022 13:53:15 +0000 (UTC)
Received: by mail-wm1-f51.google.com with SMTP id c192-20020a1c35c9000000b003b51339d350so5079250wma.3
        for <ell@lists.linux.dev>; Fri, 30 Sep 2022 06:53:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date;
        bh=vpFAl3rqIU1iYzhZEiuF5G4ulQ+7hkV9H48xUc5Lkgw=;
        b=xw8e2r5uCgxdB0bBksWQlaLRZxboKhG3xrYK213x68B6L3fqt7acdizKcjpr4MnLQg
         5ecXWK0nab93S2IOGd+TnXMnG757GFRbcM6itwd5/+Qfx7eTM5VhgTPEvMMCnIQa2lQ+
         uoqSOGGR0W4NjQMLNpS8Fg7Cxx9bjUlu0cvhBSO4Oiq1KlFNHZHR30JanbgPKPhKJ7OR
         XGyoUZx/hhZSslMjbXZlQvt+UrC2jDHiVNzLoDM0BM+Zv4IAr14RjP5qtYcZB+sTD5rl
         Lm0iKwL4p56pD8Y0pxCSswq9SW81Vtm4FPCO5EBLn2nPhOoDRiUiNhDWNXePJq7Lvx0W
         gWeQ==
X-Gm-Message-State: ACrzQf1febIE037FaS9Xiz2nYgAWiX1W8lFILoVM34TjIcFQqei3pbHA
	sytslJPApuAFEC+cdhW2c5tP1qirVqs=
X-Google-Smtp-Source: AMsMyM5OwLSQNgMoxpia3luQUP4wu5gkXIZK6S3TDdwShmFSAQUKZknMkehxGu8P13zKn1x2lsg1Hw==
X-Received: by 2002:a7b:c40e:0:b0:3b3:3faa:10c2 with SMTP id k14-20020a7bc40e000000b003b33faa10c2mr6100954wmi.32.1664545993270;
        Fri, 30 Sep 2022 06:53:13 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id p5-20020a05600c1d8500b003b492b30822sm2249801wms.2.2022.09.30.06.53.12
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Sep 2022 06:53:12 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/5] dhcp6: Include Client ID in Information-Request
Date: Fri, 30 Sep 2022 15:52:46 +0200
Message-Id: <20220930135250.534296-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The Reply parser requires that the Client ID be present in the Reply but
the server only includes that if the Information-Request included the
Client ID.  RFC 8415 Section 18.2.6 has this to say about the Client ID:

"The client SHOULD include a Client Identifier option (see Section 21.2)
to identify itself to the server (however, see Section 4.3.1 of [RFC7844]
for reasons why a client may not want to include this option).  If the
client does not include a Client Identifier option, the server will not
be able to return any client-specific options to the client, or the
server may choose not to respond to the message at all."

RFC 7833 Section 4.3.1 says this:
"When using stateless DHCPv6, clients wanting to protect their privacy
SHOULD NOT include client identifiers in their Information-request
messages.  This will prevent the server from specifying client-specific
options if it is configured to do so, but the need for anonymity
precludes such options anyway."
---
The obvious alternative is to not include the Client ID and not require
it in the Reply validation, or make this configurable to avoid privacy
concerns.  I'm happy to go with either of these options.

 ell/dhcp6.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 2792ff2..0705a7b 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -738,6 +738,8 @@ static int dhcp6_client_send_information_request(struct l_dhcp6_client *client)
 	option_append_elapsed_time(builder, client->transaction_start_t);
 	option_append_option_request(builder, client->request_options,
 					DHCP6_STATE_REQUESTING_INFORMATION);
+	option_append_bytes(builder, DHCP6_OPTION_CLIENT_ID,
+					client->duid, client->duid_len);
 
 	information_request = dhcp6_message_builder_free(builder, false,
 						&information_request_len);
-- 
2.34.1

