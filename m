Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 638EDA490
	for <ell@lists.linux.dev>; Wed,  9 Nov 2022 17:48:00 +0000 (UTC)
Received: by mail-wm1-f43.google.com with SMTP id p16so11324978wmc.3
        for <ell@lists.linux.dev>; Wed, 09 Nov 2022 09:48:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=a8vwBraGRA/dhXuiy+T63nv5ysR182QLk2bEBU0QJzA=;
        b=NXIeCP9OwYfODHEiU9r6SLa9WFlwZodcZymQTLOFt9APTRuAbbi7q2KfkWJhG8yfJK
         Da1XOIfQjlyPI/3G5lHwspsftJTQRadtXe+hYyoa6j9lkrwC+EPndWIr9la0wq3ZaNVJ
         p4pS/Hw/ilKuVfY9qSBWpTCShckXztMv07cDTjAKTQUy/ia0BD2GXPt6h4b2wZldbqrS
         PFY8RT56o8Awn1A/MUAWYNaPHW934sXjZkKcqn6JDs+M2RpZielBq4ib0E4LHw8s7KUr
         ew7Kx0P+veZ5cAM4C346gOjJM8DcINSi7UZrbDoc1b9BdbV9MIyHfW6hFq+ijzFjmPh6
         x/eg==
X-Gm-Message-State: ACrzQf0Eif9KDGFcBLKVguukIqgPiMInJWfF8Ba+BHX/WzyIz8S+Tfnn
	xEDsqpTag2g1FSdSf+/IlIcDL4sVg3c=
X-Google-Smtp-Source: AMsMyM7WCpZeYXlUOUo2SPfBxi7vwUvVvRr+Q29UbKyJICLhLzaQIyCt/LI3d6fXgEDt0tP7GNb8cw==
X-Received: by 2002:a7b:cd91:0:b0:3cf:47e7:c8bd with SMTP id y17-20020a7bcd91000000b003cf47e7c8bdmr52241822wmj.139.1668016077879;
        Wed, 09 Nov 2022 09:47:57 -0800 (PST)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id bh2-20020a05600005c200b002366d1cc198sm13934567wrb.41.2022.11.09.09.47.56
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Nov 2022 09:47:56 -0800 (PST)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 2/4] tls: Improve renegotiation
Date: Wed,  9 Nov 2022 18:47:44 +0100
Message-Id: <20221109174746.569046-2-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20221109174746.569046-1-andrew.zaborowski@intel.com>
References: <20221109174746.569046-1-andrew.zaborowski@intel.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On client, allow renegotiation triggered by the server.  Make sure to
reset tls->peer_authenticated before a new handshake.  Avoid calling the
ready callback multiple times, only call it after initial handshake.
While RFC 5746 makes the case for TLS APIs to inform the application
layer of renegotiations, some ell users don't consider the possiblity of
the ready callback happening more than once in a session and the name
implies that the TLS tunnel wasn't ready before the call.
---
 ell/tls.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/ell/tls.c b/ell/tls.c
index 5f3b717..14c8550 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -198,6 +198,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 	tls->peer_cert = NULL;
 	tls->peer_pubkey = NULL;
 	tls->peer_pubkey_size = 0;
+	tls->peer_authenticated = false;
 	tls->negotiated_curve = NULL;
 	tls->negotiated_ff_group = NULL;
 
@@ -2898,6 +2899,7 @@ static void tls_finished(struct l_tls *tls)
 	uint64_t peer_cert_expiry;
 	bool resuming = tls->session_id_size && !tls->session_id_new;
 	bool session_update = false;
+	bool renegotiation = tls->ready;
 
 	if (tls->peer_authenticated && !resuming) {
 		peer_cert_identity = tls_get_peer_identity_str(tls->peer_cert);
@@ -2998,9 +3000,11 @@ static void tls_finished(struct l_tls *tls)
 			return;
 	}
 
-	tls->in_callback = true;
-	tls->ready_handle(peer_identity, tls->user_data);
-	tls->in_callback = false;
+	if (!renegotiation) {
+		tls->in_callback = true;
+		tls->ready_handle(peer_identity, tls->user_data);
+		tls->in_callback = false;
+	}
 
 	tls_cleanup_handshake(tls);
 }
@@ -3033,7 +3037,16 @@ static void tls_handle_handshake(struct l_tls *tls, int type,
 		 * and "MAY be ignored by the client if it does not wish to
 		 * renegotiate a session".
 		 */
+		if (tls->state != TLS_HANDSHAKE_DONE) {
+			TLS_DEBUG("Message invalid in state %s",
+					tls_handshake_state_to_str(tls->state));
+			break;
+		}
+
+		if (!tls_send_client_hello(tls))
+			break;
 
+		TLS_SET_STATE(TLS_HANDSHAKE_WAIT_HELLO);
 		break;
 
 	case TLS_CLIENT_HELLO:
-- 
2.34.1

