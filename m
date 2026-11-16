Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.145
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868085;
	b=3Ktp8au94bC6eid8rlcRtRboFCTCwcEwQkDzk/7+/KBPNovWcYrVXIZ/Z+vEmDHHzJyg
	 DxTt2EES6Qq68ts6XkHprfjw1JZs4m7lNB3SJyMZiFs3KeLhxcAiJ1h5pX9DVqquSUot7
	 F5eFxsPBHV3CLJnDyfnbqhjhM8I8O7Y3b7sBNyE0y76drajmjzin2SBzYTaE16POROTHk
	 XmFFO5mjbuK29EGL1Sm+9iX4P12LRitdjW3/Ev5LqP/dMNNt1GasDAfQ1urcVVCYCKLRH
	 RrXD5I1oL9/SeYuHf+Z1bW8zkjPaKjqD3MS2OzShzaKGT6P7VpU/UtiTRiOtUOJy4xQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868085;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=t89WmGcBctoHpHDkzvc9rgDdsDP0gRa9I51PMLxvLHQ=;
	b=J+p2CixwMebbwHl99dp3nnFXP/Du7T3AFjYdeqyR4qEs8D9F+9qPVJywVxvvi+f+hD7r
	 ql7iq07Hzl/YfRB4DzQYn7pAd/OPpDkZudhjSlQyY288yL8to9RKz4viCPdF+IYa5PLjf
	 j62qu0GocgI80WwLbGCpBmeyJEAvc+6/tRvQrnJGOyQ2/QuRuYWod2Maqq4XUyqLvPeKg
	 e9qeeHUUUJMgSHsiF7cHgsuA+DoEip2sRgk8VK9+OolEa17Opf3C+azX6Ks3MC9hUCD83
	 Fvaz8kGYfotO7ADC5xZNkWYrZdh41N7L1py6tqnvP+7eTEX1XwfDq7RY7jdep3HXHhA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=IUykXqE2;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=Q4p1xVSE;
	arc=none smtp.remote-ip=103.168.172.145
Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94963606A889
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:28:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 94963606A889
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=IUykXqE2;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=Q4p1xVSE
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.phl.internal (Postfix) with ESMTP id A6080EC0873
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:28:02 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Mon, 16 Nov 2026 17:28:02 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:message-id:mime-version:reply-to:subject
	:subject:to:to; s=fm3; t=1794868082; x=1794954482; bh=t89WmGcBct
	oHpHDkzvc9rgDdsDP0gRa9I51PMLxvLHQ=; b=IUykXqE2AjwDSXcJm1khTldIU+
	LpE8xy5hmY0ai00A1gdsO4Csg42wUsIodpChv6B00s8a1JR4CHL3ZJw7eFSwxxO8
	aX3QiPExYVoqIuOGlfTtGMHiJwsfmZrQhkxjJCk/spDgUzW13yVGSlJy/eMvqZQX
	96s6cLhahjAnLiepbC4ufqpBoedPNKFBmv1KNTIDfYDQi9tRZqC3y7d/gXKruByP
	dOsScuN9Xte7KW2PnOsoGEjslJeVAgRsKvRfguTjgGSF2zfKg6vIB6/o1H90v6YS
	wjG8LNaCKnGZTOuyEYanheUK6JBhXjHfJogI8TZka+GYmhjXo246C/74KJIQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:subject:subject:to
	:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=
	1794868082; x=1794954482; bh=t89WmGcBctoHpHDkzvc9rgDdsDP0gRa9I51
	PMLxvLHQ=; b=Q4p1xVSENuBJAhwRjl+C7FxQ4CQrLBLXb/Hi75uduDhWGUndMCY
	krX8UAWb18QB4CrlQR2xHtYQGHj0GPCpaiSzn5798+xU02lR85gcEwda0/LbcM/m
	iqn+A5Rk6NcTYuxsFgOHiSQ37u3GP8TnnyQO3qZkvlpH8ipBV3Mhiq6scda9R/Jz
	WoLUonpat6BfuAsSSXEZmz83XrmvQK+dqADW9bwa57IbJnhq6kLDwMqISxYiAzBg
	C7HmWUq2efZvTPXz/Y4/k/zyE1dyZfFAvPqPZbXq5IRaVs7yC/x7TGBY0xUEdoUl
	yG6jBPcWqABbaRtpheupOoFXVwjmWcdzhlA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868082; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:EwFkgXSvsXF2M/lmp7Z7Qv40dCwSwrl8zFKnpt2kKB9kX1+
	yaQDV0R4vF308KCtq0GYRYSx++1OS4CkNEGZhiUr4EKqdUqqJG8JCXs+4gst96jQ
	X+s9rsRUMZoILvSbSazXolhYaILs4x/ZMuP2dN/fUolWTfT8fYX/jcTugi0hYI0k
	UW1aUY2ZsZIaxuOFjY1H2eaFcbK5bUwJClLWBZSCN2Ld+nLMNhD/Ct9cQDQH4TfD
	iwcC+H6bbA1tWyCQKqOPNuXVVaauNjnD8TQK8zsPJ/hXoy3ifVFnWmn48tYA7qO0
	4SSRyUz4tyf5+jeA03VpseG31bCea+7qmRLVA+Q==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=9;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	message-id,mime-version,subject,to;
Message-Instance: m=1; h=sha256:iM1YJOwTKrxpmo9qrVE1pr/H8dOU/31MAIBCCFTrYTY=:HLy3XQGWmM3ikKk/VSbDfE0XD0ctfiF3btRG0lZ7btM=;
X-ME-Sender: <xms:coP7apv4ZvFdBQq5ClLMGrzoLW3fbZPRvzsbTHL1xn8tNTUstGVOVw>
    <xme:coP7aoe7qr3zBJQU7ArgrKG3F0PFV8wEkATpO-4ZJTZIRS_hlMxWkybhEWE_EFeDm
    dxQ-4VFUfJnkSqbPA9XQY6oREg2USzalzyBtOHOsWOYqrubFAYg8tg>
X-ME-Received: <xmr:coP7aqYY6kyzlfuHIPdgFGg18CtDzN6GzKEslP5OezDl3kUhb2qDuItKqFfbMnFqU22PDuxMeQ9of0e6l6_IqngwCNU>
X-ME-Proxy-Cause: dmFkZTExTx4e1H3jFFc+NOE9Uo9ew+Eub2eF+4qJEzCCgG5L0fr/BtQRyr0k93217rQAYz
    xzgzskee6dYbPG0mlCfD+ReY67VNXJ6A/cc8rqw2/ZS+tFx+87/oRiT2CPvaBSCjl5Tp/N
    Tz8KCls6gxhd8AQhRdowY/Ctm3bZ7w6lfSK1JfrLlVpjDP8+hjEBFF47h0a9VhodEw/qj5
    fqpHBlF1NNdN0FbWDseKK52HdV8FDISFFe5PLWNeEHNMrr4JH8RFkaBZCsfLX7HK2IOtVQ
    jily/mO0WS3gBupXQN35g5rrCd+fSm/NU8Eeu11MicYnm4a6sF+RmoSJDZ+QNFXuBCOmnh
    io3s6xVyL+RGX7HxdUT5zHh9TqeXaTTH9iZp3t8vwRfoskA4shU08mRxtVQsfc3+/1qu/L
    qj9ekpsWJgPOqP1OpugzKjVLYd98WkgEBMsHll12LlUb1e5a6qg/tNZaGMHN5R6qq4nuM5
    FChwGgT4l3/3drP/Tbr9GMVv7BOsS6CHY3oMFVze/A9R9p28UoDQVacpYAPOTKql3pRnCW
    9KO5ZoGd70tW76kp5ZjksxsUFDf9avSznEgOC2mypOYqrYQlf0ekHuC15lYlzeSOtAA2Lx
    6pd34KC2LAT45YoDe6DLEqiYSqsNEJZAeD5LxMDUYXmW0J5W6SO8jwzUwb7w
X-ME-Proxy: <xmx:coP7arXrs-aQTPMQvWfM85tUy61ZNZZ2v6DLSwFBuJ3YTAD0pKy25Q>
    <xmx:coP7ash3AguuZBecrDTbKjL5gN6Cs-ZTCQaT_wfl8jdbEbYmR8a-Bw>
    <xmx:coP7apWbomGlfz8Re4-nKhJO03B-7BPYfwrNJEMfU8z5Y7KgWnV-qA>
    <xmx:coP7ajPP9Ci7KtisDZ6xUf6kJKRastJwVIsTwK3RXCpCFBKnabyS7A>
    <xmx:coP7alFwI8xTpdmNKlAObPC1lF8C_rz_hhFSRLu26LLFCaBur80OE4nE>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:28:01 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 0/6] netconfig: RA route, SLAAC lifetime and DNS fixes
Date: Tue, 17 Nov 2026 11:27:46 +1300
Message-ID: <20261116222756.2921577-1-ryan@testtoast.com>
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

Hi,

I've been working on SLAAC + IPv6 (RA M+A mode) support for iwd and have
identified a handful of bugs in l_netconfig's IPv6 handling.

Each was reproduced on 0.83 with an ASan build of ell and a small
program running l_netconfig on a veth pair between two network
namespaces, with a script sending RAs and dnsmasq for DHCPv6, and
checked again with the patch applied.

1: routes and addresses were never put on the expired lists, as those
   were never allocated.
2: 32 bytes leaked for every RA route withdrawn or expired.
3: an RA route that's not refreshed stays on the current list after the
   kernel has removed it, and is reported as removed on unconfigure.
4: an RA cutting a prefix's valid lifetime to 60 seconds raised the
   lifetime of an address with an hour left to 2 hours.
5: a DNS server in both the DHCPv6 lease and the RA's RDNSS option is
   listed twice, so it's in resolv.conf twice.
6: 104 bytes leaked when the first RA can't be used and IPv6 fails.

AI was used to draft patches and commit messages, with all manually
reviewed and tested on my dual-stack home network, and roaming on a
ThinkPad with iwd (debian sid) and the mt7921e network driver.

Ryan Walklin (6):
  netconfig: Allocate the expired lists
  netconfig: Fix leak of RA route data
  netconfig: Expire RA routes never refreshed
  netconfig: Fix the RFC 4862 2-hour rule
  netconfig: Skip duplicate DNS servers and domains
  icmp6: Fix RA leak when stopped from a handler

 ell/icmp6.c     |  4 ++-
 ell/netconfig.c | 93 +++++++++++++++++++++++++++++++++++--------------
 2 files changed, 70 insertions(+), 27 deletions(-)

-- 
2.55.0

