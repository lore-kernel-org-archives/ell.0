Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 63AF78466
	for <ell@lists.linux.dev>; Tue,  3 Jan 2023 14:47:05 +0000 (UTC)
Received: from fedora.. (p4ff9ff43.dip0.t-ipconnect.de [79.249.255.67])
	by mail.holtmann.org (Postfix) with ESMTPSA id A08E8CECF0;
	Tue,  3 Jan 2023 15:40:03 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Cc: andrew.zaborowski@intel.com
Subject: [PATCH 1/3] tls: Use l_put_be64 for IV creation in case of AEAD ciphers
Date: Tue,  3 Jan 2023 15:39:58 +0100
Message-Id: <20230103144000.641471-1-marcel@holtmann.org>
X-Mailer: git-send-email 2.39.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The usage of l_put_le64 for encryption ciphers seems weird since
normally all its input is big endian. So change this here to also use
big endian version to store the sequence number.
---
 ell/tls-record.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/tls-record.c b/ell/tls-record.c
index cdbd0b8040bb..6ac095629abe 100644
--- a/ell/tls-record.c
+++ b/ell/tls-record.c
@@ -177,7 +177,7 @@ static void tls_tx_record_plaintext(struct l_tls *tls,
 		 * be used to build the IV.
 		 */
 		memcpy(iv, tls->fixed_iv[1], tls->fixed_iv_length[1]);
-		l_put_le64(tls->seq_num[1], iv + tls->fixed_iv_length[1]);
+		l_put_be64(tls->seq_num[1], iv + tls->fixed_iv_length[1]);
 
 		if (tls->record_iv_length[1] > 8)
 			memset(iv + tls->fixed_iv_length[1] + 8, 42,
-- 
2.39.0

