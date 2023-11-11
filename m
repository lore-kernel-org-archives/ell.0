Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id D6DF51BDFA
	for <ell@lists.linux.dev>; Sat, 11 Nov 2023 18:07:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from fedora.. (p4fefc822.dip0.t-ipconnect.de [79.239.200.34])
	by mail.holtmann.org (Postfix) with ESMTPSA id 723F8CED02
	for <ell@lists.linux.dev>; Sat, 11 Nov 2023 19:07:56 +0100 (CET)
From: Marcel Holtmann <marcel@holtmann.org>
To: ell@lists.linux.dev
Subject: [RFC PATCH 1/2] netlink: Workaround missing NETLINK_EXT_ACK define
Date: Sat, 11 Nov 2023 19:07:52 +0100
Message-ID: <20231111180753.51488-1-marcel@holtmann.org>
X-Mailer: git-send-email 2.41.0
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This works around the missing NETLINK_EXT_ACK define of really really
old kernel version and defines the missing enum nlmsgerr_attrs.
---
 ell/netlink-private.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/ell/netlink-private.h b/ell/netlink-private.h
index 229b1d442ad8..0a1b016d8887 100644
--- a/ell/netlink-private.h
+++ b/ell/netlink-private.h
@@ -20,6 +20,15 @@
 #define NLA_DATA(nla)		((void*)(((char*)(nla)) + NLA_LENGTH(0)))
 #define NLA_PAYLOAD(nla)	((int)((nla)->nla_len) - NLA_LENGTH(0))
 
+#ifndef NETLINK_EXT_ACK
+#define NETLINK_EXT_ACK 11
+enum nlmsgerr_attrs {
+	NLMSGERR_ATTR_UNUSED,
+	NLMSGERR_ATTR_MSG,
+	NLMSGERR_ATTR_OFFS,
+};
+#endif
+
 bool netlink_parse_ext_ack_error(const struct nlmsghdr *nlmsg,
 					const char **out_error_msg,
 					uint32_t *out_error_offset);
-- 
2.41.0

