Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.145
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868099;
	b=O/r8zrLsxqnOTJo7BIOyUbn4DwEXqjKpbA4mTtyD8X+8388P0JYzCCN1/ySUbtNo4aHA
	 x03ZUeVrMFESjgQzxOVYHix0MGEP8ie0/Xu3dz35uQ1QoJTYv07gialGTMl7z5IE2ODC4
	 y/brhiHJsKZ8YZ08R51agBjFjjxawX0LCyn8snHDCcFIvmWeLKSkEKpLfja015qU1ngsD
	 j2fTjzE0mFPNzCd1YQ9mYsdswHanFuJQPzMVL0HIEa5GuXwejPLo1s0p5MDxKyaAwbZij
	 9Xzk2egs+HdqeBjZrchzNFR+4oMc/Qi5VbS69MBbQCdgcEhVZ3uW3WlRlCCJrQ80/jQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868099;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=M4cIqRl+yfXueI+c4tF+lnUQRUiHWBFprhlyHgUuRfM=;
	b=Q654yneWGo3p0a8UmCuTwTqsNMBIILlDv2UOWSasOP6QokLmOzymdqhrOZtei06bA3hD
	 nZ5fDjXYpG7X5LrW86+fH/HzMsxDdEjEiYxOEAHOLUghbIOCFsvalwF2wT3OizBqkNyqe
	 Rhy5EO9M2v7njAaZrKgcnYyRP7Urcj9q48fhOousYWU/euNfHBHrkI6ZOCA1d0bXWLEtz
	 IQTmDdSpSop4mmPgEwCD2y2uyoCXwtmjqN+cnZQsnNxaOJHEqAd4P7OxQpn7+orO7aGbR
	 Q+pj0wQcApbtstN1v9/z/yT4Ut4lhl5faCoJ49zR0BGhEjRg483tvmJBZzCLRVFqpVw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=nWQE5Gw4;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b="XV/GU4iK";
	arc=none smtp.remote-ip=103.168.172.145
Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 222BF606A8A7
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:28:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 222BF606A8A7
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=nWQE5Gw4;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=XV/GU4iK
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.phl.internal (Postfix) with ESMTP id 50FE9EC0874
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:28:08 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Mon, 16 Nov 2026 17:28:08 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1794868088; x=
	1794954488; bh=M4cIqRl+yfXueI+c4tF+lnUQRUiHWBFprhlyHgUuRfM=; b=n
	WQE5Gw4n8YggyoebNedHNQ7tGXJtcoumd7LnWML3jm4NDnDkO0c72HNRcdG03lXy
	b/UV2AqXELK/ZOxaZjVjNOWzjys6h7/JK0IQBMFKM5MGZ0/bbPv8s79+bpvdRJFA
	O+boF+GoDkAx6+V3w8BfPz49LZE9D5rj7vdAlMvQRxkEBmgvl9Tl0R8KgaARJNfk
	uzgpZH25fGqu4S7hdFTseV5AM5VedITrTpzUbjrSmHi8aKYvp74yOl3iyLHcORx5
	lgcHhwscLAo2t+652/KH4aUgMoQKLGuJvWNlwLmC29QwKgiSEtjRYpT1E2TAUANR
	S7roBzDM26qdajR9aMxzQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794868088; x=1794954488; bh=M
	4cIqRl+yfXueI+c4tF+lnUQRUiHWBFprhlyHgUuRfM=; b=XV/GU4iKyXtaRFwcX
	24RQNZHQ6EInphZm01WtD+/NPsuSYkA5hd5m/7IvzZoH8hYtohEdRw5jWiKWnl6+
	PU27j0+7675zdTgaFCbRZS6MdbvGghhvzl9ZFQYfI8EXhYAEJPphujPzoQfcX5Iv
	CZPJ7pm5HKEO4gLbIhnilxry34oLBQxKZRm1QjedjML9NOq1RTs6DBEHprBmm4ey
	uAF4mw2JfWgLftchHPzlRtd+TXbjcUbL9QGrbVhzGC4lMb6zunPKw7fuxSOmrZvl
	w442dgjgSYQ/k23Q9p6cRvnc2PxJLmwzgT3xDtpNvLJUl0TouQLLAE/HAuvIMqDx
	P51Gw==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868088; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:AL3T4AFNn8TI8fV6rDhUvX3E/C1RWjX8E4lQgBfqoicfwYE
	PnGDcHrem8iUTdVw9SPH0aML18TEp1AOZf3HicwIp6xOie/Erj967Qq02tV62Maw
	/QeZz9HgwuGmpKi1kWKI2JGV7SK4brFvFr7JSznc/YvBlrajCrp3a9uyd0Anxgsg
	bTsf3mdYN4cM8LEMCjuxO+DLJIhKulqG//iZNaTkODpfT7nnu0sknincrXPNdPLr
	SgVEmmZLKONUnmxVLaIcdIo9hlj/SYntIPAOq7KgVcJfN1C0kSzvoWzG9S8GZ7Fz
	JwGoaXAaS0b5/xOsm8E2D99yxd5c/lAkbHwEBVw==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:+10ObL6Rt9r8y/KAp2aO4SNMFr7VuVm1a+1h0pliNv0=:4O3OI5e8Rfra9SAo9j9U/MIbAL/dLMr+DniIgghc7BM=;
X-ME-Sender: <xms:eIP7aiVjGGBjmRPC1UuK2AD1eRGch4CAlDbWYnQHkY82coc1rsz3ig>
    <xme:eIP7akkUJSixbblHHUFuCOjn1TaP2KzBhZDJtLv9rlnw49PVR0-sf7KIBlEiuhyoc
    DqHEOus92IiRReN9fZA4y96lKtBGLuX1gaibiCQiW-vqof10lLc>
X-ME-Received: <xmr:eIP7akAvmJ2jLrxTcrhQ3A92CNdr0Zamjn4O1-pfaoGwoZ8ey9wvR-5fLUAtLYLOInl_sLykOCB-Nn_dW2EDCSc3Kvg>
X-ME-Proxy-Cause: dmFkZTGOuYtRyrNxGoDi8Gp6HKBmLSHNTelLgbw0rhO5UPH7enZFByBevu1Px5nhrEYhk7
    Pcg2OQ56t+5YTBMSDwomM00kC1WgSpRlRdhg+pcN6WoH/H/nUs7fATQPVp7B0wXmyug+b9
    Lu/cUUMjrQYyc19P0dFD3cpBQ/65s6Eh1Di08BBN1ww4Ej/eAxYtJOJxiyjKxRB+yNqhiK
    YWM4KU+pU5rFC1ycLtwz9ucRCknLHz6jxYpJ2hYM1VmxMsB0/mX6cR+j/eLCUhWbQ88SXz
    NhWqSeOjkjSI8OIugt0KsNG1UcoilbhwfrR084FkiLz/lvxRoUhfO/Q87gsUJhAruy6xEt
    EEcfylpss7kNEFT3sNZ1nCrziDAR8i+1N68WPhD5i4pABcX9ZTz2h7Ndg0SM/yP8RJ3tcP
    Mc+uUXJkmI20q+xhDo8hHSeW/oZpYl93rcLhXO+XGHtnrU/99j9SNb3GZu/slvPomRNLFT
    VLrk8YX8CAT+4TAX7gxMJE6UjIUtEORn0HYqOTydvoBOQcx6tDUaMF4wEo08zW2SG4rOoR
    1FXugVIZUCZ7FApSwtxnrE+J8briY4h6Jn4a5UHPx4SsM//gz5ttFkIbIyEDvGGkT59vTM
    0aMqbAsL1jMRUNK2wKNenpF/8avr8LrVHGD0CrZR1dZrIHHxB+Q+hZ1GIYlQ
X-ME-Proxy: <xmx:eIP7akfnGQtGYfPeWGRK0dUA2VQ6onG-EF9jFsjLIbOS4FjEYP_UPQ>
    <xmx:eIP7avLAC7GL-CISzhM_wirIGTNZArOE_4P09MBw-BEIzffxc2_Qng>
    <xmx:eIP7and-CkpQaA-vOD9VhFgyOL4qTM72ycR44os_2lMMAaoNf3Ma6w>
    <xmx:eIP7am11X5dkGJ_uh7qRA-aV5fqy4t-Koj8BiXLZITrbZEnvep5-uA>
    <xmx:eIP7atvnnvXWeln9UYnIB-BZJAgPgyPIY4Nb0FC-nPQ_CwoofRkfGlB9>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:28:06 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 3/6] netconfig: Expire RA routes never refreshed
Date: Tue, 17 Nov 2026 11:27:49 +1300
Message-ID: <20261116222756.2921577-4-ryan@testtoast.com>
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

rd->kernel_expiry is only set when an existing route is updated, so a
route that's added and never appears in another RA, e.g. because the
router went away, keeps kernel_expiry at 0 and is never expired by
netconfig_check_route_expired().  The kernel deletes it when its
lifetime ends but it stays on the current list, counts towards
max_icmp6_routes and is reported as removed on unconfigure.

Set kernel_expiry for routes on the added list too, since those are
committed with the lifetime from the latest RA.

Fixes: 6eb8b8bccdcb ("netconfig: Ratelimit route lifetime updates")
---
 ell/netconfig.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 1be26ad..7e20de6 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1127,8 +1127,14 @@ static void netconfig_set_icmp6_route_data(struct l_netconfig *nc,
 							expiry, old_expiry);
 	}
 
-	if (updated && differs && !netconfig_route_exists(nc->routes.added,
-								rd->route)) {
+	/*
+	 * A route on the added list will be committed with the current
+	 * lifetime, whether it's new or was updated again before the user
+	 * got to it, so it expires in the kernel at the current expiry time.
+	 */
+	if (netconfig_route_exists(nc->routes.added, rd->route))
+		rd->kernel_expiry = expiry;
+	else if (updated && differs) {
 		l_queue_push_tail(nc->routes.updated, rd->route);
 		rd->kernel_expiry = expiry;
 	}
-- 
2.55.0

