Received: from mail-wr1-f54.google.com (mail-wr1-f54.google.com [209.85.221.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C15B5EC09
	for <ell@lists.linux.dev>; Wed,  9 Nov 2022 17:47:58 +0000 (UTC)
Received: by mail-wr1-f54.google.com with SMTP id o4so26927675wrq.6
        for <ell@lists.linux.dev>; Wed, 09 Nov 2022 09:47:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=nenqb8EuS5yI/YfUN+XbLGRrn8OiyE/ZnYXuKMcrn4M=;
        b=CPJc9SmvdhO4uMhMtyLtQB0YnAOpx3zLp9BhcWZtM+2LUkkvM1GXVYYc8LKb46PHHB
         B7wFiQ1r24yho7bhIH1fXMN8ZIaKRvB4x21/Wf9T+lRWR+lzMLqkjJc3TtztIEC5tTsl
         bdtFdqi1oDPMfq8jqbuS2KZqdVxcwirhO8TTSE62FN+KOhzG2+Lu/VO/zKuLbju3mLYN
         0aTNrD+A3cJJVmgBO4FoAtZE/LDhivRZa/InV3Eycg/gI2mjY04kV6gc1ptnSyuR664q
         1VE7KVhNDAKoTgH4Nw97yjoVtwI8KVe6P9NT5RKKSBPChaE2nrg1dxrvUKNMI8CSi6gK
         sNPg==
X-Gm-Message-State: ACrzQf0oQ2haRm9F+LHjEipJPph7wNxx67FiDpKsMo6MXRJAN4REoOhV
	wENYdP3BVNTHlpE9E/FOL5wmzf8QEy4=
X-Google-Smtp-Source: AMsMyM5tsl0iYZFbjeO9JDRDqT9WdIxuO4HMeJAck3OMLCin2gFivO25BA8sL15NDfGpMtSCVrCnSw==
X-Received: by 2002:a5d:498f:0:b0:236:55e9:6c16 with SMTP id r15-20020a5d498f000000b0023655e96c16mr40094418wrq.331.1668016076330;
        Wed, 09 Nov 2022 09:47:56 -0800 (PST)
Received: from localhost.localdomain ([82.213.230.158])
        by smtp.gmail.com with ESMTPSA id bh2-20020a05600005c200b002366d1cc198sm13934567wrb.41.2022.11.09.09.47.55
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Nov 2022 09:47:55 -0800 (PST)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH 1/4] tls: Allow ServerHello extensions when resuming session
Date: Wed,  9 Nov 2022 18:47:43 +0100
Message-Id: <20221109174746.569046-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

While, as the spec notes, most extensions are not used during the
resumption of a cached session (are offered in the ClientHello but are
ignored and not be included in the ServerHello), this not a rule so allow
each extension to decide whether to skip adding itself to the ServerHello.

Specifically those extensions should rather be ignored by the server
when it is parsing the ClientHello but at that point we don't yet know
whether we'll allow the session to be resumed so instead the ServerHello
writer callbacks decide whether to reply or not.  As an example RFC 4492
Section 4 says: "In the case of session resumption, the server simply
ignores the Supported Elliptic Curves Extension and the Supported Point
Formats Extension appearing in the current ClientHello message.  These
extensions only play a role during handshakes negotiating a new session."
---
 ell/tls-extensions.c |  9 +++++++++
 ell/tls.c            | 31 ++++++++++---------------------
 2 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/ell/tls-extensions.c b/ell/tls-extensions.c
index 7796825..d03c331 100644
--- a/ell/tls-extensions.c
+++ b/ell/tls-extensions.c
@@ -31,6 +31,13 @@
 #include "cert.h"
 #include "tls-private.h"
 
+/* Most extensions are not used when resuming a cached session */
+#define SKIP_ON_RESUMPTION()	\
+	do {	\
+		if (tls->session_id_size && !tls->session_id_new)	\
+			return -ENOMSG;	\
+	} while (0);
+
 /* RFC 7919, Section A.1 */
 static const uint8_t tls_ffdhe2048_prime[] = {
 	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xad, 0xf8, 0x54, 0x58,
@@ -560,6 +567,8 @@ static bool tls_ec_point_formats_client_handle(struct l_tls *tls,
 static ssize_t tls_ec_point_formats_server_write(struct l_tls *tls,
 						uint8_t *buf, size_t len)
 {
+	SKIP_ON_RESUMPTION(); /* RFC 4492 Section 4 */
+
 	if (len < 2)
 		return -ENOMEM;
 
diff --git a/ell/tls.c b/ell/tls.c
index 98bc682..5f3b717 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -2053,11 +2053,8 @@ static void tls_handle_client_hello(struct l_tls *tls,
 			tls_load_cached_server_session(tls, buf + 35,
 							session_id_size)) {
 		/*
-		 * Attempt a session resumption but don't skip parsing Hello
-		 * extensions just yet because we may decide to start a new
-		 * session instead after our cipher suite and compression
-		 * method checks below and in that case we will need to
-		 * handle the extensions and include them in the Server Hello.
+		 * Attempt a session resumption but note later checks may
+		 * spoil this.
 		 */
 		resuming = true;
 		session_id_str = l_util_hexstring(tls->session_id,
@@ -2228,7 +2225,7 @@ static void tls_handle_client_hello(struct l_tls *tls,
 		l_getrandom(tls->session_id, 32);
 	}
 
-	if (!tls_send_server_hello(tls, resuming ? extensions_offered : NULL))
+	if (!tls_send_server_hello(tls, extensions_offered))
 		goto cleanup;
 
 	l_queue_destroy(extensions_offered, NULL);
@@ -2324,23 +2321,16 @@ static void tls_handle_server_hello(struct l_tls *tls,
 			TLS_DEBUG("Negotiated resumption of cached session %s",
 					session_id_str);
 			resuming = true;
-
-			/*
-			 * Skip parsing extensions as none of the ones we
-			 * support are used in session resumption.  We could
-			 * as well signal an error if the ServerHello has any
-			 * extensions, for now ignore them.
-			 */
-			goto check_version;
+		} else {
+			TLS_DEBUG("Server decided not to resume cached session "
+					"%s, sent %s session ID",
+					session_id_str,
+					session_id_size ? "a new" : "no");
+			tls->session_id_size = 0;
 		}
-
-		TLS_DEBUG("Server decided not to resume cached session %s, "
-				"sent %s session ID", session_id_str,
-				session_id_size ? "a new" : "no");
-		tls->session_id_size = 0;
 	}
 
-	if (session_id_size && tls->session_settings) {
+	if (session_id_size && !resuming && tls->session_settings) {
 		tls->session_id_new = true;
 		tls->session_id_size = session_id_size;
 		memcpy(tls->session_id, buf + 35, session_id_size);
@@ -2354,7 +2344,6 @@ static void tls_handle_server_hello(struct l_tls *tls,
 	if (!result)
 		return;
 
-check_version:
 	if (version < tls->min_version || version > tls->max_version) {
 		TLS_DISCONNECT(version < tls->min_version ?
 				TLS_ALERT_PROTOCOL_VERSION :
-- 
2.34.1

