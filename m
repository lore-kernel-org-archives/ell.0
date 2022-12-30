Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com [209.85.167.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94FB128F7
	for <ell@lists.linux.dev>; Fri, 30 Dec 2022 16:47:12 +0000 (UTC)
Received: by mail-lf1-f44.google.com with SMTP id g13so32360978lfv.7
        for <ell@lists.linux.dev>; Fri, 30 Dec 2022 08:47:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=JQmrTeVooE9oaOrlhM07p9LLMJr/69dct41uZ6gwKI4=;
        b=2CgOSqgGq7yc2NuESo6oyDoKKjadlo4HmqZIqlyEkJj3yAXci8PxAsKF+ed+lYPW2h
         /tdtqXjFATvamarXHYjRrIElIKV8vDwT4Nl9oC+vDnYd7O8r1rIBZIQVG82PMPVaJVkL
         hsRZwN+r/j+Oe6RqnBbZZZWizM0MvygTB/Z7R51XG8oaQLJVbdxxIjBj/YeDKK5Ras7C
         LSut4nE90k/5ZUMaDnQwCyGt5aZU3N3FqjUBUq4E4G3cZ97SLHsm8x5N68hlkJ/LH/LI
         d9oMxX84XABmAitRDLC00lPxdMTpiEykjCDD+PbCUR2VBdv8OYhlU/4YdZYTQGj+cLM+
         Dn4g==
X-Gm-Message-State: AFqh2koooX8HhknS43ulEr0s40U/IliMkQY8lFvSiqADNQxB97PIs4o3
	zOcZXGdl7RvFcS+xbm9WcOaAVILW5eDnDgv7
X-Google-Smtp-Source: AMrXdXusQUwQJuSOMBlsr+EiuxjGIZCj7PVXprFW1uKESJVot3RjhTxyNcOFJCkD6TMIumlVaZgr2w==
X-Received: by 2002:ac2:4f13:0:b0:4b5:b22e:9653 with SMTP id k19-20020ac24f13000000b004b5b22e9653mr8530410lfr.18.1672418830179;
        Fri, 30 Dec 2022 08:47:10 -0800 (PST)
Received: from iss.home (2a01-110f-4a07-e600-0e7a-15ff-fe95-b9d8.aa.ipv6.supernova.orange.pl. [2a01:110f:4a07:e600:e7a:15ff:fe95:b9d8])
        by smtp.gmail.com with ESMTPSA id z14-20020ac24f8e000000b004b55cebdbd7sm3545287lfs.120.2022.12.30.08.47.08
        for <ell@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Dec 2022 08:47:09 -0800 (PST)
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
To: ell@lists.linux.dev
Subject: [PATCH] tls: Add l_tls_get_session_resumed
Date: Fri, 30 Dec 2022 17:47:01 +0100
Message-Id: <20221230164701.1095865-1-andrew.zaborowski@intel.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

---
 ell/ell.sym       |  1 +
 ell/tls-private.h |  1 +
 ell/tls.c         | 10 ++++++++++
 ell/tls.h         |  1 +
 4 files changed, 13 insertions(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 6c836e1..4d8596e 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -519,6 +519,7 @@ global:
 	l_tls_set_version_range;
 	l_tls_set_domain_mask;
 	l_tls_set_session_cache;
+	l_tls_get_session_resumed;
 	l_tls_alert_to_str;
 	l_tls_set_debug;
 	l_tls_set_cert_dump_path;
diff --git a/ell/tls-private.h b/ell/tls-private.h
index 6a9bd29..46889ad 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -266,6 +266,7 @@ struct l_tls {
 	uint8_t session_cipher_suite_id[2];
 	uint8_t session_compression_method_id;
 	char *session_peer_identity;
+	bool session_resumed;
 
 	struct {
 		bool secure_renegotiation;
diff --git a/ell/tls.c b/ell/tls.c
index d363765..72ff4d7 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -213,6 +213,7 @@ static void tls_reset_handshake(struct l_tls *tls)
 	tls->session_id_size_replaced = 0;
 	tls->session_id_new = false;
 	l_free(l_steal_ptr(tls->session_peer_identity));
+	tls->session_resumed = false;
 }
 
 static void tls_cleanup_handshake(struct l_tls *tls)
@@ -3058,6 +3059,7 @@ static void tls_finished(struct l_tls *tls)
 
 	TLS_SET_STATE(TLS_HANDSHAKE_DONE);
 	tls->ready = true;
+	tls->session_resumed = resuming;
 
 	if (session_update && tls->session_update_cb) {
 		tls->in_callback = true;
@@ -3841,6 +3843,14 @@ LIB_EXPORT void l_tls_set_session_cache(struct l_tls *tls,
 	tls->session_prefix = l_strdup(group_prefix);
 }
 
+LIB_EXPORT bool l_tls_get_session_resumed(struct l_tls *tls)
+{
+	if (unlikely(!tls || !tls->ready))
+		return false;
+
+	return tls->session_resumed;
+}
+
 LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
 {
 	switch (desc) {
diff --git a/ell/tls.h b/ell/tls.h
index e688c7c..6964380 100644
--- a/ell/tls.h
+++ b/ell/tls.h
@@ -134,6 +134,7 @@ void l_tls_set_session_cache(struct l_tls *tls, struct l_settings *settings,
 				unsigned int max_sessions,
 				l_tls_session_update_cb_t update_cb,
 				void *user_data);
+bool l_tls_get_session_resumed(struct l_tls *tls);
 
 const char *l_tls_alert_to_str(enum l_tls_alert_desc desc);
 
-- 
2.34.1

