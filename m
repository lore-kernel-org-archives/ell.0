Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.158
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868577;
	b=AILBn6Fl7jw4uon1n/5cn6SgDCmQXDlvZL/OkhuZtzVT3WVy+BA09hquxFiGboyA/i0O
	 EL1RYI/VuffRqKr/kjQ/lIgikzpzIzQcasv85JHkriIEgMrTTSC20BAGmq95JXzALQId0
	 W4SDHlG0EELppC15j5+1p5hOWHT8fmH2DLXjw+q6BVUL3u+xKg5dQ96fnzkWp0B7AwaiV
	 E065N6QDh9Z+CiS0dS9HO3zJ0O0HEkmiAWEa891Uy8ZrG3a4wSzL78QPBsRYZ7ko56l/9
	 XVo0QVOUE1Yg+rkS8N/SpuY9xuQq4pLz4h8fTOu/HlxUofpimy5oOVEbF2dK3rPs53A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868577;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=xr5dTy+zN2TorDmxKpsZr2Z7NvNiBIOojjVmBdL9RMU=;
	b=TF+ugvY0ETtR6QOQFtN+N8DdjgbTNjrYd4xVdBCAvp688C1BOzFVb6C800cPyEGxmzYn
	 a3QARloHqdobyGfgY0+IG5NQd/T2y59XcQHFqWHWFCW1IfnJW6UOStyb/wXFxbx8vWHJm
	 L+K+bJraLZQXrtJ6JxWSxUtvty/4XMoGRVfYTnh2SSIIx83ODM5CCf8MiltbTiAvruavG
	 NGTkQ05rmXPYDRXqSr6QhY8cTsYRh4T95eamkknS4XT2iyaIvBqLyP3RsRnzv25egFnB8
	 G1w0aDCum+NhQz1eZzxS0F1N85ks08kX4amWHD+/xSg+5iCzeHdoEiQr7fo/G66DUsA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=J1ZEgQG6;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=Ibvlu5MK;
	arc=none smtp.remote-ip=103.168.172.158
Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24A59606A880
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:36:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 24A59606A880
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=J1ZEgQG6;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=Ibvlu5MK
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 435CF1400098
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:36:14 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-12.internal (MEProxy); Mon, 16 Nov 2026 17:36:14 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:message-id:mime-version:reply-to:subject
	:subject:to:to; s=fm3; t=1794868574; x=1794954974; bh=xr5dTy+zN2
	TorDmxKpsZr2Z7NvNiBIOojjVmBdL9RMU=; b=J1ZEgQG6fZppcv9EgydXis2VoI
	f70muY7GXZ1AVshA9JoYfBLDNIn6w693pOyyKoiy4/njjFCUXjks8vedji4znTGf
	TsAojkMRNitF9m2XsID2XWenlT+j0hKFSfKP9EwWh8Sdx3ZaH/5XyQCQ62lfbBcS
	VNbjfZhNPYOzTCT7DSq/K28qcsNNK/vxMxjcpEXhT7w6BcK85tt8sHCMI0QWNW8j
	KhFVOB5CWKP/fybVgCWo2jSCLj0fgfBwo/gkixVUOiuMoMO1rnO23V9/o0WkEUho
	u4Qcb+A9B6xlM46Ahlg1nyUR8ZeaCrsMC6sRcGRlZ0cVewS7mz4aSTHk1iAA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:subject:subject:to
	:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=
	1794868574; x=1794954974; bh=xr5dTy+zN2TorDmxKpsZr2Z7NvNiBIOojjV
	mBdL9RMU=; b=Ibvlu5MKGYi6dRqdcddlySGWZKwu1ESP4fmrNsoohFmHGUVmqgA
	YF5MpBL2/ZlT3MuGZcd4T6Ny90tlYzIMXYaGgsdA3RRpo4y//FE9zN5LA4Gqtp1U
	jGTJs6F2VyI6weWaMCng5MtDt4d3K/4/Mt66PsCollYJKfDqoVWWF4cuv2SPWPKN
	nQkc9Y81rQRSY7Rp+8ljrm4A2kUSsOc5QsypYp9oR7mTI13GQt7aRNUJZg7roRuV
	s12WnEM8k9iTSLLsvHNuB9djA893EfJhNF30euQgwP5AW+zY6xcGthsKIvSZLyp9
	M+8Gm9Allsb+gdu1sT58q3F54pRtuZ4XXkA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868574; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:YwhET8xlHCUcH7kJintzyvUFLscYSlPkeZnuEjbHf1Puh1K
	CJUF60/bf+n+YumVd2otOSG6cfNoYjb4NeAnfjA5MczsszkJH1LqkKHraMKv0gU/
	SsweS9+6isKIhEz1hDpbNaGqRpyffr2zALYik3gsaA+gM9sgU2e2UMcpf8NMDP83
	ko/sf25Fuj5uvtULcI0qXKnVhbXEDKok7Sfi5hoTnQapfYapXRmOMu6fDc0e0e8d
	ww8K5eZOmMuDZUyrQdxnxiG6mjOhiuyboMj7DetY7TKG0baT7WhYFjcfDjLzyjoQ
	APn/ujVdjDbVHGnARJCTHObTsTlEAbaJuK1wtuA==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=9;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	message-id,mime-version,subject,to;
Message-Instance: m=1; h=sha256:vY7kBcz3SXDBOwAelcOpFWazfpmvuUoQoqijn+D4480=:XfafHv0xS10P9FVvQxIfX3niJeP+Lwn6tMzU525Hi3M=;
X-ME-Sender: <xms:XoX7arHy2iEuTLWuZ31e3ld76c2cvZpT2izkPd8KBpPKKcaOPedWIg>
    <xme:XoX7auX6AzK5DdzARshDvjYmjeeehbNaCF1_Jj1m8wJHF3SdU3qCnWUCvQs5InQ3H
    VLlj2HG25rbTgjz2TO3Vcujl8b8N4sYxQEBuelDqAu1972CTEq72pk>
X-ME-Received: <xmr:XoX7aqyHgPSeVxKkkiWSox7JXsS3YOv2_slv-wdbO4YT65cVYbTGxaq8g-zWAjfBXbOD9vpzJ_9O0oAuv9pdG9_uXCs>
X-ME-Proxy-Cause: dmFkZTF1jjdXSJGh44UegPicHPMUfThhmwPc9y8kaBLRRI+eu8nb8p4kjwtSwhFDauox8Z
    5cJxvCVlrICXJz81sFAWDrVGZ1x5ZnAXySRB2S9J+9u+ChufnqBUrbGxEHb0CxVs3kq6mE
    V3HWVoEplDAzlsGtBwLMOILUubii7mdqbKMCdSS1LVDErto2IfKB9HPuNoz8EXYYuDF3ln
    IPk/Z3RZDLKdiNWf3iTKRTtHFuWaoQ1a5qguQtn/jNAY1Kk42kt6Q5UXuLfkmzYLSyUpXV
    sgUmlHy9GNWyuUtC8OmdCVPAqqIc9rZfJHSnq1Ib0Ifn8301uu2vPGbyhmLekti723H2YE
    1PPIWG0gyFvwsxqs3705bWc+qJYfsNcyiAx1TjbGSEl4175D6immQwZ8seqvyoOgkGM9cN
    qfgEWWu/qx832kgS9wZ5YXEUrFcIsz0Ija43k3ig7WgH71fbNPvnisrHGn0ZT0KTlTWNgP
    Y72W4DkvnLBjYKFsWixxmEj8eJP8OzJ+kWTDQ4LiPeyvzAuB32B2qtDaWFwCddD04lwJys
    zd3799sysXsJMjjWAKZQETEZkQ45ypjyt4qGlBLDqNJO2Ry4kot3CW2v/eXE+ciYoRpDJA
    CgIclcc1N/SrarKQG6Q8A29z3DX4NvPMA+XlrKYLwB2puDF3TUgWzGb40tLQ
X-ME-Proxy: <xmx:XoX7akOVCPc_Fl09ha9LyJJasr83QWYCjjctQEOvsI9FAIvJweoHMA>
    <xmx:XoX7aj49TIIKfPUSKCMvlHnTAEB6I9EvbhbIK2q3zovmpKMAt9lYlQ>
    <xmx:XoX7atOyO9Bi-QbYMsNxRcma1ASMu00X-VyvuG7SikMatalTDtf10g>
    <xmx:XoX7aploLfwoI2WGPz8bwsf_PsCLUksq4larDT8jWOUCAtEFEhrLpA>
    <xmx:XoX7amctfCgjaenFPBxKwurHwFmDOnSnr8B6lFyR3XDNS_iUOyqN7WE6>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:36:12 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 0/2] FILS IP address and station shutdown fixes
Date: Tue, 17 Nov 2026 11:35:37 +1300
Message-ID: <20261116223609.3134127-1-ryan@testtoast.com>
X-Mailer: git-send-email 2.55.0
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

Two fixes for bugs I hit while testing ell netconfig changes under
mac80211_hwsim, with iwd in AP mode as the access point and dnsmasq
sending RAs:

1: an iwd AP that has no DHCP lease for the station sends a pending FILS
   IP Address Assignment response, and the station then acts on an
   uninitialized structure.  Depending on what was on the stack it got a
   garbage static IPv4 and IPv6 configuration, or stayed in the
   connecting (netconfig) state until it was restarted.
2: a GetManagedObjects call while iwd is shutting down reads freed BSSes
   (ASan heap-use-after-free).  I reproduced this 2 times out of 2 by
   calling GetManagedObjects in a loop while stopping iwd, and 0 out of 2
   with the patch applied.

AI was used to draft patches and commit messages, with all manually
reviewed and tested.

Ryan Walklin (2):
  ie: Fill in pending FILS IP Address responses
  station: Unregister BSS objects before freeing

 src/ie.c      |  1 +
 src/station.c | 17 ++++++++++++++++-
 2 files changed, 17 insertions(+), 1 deletion(-)

-- 
2.55.0

