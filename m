Received: from gregdf.com (gregdf.com [152.228.171.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9ED6E3D9D
	for <ell@lists.linux.dev>; Sun,  8 May 2022 00:00:23 +0000 (UTC)
Received: from localhost.localdomain (unknown [37.167.202.147])
	by gregdf.com (Postfix) with ESMTPSA id B3C2D796F40;
	Sun,  8 May 2022 01:49:33 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gregdf.com; s=mail;
	t=1651967374; bh=wznD7WNT8+0b+9LntRTHA1HAXzL+b8R6BARGm0URa9s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=KY4XEKIGfpU5OeKO4gp+gqXqAB0eQpJoEAx3DFnP6DyGYtvKIj2mtRTtBRfAYpiCY
	 JHr/ttnVSRsT5isZFK5BXGfq0KdUB8FMwmlbv2loToxgGg7V8b2VvUc/7LWGXudG9Y
	 Rc7h+TIDZ8UbhAdhknLCSYm+ftAgLBsq2fjXGYLk=
From: Greg Depoire--Ferrer <greg@gregdf.com>
To: ell@lists.linux.dev
Cc: Greg Depoire--Ferrer <greg@gregdf.com>
Subject: [PATCH 3/3] dhcp-transport: Initialize the udp_fd field
Date: Sun,  8 May 2022 01:54:34 +0200
Message-Id: <20220507235434.11693-4-greg@gregdf.com>
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

Initialize the udp_fd field to -1 in _dhcp_default_transport_new to
prevent future mistakes where a random FD is closed when the transport
is closed before the field is initialized.
---
 ell/dhcp-transport.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index d73930b..8ab6327 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -550,6 +550,7 @@ struct dhcp_transport *_dhcp_default_transport_new(uint32_t ifindex,
 	transport->super.ifindex = ifindex;
 	l_strlcpy(transport->ifname, ifname, IFNAMSIZ);
 	transport->port = port;
+	transport->udp_fd = -1;
 
 	return &transport->super;
 }
-- 
2.35.1

