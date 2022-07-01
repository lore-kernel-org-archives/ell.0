Received: from mail-lj1-f181.google.com (mail-lj1-f181.google.com [209.85.208.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2728F1871
	for <ell@lists.linux.dev>; Fri,  1 Jul 2022 13:32:46 +0000 (UTC)
Received: by mail-lj1-f181.google.com with SMTP id l7so1912630ljj.4
        for <ell@lists.linux.dev>; Fri, 01 Jul 2022 06:32:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=4yhvNPxQbStgkKWfMv2II9x6lR9oJSRsLjXfA0v/NJM=;
        b=bTaKFNJMCJd6YnFKgV1cUis9ZCHo1c0RtrD7qWY9LTkcHAcoNDQog5OloJNyex831g
         EuYIFjzM1CMwYy9FOLyxOyOk/8nmhDwu6coOWQH7wIDIoGjT4DAW4z7Vqe8eZI/KBmo7
         x0IY4/nuMHCImhnmDkLalsbrfosnXeE9IPoP3KuPfO6xKSM12M+0k5/ten9tTnMQJpHD
         H7ZkQ6MnTongYs4wpowaJ1Cdo/8l24JBFvoU34aFNNAbXQhnCLpXCo1ul0tVVt30a+ZR
         vY6K6n0CRP1I0GXUC9DbZf3FiuszYpB56Bdh1OwDSoQsV1QyjWfWg3QuWDMPW+rb3H5D
         7K6A==
X-Gm-Message-State: AJIora8cEijavX678VctejOHtcVQtScFVsT/cX9FbJWLzJT5RYoOzp/w
	tiVM2kuIIB/hqwR05XfWY67OC6yRoUn2rYmp
X-Google-Smtp-Source: AGRyM1u02kA5FIwKEzrQsaHwGByh7MPcFYmn+to+1oTtW7iY51t7QieMbB6HnPgczT7P02LEoSID/g==
X-Received: by 2002:a2e:a54a:0:b0:25a:6609:835a with SMTP id e10-20020a2ea54a000000b0025a6609835amr8225527ljn.408.1656682363797;
        Fri, 01 Jul 2022 06:32:43 -0700 (PDT)
Received: from iss.home (79.184.238.213.ipv4.supernova.orange.pl. [79.184.238.213])
        by smtp.gmail.com with ESMTPSA id 11-20020a05651c128b00b0025a725af81csm3185815ljc.39.2022.07.01.06.32.43
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 01 Jul 2022 06:32:43 -0700 (PDT)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/4] dhcp: Set lease->bound_time before emitting event
Date: Fri,  1 Jul 2022 15:32:34 +0200
Message-Id: <20220701133237.2887854-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The event handler for L_DHCP_CLIENT_EVENT_LEASE_OBTAINED/RENEWED will
want to use the new lease->bound_time value for expiry time calculation
to we need to set it before we emit the events in the DHCP ACK handler.
---
 ell/dhcp.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index f9c0826..afd5c34 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -898,6 +898,7 @@ static void dhcp_client_rx_message(const void *data, size_t len, void *userdata,
 		CLIENT_ENTER_STATE(DHCP_STATE_BOUND);
 		l_timeout_remove(client->timeout_resend);
 		client->timeout_resend = NULL;
+		client->lease->bound_time = timestamp;
 
 		if (client->transport->bind) {
 			e = client->transport->bind(client->transport,
@@ -910,8 +911,6 @@ static void dhcp_client_rx_message(const void *data, size_t len, void *userdata,
 
 		dhcp_client_event_notify(client, r);
 
-		client->lease->bound_time = timestamp;
-
 		/*
 		 * Start T1, once it expires we will start the T2 timer.  If
 		 * we renew the lease, we will end up back here.
-- 
2.34.1

