Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793389693;
	b=SIJsP5WI2RoTqOWVe57kLRWxCd5JXO9z+eyhHSI7OVmOlx6HTVn6HXb6vTqGshqV9TS+
	 i/q73owrdJ7/QULAVk7AnYwugTlD4TOCFSYyq0NhIQSh35Ig7iwKgg/sf1p2X9xTsxZ79
	 KSTp7BFpmzZUWfCdJQorQLbNYaLvdPLMd9ynF69X6gr0pWr+uPoiJ7tOG61MN1O0Z/Yhj
	 aWMb/s9pBHYz82roB5fZ/tIh7ZkIAgOWss++Z6nxKCqJShhRsVJhepl5ltTyGJbY8Ep2s
	 8HHmrjrBGiWHtrS5Zu65IqcZGkdH1ciU7WSqUtYOwqMAP5RD/I9gUXGpKSkQfzrrXZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793389693;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=q4oWH3oahUD6NO2vg7RGaulZyFYMq/EXSed1gCd9tJ4=;
	b=BEz4d2wFNuIlDjCL/4jG1BC/XDb6MZoGr9W47Ur6t6XtWJu4SNUJSKB+MANpr7FmKmyd
	 u0VBT8lJPSTJVvrMQ9DejRHUJM9zueWYveidn6xNoXDXzkCUV0DV8lGQkjyujXXBlF5+J
	 ph84o6HyvPGhqgoANLFl6iABig/Chf9UARHzaeUdNrRqwIu6EP8kNKvYYSGDy53uzt5r2
	 xQ4KDDrdDVNE46ejeBn6dE+oKnRpJhU7YxNzf5QzifnnyvmVAooB78HudPmYLSM3jiTNR
	 0fSJrhXoeUVqxcj8wjO6JSA9MERNM/xtMwVnFoTXT0HegcZc9Dq4k2uQXQZwBbQH4rQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=cteubner.net;
	spf=pass smtp.mailfrom=cteubner.net;
	dkim=pass header.d=cteubner.net header.i=@cteubner.net header.a=rsa-sha256 header.s=fm1 header.b=F0cd2QkP;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=ylsVxOHQ;
	arc=none smtp.remote-ip=202.12.124.144
Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E86D606A322
	for <ell@lists.linux.dev>; Fri, 30 Oct 2026 19:48:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1E86D606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cteubner.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cteubner.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=cteubner.net header.i=@cteubner.net header.a=rsa-sha256 header.s=fm1 header.b=F0cd2QkP;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=ylsVxOHQ
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id 579A21D000F1
	for <ell@lists.linux.dev>; Fri, 30 Oct 2026 15:48:11 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Fri, 30 Oct 2026 15:48:11 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cteubner.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm1; t=1793389691; x=
	1793476091; bh=q4oWH3oahUD6NO2vg7RGaulZyFYMq/EXSed1gCd9tJ4=; b=F
	0cd2QkP1kA8Q1v/qT/PohfwZwGiBC6DJh9y6rKthiMCKTZ97qIsSZL5Ku1E6/zGc
	PF9reCPJTqPyzE9J4VZVNekvHAl95Ajt4mT0asXcKNQKUxe2ttry6/ycW8oLlzVp
	cSm7zDCq+KNs7GoUJqCw4FN0uJjK0H9eT18YxOQaLHGeFwmDZ5JxJsqAj62D0THn
	Pn0rY6xoB7HFrTcYrWHGp0L/gDatYEaOdpBML2YCA0LWMB9X33om+x3DTPv2iKR9
	lrSUr1+edKegMJsqurMUP7aA01skYRz1c4hXJ2zrFQM0BhJhkkHSQfwN4w9mwvPR
	HQzBuJOCmB5og3/LSBe1A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1793389691; x=1793476091; bh=q
	4oWH3oahUD6NO2vg7RGaulZyFYMq/EXSed1gCd9tJ4=; b=ylsVxOHQZVpwFZuNF
	nZGLoECGCsNeVObcrT5UTmTxZK5Nj4sBAaqclDWZeunabk/fQ1oLEdC70NkuX1x8
	5H3HSYeMfbDenKVCMy0guH8Jmq1pafsY2sbPuclPJZ044f5eXohglDZUdyfnOttD
	94murQRoCaf1cq/KR/FTLeexMX7HDsiIntFb9cgH0iCiNXnoTtECO+38mL1ZSleL
	HJ3pQ+DsT2XnShNHCowDHugbfR8q7m1w+GgQ3Kk4ifn2MRttRFXZJPHLM62m2KBG
	vws4mY3UbZLRHU0TT4O9u4BMyqOrShRK2ZK3ObaSW7uW6pJhJMVSuRGySDoKTuPe
	tHe4Q==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=cteubner.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793389691; d=cteubner.net;
	mf=PGNhcmxvQGN0ZXVibmVyLm5ldD4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm1:rsa-sha256:jY1Z6amkVzrZQZtCjM596TGufaFu4sDDj/dOObDcdk9G5g5
	qP9Ifaaheph5hvFNJ+f6yCR/QuC5dJJIg72RgU8OQff2c8PTUAdPB2QtHklR98Jj
	HXfjfPMFGElGeaSPCOlcXhFEW+FzoXc81Dix+062GzOGL1C1YzwkjBu6S534TdIk
	PG3PrMIJNI/u9FMnoHutp99VzGWIgc37flpbKFbV06rFoYyW8oYrY6QW41EjOs7n
	Phu9pbmfJ2BbB+AyFpoxL0bRzN9mM2nWD7S0T+VcfRvKd/0XXn7svxEImVcMuhgE
	wfoBP91EdFtYcZjFEuqTHuVa5uFghAHakwcdXwQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:MFL1J3PBVwdJLDTtcKs5qmMcmWwtRLC8lVWYKO6gSzk=:6xeGZPXIRXEL9tU+w8oIXb6hrc7uBnwSkZfPnd6fEdc=;
X-ME-Sender: <xms:e_Tkal916GH_ets0DBDpJTYg--wTNdIFiVi-gTCE6CTub7sWsJA3mg>
    <xme:e_TkavvylPe_TJvKPggLCdj2Y0nG1tI1fJSX29eTbHp1zYWCXkbX9krDyzrk3W9e2
    uceY-AJ3w7cV31WXnzkYs_QzvBd6Qr2Wj1pCTDzkFm6TBF0xb-jQfE>
X-ME-Received: <xmr:e_TkagrtZRr5Bo-lUdJs6x9fkwCQZdiQB6NG5nrRo0CSTSbevphHWQ>
X-ME-Proxy-Cause: dmFkZTEm0X4uirDZvfsKXtv65aNa9pCvPvEAwurDh0FC4p00V95HJFpP6spg/bn187fVQe
    8BAjwqAUkQkCFbk2gGklSkXbnJ4jyUWAfgjBMi9dKQGcVNRO4on4jUlJeJHqCAcFluIOaH
    aNeCem65FxDJTRakKDER6MFEuwxkQBnUaCGH7b+GVUy3a0J6kpksVh3MMSipjZkYZ6Fcwp
    vQch8sqBBpfuK14CUQO3cuiJvxkx74LrpwuMe1POvn1XH35qzA8odxX2dV/12p43/9U7NK
    LKni4d1voeTcfHYHg2BdNmvSu236SgCpfdqdxh/pjxUhWqmq0YInvDcyPJKvJ7yaJ07iQc
    9YdZ8Gw6u3gpf0uerPgPZZe3JAQGwfoSjCotZ9nVvVNmxZLazrt7wuVXoLv9klyzfBBJus
    jsi9rUpcAvE150NUUd+F2M5gpUi+e6+0vS79/R55yT5jSF84W/S5FUJHEkvWPZGhIc4B6x
    8CwDhrnzk2gMWb+btfFDFJIaGJA6BLD7wRhKE+mioAeykOcpn48fTnxej7WQP6euFLjH7T
    YcnLRsr/5bR+VLlHKRk8R+aknLwYodssSuk62UVmitMWh6vxNjzku9W5MFu2IGqe/jd4fV
    GJtpBtUDvzXuAAdXUwG94hI1/ObeFNBNWlfzl2+UibOFxu/32yxqwY66PIiA
X-ME-Proxy: <xmx:e_Tkakkybyn_oIyPQCjqP7D-cG9YPnJodegrgKeKu0T2CAOGR_TYGQ>
    <xmx:e_Tkasx8mB5TpBuBZJ_o1wsBfFcuyxamMWUIO7Ko6YO62zuPLHGpaQ>
    <xmx:e_TkaklWtJg-goBNpyYy5c73nJXTBcUfC8iLpVU9b7ZV0PYoBL8gvA>
    <xmx:e_TkatcFL7_kFtLpcVZDo5WjAQpNqDbH8gdueL6SKIW94OyaAwqOIQ>
    <xmx:e_TkahWflsR_UNHwP1NK2ejttUtYgT0sEC33S-KNuy6IbkMH8nDAMFn7>
Feedback-ID: i3cc944ce:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 30 Oct 2026 15:48:10 -0400 (EDT)
From: Carlo Teubner <carlo@cteubner.net>
To: ell@lists.linux.dev
Cc: Carlo Teubner <carlo@cteubner.net>
Subject: [PATCH 0/2] Ignore DHCP root domain names
Date: Fri, 30 Oct 2026 19:47:58 +0000
Message-ID: <179334935255.3.16564933583527517394@cteubner.net>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <528838ce-7599-4268-b7a1-0cc9d7d689bc@app.fastmail.com>
References: <528838ce-7599-4268-b7a1-0cc9d7d689bc@app.fastmail.com>
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

Hello,

This follows up on my report of iwd timing out when a DHCP server
advertises "." in option 15 (Domain Name):

https://lore.kernel.org/ell/528838ce-7599-4268-b7a1-0cc9d7d689bc@app.fastmail.com/

Rather than rejecting the whole lease, this series discards root domain
values and retains the remaining configuration, in order to fix this
issue.

Thanks,
Carlo

Carlo Teubner (2):
  dhcp-lease: Ignore root domain names
  unit: Test DHCP lease domain name handling

 ell/dhcp-lease.c |   7 ++--
 unit/test-dhcp.c | 102 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 107 insertions(+), 2 deletions(-)
