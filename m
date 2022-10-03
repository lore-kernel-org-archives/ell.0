Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A609833D9
	for <ell@lists.linux.dev>; Mon,  3 Oct 2022 22:29:05 +0000 (UTC)
Received: by mail-wr1-f47.google.com with SMTP id j7so13342798wrr.3
        for <ell@lists.linux.dev>; Mon, 03 Oct 2022 15:29:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date;
        bh=YMlLnTf3srE3i5/B/X2C9Q8R1Z+Y0QSr7luB+e7ADrQ=;
        b=wwqrbK0FXm+79nw377Ll8GehYwvvsLObDGlkXlFNNzcNfzZcEbU08z65Vln5ozYWbh
         CF6noKIM1MAonAyZlaUdd6rwAnQBcFg+H+KgqmFtmUXFMrhnehPwZb/YlJ9FdahJQ8+4
         Tye6+MME0qPd5DOTMjq24Ti5qXyFTbpOHf8nQ1DiVZClwiqTvf5iSmxspkePCKKTUy6W
         cPocrd3Kdp29yK4SvD5bXZYE1dFrYcjSHhHjOsEBrEaNaNjCAeF/3EhX1TrRVXrggWki
         qeGQL5rw+kmsAMsd73F/C8l4vAUL3+mUPFsrgDP2pJ2jqNYUmUva80X1rXfafnMzYsEh
         Y3rg==
X-Gm-Message-State: ACrzQf2mYD7QKzggH+PItQfbNENhypDhDsW7NUt7Ts6pY+Ugi9+b7rfI
	/XmBnEaZnXhmlzOZL5sZZPBobBHVX2ThLg==
X-Google-Smtp-Source: AMsMyM7VGCMUtf6smTaEMvE6/pn+bOaPCxnj4ItJlOkG3rnPvlTr3HWIPBKR7UXjiy5q6W03k2MxPw==
X-Received: by 2002:a5d:404b:0:b0:22e:331e:1cba with SMTP id w11-20020a5d404b000000b0022e331e1cbamr6447593wrp.488.1664836144902;
        Mon, 03 Oct 2022 15:29:04 -0700 (PDT)
Received: from localhost.localdomain ([82.213.228.103])
        by smtp.gmail.com with ESMTPSA id l9-20020a056000022900b0022b315b4649sm10434207wrz.26.2022.10.03.15.29.03
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 03 Oct 2022 15:29:04 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 5/5] dhcp6: Don't require Client ID in Information-request reply
Date: Tue,  4 Oct 2022 00:28:47 +0200
Message-Id: <20221003222847.699047-5-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221003222847.699047-1-andrew.zaborowski@intel.com>
References: <20221003222847.699047-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Since we don't include our Client ID option when sending an
Information-request, the server can't send it back in its Reply.  Don't
require it when validating.
RFC 8415 Section 18.2.6 has this to say about the Client ID:

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
 ell/dhcp6.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/ell/dhcp6.c b/ell/dhcp6.c
index 3dbd0cd..a17dc49 100644
--- a/ell/dhcp6.c
+++ b/ell/dhcp6.c
@@ -1098,6 +1098,7 @@ bool _dhcp6_option_iter_next(struct dhcp6_option_iter *iter, uint16_t *type,
 }
 
 static int dhcp6_client_validate_message(struct l_dhcp6_client *client,
+					bool expect_client_id,
 					const struct dhcp6_message *message,
 					size_t len)
 {
@@ -1205,7 +1206,7 @@ static int dhcp6_client_validate_message(struct l_dhcp6_client *client,
 		}
 	}
 
-	if (!duid_verified) {
+	if (expect_client_id && !duid_verified) {
 		CLIENT_DEBUG("Message %s - no client id option found", mstr);
 		return -EBADMSG;
 	}
@@ -1229,7 +1230,7 @@ static int dhcp6_client_receive_advertise(struct l_dhcp6_client *client,
 	if (advertise->msg_type != DHCP6_MESSAGE_TYPE_ADVERTISE)
 		return -EINVAL;
 
-	r = dhcp6_client_validate_message(client, advertise, len);
+	r = dhcp6_client_validate_message(client, true, advertise, len);
 	if (r < 0)
 		return r;
 
@@ -1311,11 +1312,17 @@ static int dhcp6_client_receive_reply(struct l_dhcp6_client *client,
 	struct l_dhcp6_lease *lease;
 	struct dhcp6_option_iter iter;
 	int r;
+	/*
+	 * Per RFC 7844 Section 4.3.1 we never send Client ID options in
+	 * Information-requests so don't expect the replies to contain them.
+	 */
+	bool expect_client_id =
+		(client->state != DHCP6_STATE_REQUESTING_INFORMATION);
 
 	if (reply->msg_type != DHCP6_MESSAGE_TYPE_REPLY)
 		return -EINVAL;
 
-	r = dhcp6_client_validate_message(client, reply, len);
+	r = dhcp6_client_validate_message(client, expect_client_id, reply, len);
 	if (r < 0)
 		return r;
 
-- 
2.34.1

