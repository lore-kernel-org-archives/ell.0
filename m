Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.158
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868090;
	b=3dweOS2xtydRmefFnBr8gRGFkJ58SFlC41TZbd1c+zxJVVs/TnjRNA+WhP28qfxac8hg
	 c76LolhMtEpOOaBUOFtJL3ZGQ6giD9WYLyBl66+/XqQ+ui2Od4xIMYIb7An7iurCeLZQ4
	 CFAtcqpVXQS0z7ZsPSEsM0/iO8UeYt2IKlxWTmpKaG+Ft2vT+AtbmYIql95cylpF+nDSd
	 4OyvUgh7t/WIiuEAM9k3dLz8C/JhJ/D0+QNSHtbC/rFuN2qeQjA3okjIqIuEFIgA5QkXn
	 0i4x1MELEJPrZI3twuIWhSU9X4ebRpKI1ZeiKHNqE0DvGVBDzKL2Bo+tsznIWC329sQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868090;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=ilktQjuzpJiC6uWCAdOG7kgqcNlW7q19pTUyspy3cY8=;
	b=shDv2e7LsOkpkBKO51SAHXU+qV0a4rqlgwrsCcVaQV4bo3oSbGhYTWwdOMYHlPdD9/H1
	 ibkf+yHZKkBJ0be8uBb13R0CFt/c81Bf6K/2qbh7rkk8tbOS5SjCy4+1aDNOFtpFebaRW
	 yrjBlqcblqDYWjjtYMKrd93r0d8y99FJYUpgOcqt4Xct86wmVIg1ea6gEyBVpcQQuEC1a
	 LSOCS5Gh9ZYBY5UoHbjB7ViA85Lu8+Zei4jZPKYrgYny9atjtFrgClOvqQ8/N8lOApM/2
	 F7Zd6G6JySXJdOnFiydHGzaXf4vjPqOzHRV9EbOe793tIWKxqVJs80B8+Kn9DM3TnzA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=Tlzj01Px;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=MJljm9hY;
	arc=none smtp.remote-ip=103.168.172.158
Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 90813606A891
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:28:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 90813606A891
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=Tlzj01Px;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=MJljm9hY
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 812DF1400050
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:28:06 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Mon, 16 Nov 2026 17:28:06 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1794868086; x=
	1794954486; bh=ilktQjuzpJiC6uWCAdOG7kgqcNlW7q19pTUyspy3cY8=; b=T
	lzj01PxCcOPDVNLxPkZsFsRGYDSs3Gu+CU8ebo61mQPi+oV9gOdLv19rUzHxUAq0
	FWsqPE4Y8Z6zNofe16cLWHRlBPxYQeWLHzw0uGR36rZB8UzruRpQ00pWypi/ND9G
	nAwI3FUDak1EU6XH67ka5cL6WtERTGh/IdqNDRxY/blj8sC5Xme32Nz2JWXnU+dV
	cX2L8tZrSa++g7rxjaJc18EDr5rTVIVc1otio7Tfa1sxbn3yXawGpBikfFnDeftt
	47ZS+1HFf5AcMvL7HCk7D+vv6NRu/UfNAhifiB7ETmosmibx1TxQ9SK3tbnIZnco
	kj9xfcAwpYXqbu4o8j6sA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794868086; x=1794954486; bh=i
	lktQjuzpJiC6uWCAdOG7kgqcNlW7q19pTUyspy3cY8=; b=MJljm9hYzPDtGtZy0
	k0Fi2tI3v/S93r60SjfSxZlkDhXXVnmdBvhM9rsUM03TMZtexMpnHoTjzt8a6Tqy
	mJdlPKiU8iXc5kSHM6p37j6SLB2kUjaufqG00WU4eoG6/gERngF+x8YmBghaF+A8
	VmmvFdt5vXskk/srQZ4AaP/EqsQUck8r3SJdyT12zSl02hQBX4hqnJLozp5CU6NG
	eJTnwH8tuhehwTSSAzxR3VkqcccRMe3CwthCkEMQb6PgFHoBBXxJSykXpK1PBbD2
	8e7bqyPQS0M+4cbta6mVPMEHjzVVv5Kj1WI7+NeswVQCbe7k/OmRgol+Z/ga6w1p
	YoIIg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868086; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:HcjIxyhsN28xSJ8AlekudN22JIQUlxxtfz2pBzvjN8xBFoA
	zkSKHj6zdeviGUp3j1lYpFwXWj+aFjdcqiHetuVZfuYQwzWu6zcfMc3XO3wglAHt
	jMGHIV4xrUezVRhfrF93cl1hZ3MmM4tXuxAfKF8+ZtHjmE5qRVuraXWFbW493H0o
	8LhdGQUvAUDXMFSzO0DKmJ8J4ba7jC2U2qqW0PaNcqTPDt/Wo+ROnwJWP0tCQAKX
	T6CgCEJmLDJb+5oGQjGse0LNywfA4t3trga9k1kGFGxbhwnwNjsnQYB5jSEktfI6
	Wxzr7XENDnuN69UKG1Wr1Y2ylTfYnwgj1ETQYpQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:e9xLS0gh5840BfgNB0ki4NALOlARGgi1okBGDBTi+oU=:G00l+2FUFM6lSIjtILrOhHu8rJpO9gmXeTLBKWTHwu4=;
X-ME-Sender: <xms:doP7asH3RKD9XBry65z4W0rMxFvIefWln4m_knje2amP_IOJR5jxQw>
    <xme:doP7arWCdNDVzOe_VMoWMPzEYfzsfKzfvcciClb3edkkBu3i3K3c4U4UV4WtIaVnd
    NVfkM1YadlhwHdPp_GA9bMCqxeQdNDkqKft2UFshoSYg9mqNvrQhA>
X-ME-Received: <xmr:doP7ajw7Lxjkihdv3VRQ7VzsZGHBwjg0x6GYeEtuY9wDCRz2SamqEnRqN7fEWfki8q_HJzVcMkMqb-NJvd51H-gCUlo>
X-ME-Proxy-Cause: dmFkZTEEP0tiYnfrv8FOZ1/e/XcawF0bDm8Q8CNNJfgGlGTzEU72oaYms7G0oYWnigKsZE
    exrS0TVgC4VMYNKN9tMRgtVhq7JX7G70NYb4NbB47ABpcOBsnI+UAX9ECEsHZYX383LQyy
    wjQKVfFK2bpkd6rniJ8DOSwKdaPLImMl31mgaEv65z0wlqWyFbsp/dHW3X77DfVnwwqPNv
    1SqOHyMJSpQHvWu8qv7VH0cRxG668rltANRzGKzqCEgz4851QEQOtnKPL/T75QPzMDHUhs
    +Y/pz3rtL3AObiQR+ZIO9M5aqxxjYqNRTcgrkSSbw4+ednrGcDnf5OuY8cYq33vOIDigHG
    Uo5hpCKofiIlS7sIzu+fKwCv0vAaTP1ngIpcCxvUn29Y5ZZJ2zkVOv2//DOf6swzDT78CI
    jhC85SrZDq1rB9OPGYze3xujR1W3yQJpeuToCWqm+oaQmbm54Kmi+KDRvTG38l/jB2kswC
    9K+xVsc8BqE/tmgj4WJLhIJErzvwW6unJJNR6bXJttP/jOZvj8n0ScFv04W6f6fdZSkRn/
    Hc1P3aJ+v2dkMmHCa4cfeLy1eT4vHewbMnWcuBo3FIIoIWujx2kaNxL9kg/CiMCF13L7Mk
    +QkrOnCy++v8CeNUXMJ4SUQ2KiVjllBkKdG3NpHC1qqBuMHoV0+STOXOxTdA
X-ME-Proxy: <xmx:doP7apNpfoZeUYne5w2u-kYBctr54QC5wj3ByqStFwrDWAVoOyYmYw>
    <xmx:doP7ak6D940zz3W7Au4ldYVdyv8hBMRNf4a_9oUG_C201Rh_QjE__w>
    <xmx:doP7aqPn2h-FEggaR_d0Hxphp30wtN0ufCjLN813stRWmmAjG_SQSQ>
    <xmx:doP7ainFKfywP9DxJzeNbHumOHQdUPcHxQxlmsvjy8dx_wpCVRlAdA>
    <xmx:doP7anf6HXSo9fyNOFnH1adlPhtORICjX1fOTNXsFStadq4aTznJMtw9>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:28:04 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 2/6] netconfig: Fix leak of RA route data
Date: Tue, 17 Nov 2026 11:27:48 +1300
Message-ID: <20261116222756.2921577-3-ryan@testtoast.com>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261116222756.2921577-1-ryan@testtoast.com>
References: <20261116222756.2921577-1-ryan@testtoast.com>
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Post: <mailto:ell@lists.linux.dev>
List-Help: <mailto:ell+help@lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
List-Owner: <mailto:ell+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

netconfig_remove_icmp6_route() and netconfig_check_route_expired() drop
the struct netconfig_route_data from icmp_route_data without freeing it,
leaking 32 bytes for every RA route that's withdrawn or expires.  Free
it in both places.

Also free the route itself if it was still on the added list, i.e. it
was never passed to the user, since it's then on no other list that
would free it.

Fixes: 6eb8b8bccdcb ("netconfig: Ratelimit route lifetime updates")
---
 ell/netconfig.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 2444d97..1be26ad 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -953,12 +953,16 @@ static bool netconfig_check_route_expired(void *data, void *user_data)
 	 * If for some reason the route is still on the added list, drop it
 	 * from there and there's nothing to notify the user of.
 	 */
-	if (!l_queue_remove(nc->routes.added, rd->route))
-		l_queue_push_tail(nc->routes.expired, rd->route);
-
 	l_queue_remove(nc->routes.current, rd->route);
 	l_queue_remove(nc->routes.updated, rd->route);
 	l_queue_remove(nc->routes.removed, rd->route);
+
+	if (l_queue_remove(nc->routes.added, rd->route))
+		l_rtnl_route_free(rd->route);
+	else
+		l_queue_push_tail(nc->routes.expired, rd->route);
+
+	l_free(rd);
 	return true;
 }
 
@@ -1137,8 +1141,13 @@ static void netconfig_remove_icmp6_route(struct l_netconfig *nc,
 	l_queue_remove(nc->routes.current, rd->route);
 	l_queue_remove(nc->routes.updated, rd->route);
 
-	if (!l_queue_remove(nc->routes.added, rd->route))
+	/* Not committed yet so there's nothing for the user to remove */
+	if (l_queue_remove(nc->routes.added, rd->route))
+		l_rtnl_route_free(rd->route);
+	else
 		l_queue_push_tail(nc->routes.removed, rd->route);
+
+	l_free(rd);
 }
 
 static void netconfig_icmp6_event_handler(struct l_icmp6_client *client,
-- 
2.55.0

