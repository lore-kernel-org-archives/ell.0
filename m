Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 61FE58460
	for <ell@lists.linux.dev>; Tue,  3 Jan 2023 14:47:05 +0000 (UTC)
Received: from fedora.. (p4ff9ff43.dip0.t-ipconnect.de [79.249.255.67])
	by mail.holtmann.org (Postfix) with ESMTPSA id CC18DCECF1;
	Tue,  3 Jan 2023 15:40:03 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Cc: andrew.zaborowski@intel.com
Subject: [PATCH 2/3] tls: Replace tls->ready_handle with tls->ready_handler
Date: Tue,  3 Jan 2023 15:39:59 +0100
Message-Id: <20230103144000.641471-2-marcel@holtmann.org>
X-Mailer: git-send-email 2.39.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

In general the naming should be "handler" instead of "handle" if it is a
callback function.
---
 ell/tls-private.h | 2 +-
 ell/tls.c         | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/ell/tls-private.h b/ell/tls-private.h
index 46889ad86769..bfd20b10cf88 100644
--- a/ell/tls-private.h
+++ b/ell/tls-private.h
@@ -200,7 +200,7 @@ struct l_tls {
 	bool server;
 
 	l_tls_write_cb_t tx, rx;
-	l_tls_ready_cb_t ready_handle;
+	l_tls_ready_cb_t ready_handler;
 	l_tls_disconnect_cb_t disconnected;
 	void *user_data;
 	l_tls_debug_cb_t debug_handler;
diff --git a/ell/tls.c b/ell/tls.c
index 72ff4d7723ec..687797f1e466 100644
--- a/ell/tls.c
+++ b/ell/tls.c
@@ -3072,7 +3072,7 @@ static void tls_finished(struct l_tls *tls)
 
 	if (!renegotiation) {
 		tls->in_callback = true;
-		tls->ready_handle(peer_identity, tls->user_data);
+		tls->ready_handler(peer_identity, tls->user_data);
 		tls->in_callback = false;
 	}
 
@@ -3361,7 +3361,7 @@ LIB_EXPORT struct l_tls *l_tls_new(bool server,
 	tls->server = server;
 	tls->rx = app_data_handler;
 	tls->tx = tx_handler;
-	tls->ready_handle = ready_handler;
+	tls->ready_handler = ready_handler;
 	tls->disconnected = disconnect_handler;
 	tls->user_data = user_data;
 	tls->cipher_suite_pref_list = tls_cipher_suite_pref;
-- 
2.39.0

