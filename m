Received: from gregdf.com (gregdf.com [152.228.171.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A41113D9F
	for <ell@lists.linux.dev>; Sun,  8 May 2022 00:00:23 +0000 (UTC)
Received: from localhost.localdomain (unknown [37.167.202.147])
	by gregdf.com (Postfix) with ESMTPSA id 3E3D3796F3E;
	Sun,  8 May 2022 01:49:32 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gregdf.com; s=mail;
	t=1651967372; bh=IZAUY/ehHHduqNH8QXXKtaHrM2CdtmyC/XW26xesmPo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=AA7jyDApTD1/El5vzeUoesCTL++B5fYTxOh8iFbTZAkDt3OqTzA8/IHPCf0MnrVJL
	 OBwtzfSsNCffLG+YkFC0zYCgQ4aPrPuHlztogU3cDhU2dQVAq37rEMP4rEP5XcJ8Yb
	 gdJA8maGLXNyytX1K26E3cREs1ocyLwTLk5tthqc=
From: Greg Depoire--Ferrer <greg@gregdf.com>
To: ell@lists.linux.dev
Cc: Greg Depoire--Ferrer <greg@gregdf.com>
Subject: [PATCH 2/3] dhcp6-transport: Remove udp_fd field
Date: Sun,  8 May 2022 01:54:33 +0200
Message-Id: <20220507235434.11693-3-greg@gregdf.com>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220507235434.11693-1-greg@gregdf.com>
References: <20220507235434.11693-1-greg@gregdf.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

_dhcp6_default_transport_new forgot to initialize the udp_fd field to a
negative value. Because of this, _dhcp6_default_transport_close would
try to close it. For instance, this could end up closing FD 0 (stdin) if
memory allocation returned was zeroed.

However, udp_fd is not actually used and is a left over from from the
dhcp-transport.c file that was copied to implement DHCPv6 in commit
b384838d1a79182f09b71a7a48d103ff790b8ae6 ("dhcp6: Add dhcp6 transport
abstraction and default"), so it can just be removed.
---
 ell/dhcp6-transport.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/ell/dhcp6-transport.c b/ell/dhcp6-transport.c
index 04bf4fb..8d15606 100644
--- a/ell/dhcp6-transport.c
+++ b/ell/dhcp6-transport.c
@@ -45,7 +45,6 @@
 struct dhcp6_default_transport {
 	struct dhcp6_transport super;
 	struct l_io *io;
-	int udp_fd;
 	uint16_t port;
 	struct in6_addr local;
 };
@@ -214,11 +213,6 @@ static void _dhcp6_default_transport_close(struct dhcp6_transport *s)
 
 	l_io_destroy(transport->io);
 	transport->io = NULL;
-
-	if (transport->udp_fd >= 0) {
-		L_TFR(close(transport->udp_fd));
-		transport->udp_fd = -1;
-	}
 }
 
 void _dhcp6_transport_set_rx_callback(struct dhcp6_transport *transport,
-- 
2.35.1

