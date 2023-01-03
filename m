Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 5FFD22F35
	for <ell@lists.linux.dev>; Tue,  3 Jan 2023 14:47:05 +0000 (UTC)
Received: from fedora.. (p4ff9ff43.dip0.t-ipconnect.de [79.249.255.67])
	by mail.holtmann.org (Postfix) with ESMTPSA id 0107ECECF2;
	Tue,  3 Jan 2023 15:40:03 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Cc: andrew.zaborowski@intel.com
Subject: [PATCH 3/3] tls: Ensure callbacks are available before using them
Date: Tue,  3 Jan 2023 15:40:00 +0100
Message-Id: <20230103144000.641471-3-marcel@holtmann.org>
X-Mailer: git-send-email 2.39.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The common callbacks for TLS ready, disconnect and transmission of
packets are required to be set for any l_tls object. The app_data
callback is made optional in case implementations want to provide
an out-of-band data path.
---
 ell/tls.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/ell/tls.c b/ell/tls.c
index 687797f1e466..207f6c3ae40f 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -3357,6 +3357,9 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 	if (!l_key_is_supported(L_KEY_FEATURE_CRYPTO))
 		return NULL;
 
+	if (!tx_handler || !ready_handler || !disconnect_handler)
+		return NULL;
+
 	tls = l_new(struct l_tls, 1);
 	tls->server = server;
 	tls->rx = app_data_handler;
@@ -3561,7 +3564,8 @@ bool tls_handle_message(struct l_tls *tls, const uint8_t *message,
 			return true;
 
 		tls->in_callback = true;
-		tls->rx(message, len, tls->user_data);
+		if (tls->rx)
+			tls->rx(message, len, tls->user_data);
 		tls->in_callback = false;
 
 		if (tls->pending_destroy) {
-- 
2.39.0

