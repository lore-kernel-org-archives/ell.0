Received: from metanate.com (dougal.metanate.com [90.155.101.14])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EB1320E9
	for <ell@lists.linux.dev>; Thu,  7 Apr 2022 11:40:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=metanate.com; s=stronger; h=Content-Transfer-Encoding:Message-Id:Date:
	Subject:Cc:To:From:Content-Type:Reply-To:Content-ID:Content-Description:
	In-Reply-To:References; bh=5kVM1eEsiJgwcImFDKKg3JZ9HHO2+0wPE0O2+7sOQxs=; b=eS
	IARXhjoXITshwFFcoacvhcS8kIKrL6xzPx6kpFObIqDCVjz//Fy7f6pE6EJyH1NxFE0Yq3NjIn9VE
	8PvwJrASveZpBkm9qeRWyi4BUfQ5RJBn2vF8dnQ0JRcDCRfQ/IyciCM16kBbL77ZqrES40JHhpTd+
	VPPy55uFJ7POH1JRBrucHXkU1vZZ08VLgKaZC/1oDhujTw/Vg40Bo15uI6brt5QICLXLyEWN+oklJ
	CiZWMv/Qog4AGv0LPXfH1PUkWEpVRxZ8/UdMZvK4WhPs/of5vy3Q6tD2jfmHtXlHR1UDf5GNAN4qa
	XkmVfkrUoabz1jQbK0xSJ+FnI+d2aKBg==;
Received: from [81.174.171.191] (helo=donbot.metanate.com)
	by email.metanate.com with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.93)
	(envelope-from <john@metanate.com>)
	id 1ncQDR-0000IQ-1b; Thu, 07 Apr 2022 12:22:17 +0100
From: John Keeping <john@metanate.com>
To: ell@lists.linux.dev
Cc: John Keeping <john@metanate.com>
Subject: [PATCH] dbus-util: fix fixed-array file descriptor check
Date: Thu,  7 Apr 2022 12:22:12 +0100
Message-Id: <20220407112212.3433989-1-john@metanate.com>
X-Mailer: git-send-email 2.35.1
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Authenticated: YES

The code does not match the comment here since 'n' is the type code for
a signed 16-bit integer.  Change to use the correct type code for file
descriptors to match the intent expressed by the comment.
---
 ell/dbus-util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dbus-util.c b/ell/dbus-util.c
index cd8ba7f..b6220d2 100644
--- a/ell/dbus-util.c
+++ b/ell/dbus-util.c
@@ -716,7 +716,7 @@ bool _dbus1_iter_get_fixed_array(struct l_dbus_message_iter *iter,
 	size = get_basic_size(type);
 
 	/* Fail if the array is not a fixed size or contains file descriptors */
-	if (!size || type == 'n')
+	if (!size || type == 'h')
 		return false;
 
 	/*
-- 
2.35.1

