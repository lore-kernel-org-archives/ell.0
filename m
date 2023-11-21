Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 224161389
	for <ell@lists.linux.dev>; Tue, 21 Nov 2023 18:48:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from fedora.. (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id C5AD5CECDA
	for <ell@lists.linux.dev>; Tue, 21 Nov 2023 19:48:38 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Subject: [PATCH] netlink: Add workaround for missing NLM_F_ACK_TLVS and NLM_F_CAPPED
Date: Tue, 21 Nov 2023 19:48:36 +0100
Message-ID: <20231121184836.197219-1-marcel@holtmann.org>
X-Mailer: git-send-email 2.42.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The feature for NETLINK_EXT_ACK also adds two additional flags. These
are NLM_F_ACK_TLVS and NLM_F_CAPPED and need to be defined as well to
be able to used the extended ACK feature.
---
 ell/netlink-private.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/netlink-private.h b/ell/netlink-private.h
index 0a1b016d8887..fdb584e62652 100644
--- a/ell/netlink-private.h
+++ b/ell/netlink-private.h
@@ -27,6 +27,8 @@ enum nlmsgerr_attrs {
 	NLMSGERR_ATTR_MSG,
 	NLMSGERR_ATTR_OFFS,
 };
+#define NLM_F_CAPPED   0x100
+#define NLM_F_ACK_TLVS 0x200
 #endif
 
 bool netlink_parse_ext_ack_error(const struct nlmsghdr *nlmsg,
-- 
2.42.0

