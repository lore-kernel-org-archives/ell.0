Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.145
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868101;
	b=G3wwjDGAAi7L4WN0OB8al22EErK70+T2SARmbEckzYcATtT61uWC1lKMjH5ruaaCrWAU
	 TTDeaMIU9hETIp2y8H2YnXLaEZxbai1x9eP36N0VK9Oh9oLiaBApLVfEcVSW1UfsmsOjr
	 ssFaOIJh3lZarLQpqMRvqZ77unJLJYXmvGc2q+VgvLl6hWspoI6iRvMReD3vUA7FgEGkJ
	 f+HlczcyKEck5ayvlYoLaCtd9ZgyRw+Xe9CBFjetsiVpk5PrHMGnleiZLLUO13YG2ppg4
	 FjHN1yrk0L/A8W5FHGGj40Us8ftmTyN9FDTMI9GhYYB3C1cNFw0CcaD6s3gROzqua/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868101;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=7H5XoOryt9yKyW69B2L1L92yWa4L6wjl/HWBLhRq2Ic=;
	b=PFAUmupF73swZoVAJP5XZ1VsRY9nzymFBKAoSEdLW577UkR0sg2XnCuCx1+94sQKTUEO
	 V7JOQqtuI2ryLzbiVFmHZYvb1hsuNzQRdO57ulyF2oYBW1iWntL5VTVFgRLIDuwXNGedE
	 p6SraqzQ6ASkLBWw6fHgnnez9lemTNF3b1VmYwGt8fx25XnRw/fN5J8RgEfgx/ynYTr0A
	 j9zOW3OdyN8eclJF8mRWdtNPnhPUpqqB4dHmyygvmuKAs8pGYXBhbtRv75/wnGXijyDFX
	 d4HNBrPCEWAPvRyrO1GJYe724g7ZhcV8yklG1QEL9CN1xkRF3VWQ8TN2mTGQ6qfn7eg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=CuLLxVEn;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=OcwHJPW2;
	arc=none smtp.remote-ip=103.168.172.145
Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A21C606A88A
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:28:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6A21C606A88A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=CuLLxVEn;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=OcwHJPW2
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.phl.internal (Postfix) with ESMTP id 8689EEC0862
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:28:13 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Mon, 16 Nov 2026 17:28:13 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1794868093; x=
	1794954493; bh=7H5XoOryt9yKyW69B2L1L92yWa4L6wjl/HWBLhRq2Ic=; b=C
	uLLxVEnp/5Or6bWCoGBod9VmFzXpilo6VIcyCoti9cZzEkejGxqwzBPGJq97oQDS
	cRgfE0Pggud9OI1XOWidev7B0F18wEXuaTLe3dGFJZ5//N5cEYxIMvn/mHLw+hoZ
	KWOkkZAFDhKtAV+7lYZSr8vsptePHOu+dNOZbKpEEQhzmHbVsEE49t/EVaYkLxBb
	VC5Rb9faarukvYG0p38be3f+L6FKcbVBcj5SHib/Q8CZMjl8eWuNX3u/2tj5Rbn3
	OzMKBH4Se8TQvOneTdt9vtHeNZ5pb7WnbciEiClOBos2jPwBeW564/kPI3ZwGsdM
	Gw8h+GP0m5EF9zwiNMRlg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794868093; x=1794954493; bh=7
	H5XoOryt9yKyW69B2L1L92yWa4L6wjl/HWBLhRq2Ic=; b=OcwHJPW2t6/mTmv1s
	G8VXfOOOho1zpi1MILH6nnXyg7I11pdpYV5LLRLWBLRkGMxLlCZFy9sOaD2SR8rl
	sFSyi5TJxhdGQn8gYbzLH5Qe2VwJWbuXNSpfF21WBShll8MpvbL57L67YpsQQsna
	KpOZkuSD/sudScRI07DzrwAO4jpvsEbM3IRX5fzN/DW35ThF+B1VxdGxKKzP/QNN
	21Z8ZM5Hn0sSBy1iKbmfOsFKmAVm3mDOap2JTXXsZZirvB8U507Gt5aH1Xk5Aan+
	41iemC98E3NZcOHrx+j71Ryc0C8MSmhhwtfjqcz3sbz+yaKkP+/l9HHgnb2otZZO
	W2cYg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868093; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:LKe601POJoaofqvAORDSVLJTH6+9Ja7Dr7iRTDfmAL6Wcgw
	abinC29SpenN8veg4+zsRCKR1VxaKgm8h2pPxLz4CKlKjVc76ANXG5VLGB+ckX1i
	Jb73QeVnJ2I/p+zS7qvkv0KkHHTksU35mGwt9BKp62oEAR4n9pTG7QbgmsyfGO7F
	MqdY4x5tkObD2mwW4S2Ml8Vscxy+fVlJhRzkbBFODwXNdeG0zi3Z5XlPDDzLdb+2
	5IcQQGCJX4vm1Irn/438iCOsIJb8rOx3Pp2zFYQZokU2kayYTtKZnO8/eKH9gBnf
	vLGOvZDnUF5p23y2FmSB0LbPlXCpYVFhDEMJjXg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:DJUKKSrrm/LRMKWA7idVkDCCnpWHh9UK3cEqmoc4Leo=:vT4ThCneOHzBgsWNjE8iCBlpqMRtYgmKfTSU//w6/H4=;
X-ME-Sender: <xms:fYP7aurxcMfYpz4eLVl15oh7ebrgBbYwT_oAD0Ns8yieWaJiPYzJtg>
    <xme:fYP7aircuixP29v3_4QYKGkCF6VpECSOTa8fcByb2iHkljH3eXvhi3H-L75-mVPeS
    RJl4q5do9-4Qnw3uqNHv075ubatTk6LlpnAASjS6yK1BUPJEzFlzew>
X-ME-Received: <xmr:fYP7ag1wXoRYe_GfcddpcWwwLZgZNoRKOjT8jNHB5cGFE1hHTlhn9Fe_QeSe_10n9MMr6f0EmG0NflaooX1t9tnTtdw>
X-ME-Proxy-Cause: dmFkZTErkaN7fVlPtNDdi51QiCO3Jwu/EXF3J4JMuaS7oz4sQp/qZo92lHHso/nWqftgyo
    shyiFCj0XGRYSExSdsxL4hZ0eCGOLV8mdTnhPW/3IxcPtNhSCwG9wLFNy76VI24xFu4ost
    cdj4rolGfawPJ9mrkc2UnaWOhWCb3qwejaEqCUg6IT1FzkPrNHFz/nHJfXLhgJa24ZebGW
    tQg5xOXzqJu9sqHXTN+/hdVrPyA3Wqmv5hNe+T+H/A6YvWinAi39i2SGqCL26UC4/KTq+9
    m8DHcWgFwNUMzdABkBY/R5529o5EIE0s7v2vMSEh9uYeOz2vbbRYdTM9mx5w9UjtRa2IbM
    4AJYSVQcLZs1AeBIG5sWst8U+EDpXKF85gwqRT9VSTu7kM0qxohYGRuUFWteESOt9pMs80
    rE82Odn2MhZxziGidgYTRHTfZ+e8uBeBzt6GtAhOQtJCCDfZqJMd8vaqcBoHrudKLxQUNe
    8caHMkXIgcB+RTv7LX+W0NwRU9PiAJOtSpZFpzGO+0MNyP8A82uOShPB7PWCCzoJG7KDWq
    2Xb9KtzVswBV9JEKcueTaoYG6AuMiuj6XJ+LLimpSajm8oxRtdytPfUrc4KRw+FbsGEEyw
    VcDf3VCnbDm5DxHlss28bqXklUJP9rfcxDN+9mvLSpD2Nyxa930loDjJfYkQ
X-ME-Proxy: <xmx:fYP7apCst-4n7yREr0Q88-pzRoDW9FAP09Uw_CyF9aUzgfwJNrgxbg>
    <xmx:fYP7agdXxIfa3QaJ6iYInXI7tW8qSwp57CD7Ja1msH0ZWLLxAF4R1Q>
    <xmx:fYP7amhD1R530uUAcSphkQC6AxWlLTZbE8fO4xEsopUi18p6SAdEyA>
    <xmx:fYP7agrW0erKuDSGSxpcM5aglve2rk7lh2ziPnM3cGu1hSeh73eVPg>
    <xmx:fYP7aiA9x5LmfeSZtcgpf33Utkph2RQerKZV3KOFvXfUsYnp03chUzKW>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:28:12 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 6/6] icmp6: Fix RA leak when stopped from a handler
Date: Tue, 17 Nov 2026 11:27:52 +1300
Message-ID: <20261116222756.2921577-7-ryan@testtoast.com>
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

If the ROUTER_FOUND event handler stops the client, which l_netconfig
does when the first RA can't be used for configuration, the parsed
l_icmp6_router is neither kept nor freed, leaking it.

Fixes: 90784c747ce4 ("icmp6: Emit L_ICMP6_CLIENT_EVENT_ROUTER_FOUND for all RAs")
---
 ell/icmp6.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ell/icmp6.c b/ell/icmp6.c
index d352955..2a8798e 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -457,8 +457,10 @@ static int icmp6_client_handle_message(struct l_icmp6_client *client,
 					r);
 
 	/* DHCP6 client may have stopped us */
-	if (!client->io)
+	if (!client->io) {
+		_icmp6_router_free(r);
 		return -ECANCELED;
+	}
 
 	if (!client->ra) {
 		client->ra = r;
-- 
2.55.0

