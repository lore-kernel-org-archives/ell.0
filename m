Received: from mail-qk1-f181.google.com (mail-qk1-f181.google.com [209.85.222.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 12DAD3B195
	for <ell@lists.linux.dev>; Thu, 11 Jan 2024 13:33:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JLcDR7vl"
Received: by mail-qk1-f181.google.com with SMTP id af79cd13be357-7831389c7daso427419585a.2
        for <ell@lists.linux.dev>; Thu, 11 Jan 2024 05:33:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1704980015; x=1705584815; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=Mc2BGraBkjUiLgyjiI/DYcl5yg7mOxTpE7J1NNLYt+0=;
        b=JLcDR7vleutdRMRsSl0gi4nXkWxzyXmw/0X8/Fea47hUEGcmyl3nucAryt9n9ybEWS
         YMxocE2MaBAS34GvRXwq1JkXGc+hknY7KMxb1aveXKY36LRPZVJw7sm8nUwjEEATW2KC
         HVJ+RYoEDdeQaYXQ+i5sXqTSgiFPE2Vh7bpWxxS+04pX30L/YVbsyf1X7dT4CLkzqpp2
         EZEcZ+5YECfyOWQ5TCeL37vJIC1zJcDU6ORb6/18JcSfYNMqQJH+iFsm84XNptEEqOZ/
         9eYKsg9YqG2L40YCumBr9dNQfEXcdIKI+TNO7coUOyOxNt+RSwDH52f61WdkMd4Vijan
         qYKw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1704980015; x=1705584815;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=Mc2BGraBkjUiLgyjiI/DYcl5yg7mOxTpE7J1NNLYt+0=;
        b=cqT4i97QUqfdOXBsrfkSkadcWQz6rY2JdagLRgCjYDU7Vaxc0LP+59Q9WBd1hSazTn
         94v6m12QpUGA9IsEU8H6TpRPjjXNNQrTbE0+bfeIwLbj2LiNd2PR2BSKnVWoUbVSffiP
         64zRkvTpcBZJkbq7SQmRacnjlXUYy4263EOFviwamqty3CVDCAtokdNaOJU7hJuOJzHn
         i0Rrx4B+kABoSshPZD3UnWC5ACbT6c1QeUytA2btH+GuQJUFk9Nw0RjLcyTcJYEO1mAT
         tpc1Zt8HyeHxLtkfA8eJ7eJnLwQo836vvr3yoehv4+WOj8sNZMyXnOOWfJ81KWjICU0m
         KXqw==
X-Gm-Message-State: AOJu0YzvbpIvnf5axkJHw5NQ/CQk/Ql8IKjUKxP9APnSXV1nVmAnDt2k
	zTxSA6d+EJ8TPBt92Ba3QBUR04DwXd0=
X-Google-Smtp-Source: AGHT+IG02JOzbHHkDpRosTzVcze6OwlsL1yFjGc4jAucXykH/eOnF5uprQ3wvVPYlCP1yP62bL0jtw==
X-Received: by 2002:a05:6214:5001:b0:67f:6ea8:b2a1 with SMTP id jo1-20020a056214500100b0067f6ea8b2a1mr1165393qvb.19.1704980015623;
        Thu, 11 Jan 2024 05:33:35 -0800 (PST)
Received: from LOCLAP699.rst-02.locus (50-78-19-50-static.hfc.comcastbusiness.net. [50.78.19.50])
        by smtp.gmail.com with ESMTPSA id dz19-20020ad45893000000b00680b1a92322sm301238qvb.77.2024.01.11.05.33.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 11 Jan 2024 05:33:35 -0800 (PST)
From: James Prestwood <prestwoj@gmail.com>
To: ell@lists.linux.dev
Cc: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH v2] dhcp: fix overflow causing retries to stop
Date: Thu, 11 Jan 2024 05:33:31 -0800
Message-Id: <20240111133331.1423853-1-prestwoj@gmail.com>
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

Roughly 2 minutes has passed when we reach >5 attempts so it makes
little sense to retry indefinitely, at least without notifying the
upper layers (which could decided to retry themselves).

Add a new event L_DHCP_CLIENT_EVENT_MAX_RETRIES_REACHED to notify
netconfig of the situation. Netconfig will then send a failure event
and the consumer can decide how to proceed.

Fixes: f130c448 ("dhcp: Introduce timeout fuzzing")
---
 ell/dhcp.c      | 19 ++++++++++++++++---
 ell/dhcp.h      |  1 +
 ell/netconfig.c |  6 ++++++
 3 files changed, 23 insertions(+), 3 deletions(-)

v2:
 * Added new event instead of retry forever.

diff --git a/ell/dhcp.c b/ell/dhcp.c
index ece3e23..79fc54c 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -557,10 +557,23 @@ static void dhcp_client_timeout_resend(struct l_timeout *timeout,
 		 * RFC 2131 Section 4.1:
 		 * "The retransmission delay SHOULD be doubled with subsequent
 		 * retransmissions up to a maximum of 64 seconds.
+		 *
+		 * The maximum is hit after 5 attempts (2 << 5 == 64)
 		 */
-		client->attempt += 1;
-		next_timeout = minsize(2 << client->attempt, 64);
-		break;
+		if (client->attempt <= 5) {
+			next_timeout = 2 << client->attempt++;
+			break;
+		}
+
+		/*
+		 * DHCP server is non-responsive after ~2 minutes, relay this to
+		 * upper layers do decide how to proceed
+		 */
+		CLIENT_DEBUG("Max request/discover retires reached");
+
+		dhcp_client_event_notify(client,
+				L_DHCP_CLIENT_EVENT_MAX_RETRIES_REACHED);
+		return;
 	case DHCP_STATE_INIT:
 	case DHCP_STATE_INIT_REBOOT:
 	case DHCP_STATE_REBOOTING:
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 6ce4dde..4db573d 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -41,6 +41,7 @@ enum l_dhcp_client_event {
 	L_DHCP_CLIENT_EVENT_LEASE_EXPIRED,
 	L_DHCP_CLIENT_EVENT_LEASE_RENEWED,
 	L_DHCP_CLIENT_EVENT_NO_LEASE,
+	L_DHCP_CLIENT_EVENT_MAX_RETRIES_REACHED,
 };
 
 enum l_dhcp_server_event {
diff --git a/ell/netconfig.c b/ell/netconfig.c
index ab59299..1e6912a 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -548,6 +548,12 @@ static void netconfig_dhcp_event_handler(struct l_dhcp_client *client,
 		if (!l_dhcp_client_start(nc->dhcp_client))
 			netconfig_failed(nc, AF_INET);
 
+		break;
+	case L_DHCP_CLIENT_EVENT_MAX_RETRIES_REACHED:
+		L_WARN_ON(nc->v4_configured);
+
+		netconfig_failed(nc, AF_INET);
+
 		break;
 	}
 }
-- 
2.34.1

