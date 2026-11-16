Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.145
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868101;
	b=gYPK/J3/MTHaaa6H+cXj64MvomUTJKGBWihjBW/+rfDODd9egy7Ce860Zuu1pkfk4RD5
	 ljleMjbjSQpaV/FxKVkXbyq9DEKZp38VW9W76Og900uFqmr6Sd7eqtX6lGDTo9dwIbqeW
	 rZ9MAmGk2+5+hvug2t5kVe2K5Y3K5hB4vnI5JvXd+3cxe/Zsm6nbBxHMBASHE9HBTKB/m
	 BwtBnhHc0mdrAIVfvBEuie/tEC+73p4fEhZxecsjo3OsliTCGU5aBcjG3hBatqbSuisX0
	 7c78G+8Yt13PUaqQbKYa2g3az20g8IEyZNHKYvV5HsjgB6Y4O887/cF5ssx5RSHtz9g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868101;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=qqi77ZkKSIAV+/rSYHxnLVsMdRWBTOhy0XP6QznP3ZE=;
	b=zodmkXPf5ksDrZjWB2bxpJ1nSLsxkFheTM99aeh7lkMZgySeSuKR1GpnQBQ3NMQfK1g0
	 NacE6uij6Sq1PuBtrPQ4bzKQVMgyRC8keSvcaCARyotj6LI2NfzbV3Nh6F8oSLMYaGcxf
	 258Cms/OloXTheGU/Ob8GvdPcxA6ICotsmGsUtdDR3PZDCUqgKYeAk/ieVFSeASZjfsWL
	 bwL0rqzebQas7VInoh5FKu6/JQ4DeCiciOwnPx5V/Ztwhdvi5oQ/lS7jrv9hsJHLBiwjB
	 2eDf7WHAoZOjAMT9g7OnsycDJvnMf2wZ4LjKE4CskUH78qD1xKv1XAXdGZxFek3+XNQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=VjZaSkAB;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=X23pDdAh;
	arc=none smtp.remote-ip=103.168.172.145
Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6D11606A32F
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:28:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D6D11606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=VjZaSkAB;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=X23pDdAh
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.phl.internal (Postfix) with ESMTP id 076A2EC0875
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:28:10 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Mon, 16 Nov 2026 17:28:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1794868090; x=
	1794954490; bh=qqi77ZkKSIAV+/rSYHxnLVsMdRWBTOhy0XP6QznP3ZE=; b=V
	jZaSkABmSEOzPSVdlCJqQfdwLTutmDRznCvoNOU30ykS0q57G6JgN+LEIih4i1js
	Yhk0FfGAzFDW0UBL0F9lzadYlLev6pZH+H7aNDX+0pQGBhiMw/kMU4hjYALaZpJB
	3aIcgIFywA4DhTcoAhCz70hc8YaOK3ppX/Vw4gMNK6xzIIqJDjLjrYDNeQ+/1uNN
	7kXRhs/4c9epsnLT+jEdyHaVvF271SW73A1hDd728T+uodVl/oLStESusJb6PeyV
	5X2VrM6qh4NHbCQDRLk4xwuKIlMpiwbVm+xaNgqjkFW5yyahcbF0EoyuE5Rmecu6
	UEard0x59kydNxw3lIwXw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794868090; x=1794954490; bh=q
	qi77ZkKSIAV+/rSYHxnLVsMdRWBTOhy0XP6QznP3ZE=; b=X23pDdAhBRUVc34sl
	33waIHKyTbfhSn4ZdkW6eyUjQgRjEYIEIDBuEjOJM2Z/lxUie1fb8WdU+q6Blj9w
	XBw+Jl4fA+pr6J2dyks6hbfLMmC0NC5jeULZ7f6hvky6WCEsMk35YQzolyBUBk/d
	OoRmTXBahCFE6EZZ0p71PsDz6h5FB+I6LmaB+59Lj//UFyfffEcsEo77PwNt35O1
	1NcLxrBIefepoGaF9k0QLasosfy9MZh0PmlejFWapuj7luyTAo76mEmE9/hbwYeB
	DMd5bFk74+AiT/uCf3Zwt1VDFozH+xF0oWMxXhnGZy43xpzWeD30TJy8RwsKSYxK
	frd4A==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868090; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:kYyh1DKROcLEq+Nj42ZCHybz6yQB2VSz20q4YsYkgBoqYlE
	volLSIHszeWp4ARckOtPKaKK31zBhwUfcEoaTZpO+HCHYOzv5xn+WeZQpfktxgh4
	8Q26M56gDfU58Vkb7GTU7QS1Ivc5cFMo73WRDMRnAKD206a4gyKmym0qTXiF+ax1
	f3xKUnrgJ/jp42SH2SlW/894d09p/gI4PAYUrlBltNKjG8guUT1KTPJjBloesUs9
	Ohtaj4wsN9ZTWJvou2Gvm96aNi+F6FQmMaIUq6ljThWRKaFrZ43CdmduPQofqV5Q
	WeO6neR847wsy9GU2+kBCAZ/Sfs3sFlf1ZoGYRw==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:ApfFSiRwpCfpVMyVkfIYmua5MsNMbIm7vjY6Vj2T1QQ=:I9nI0lk2cr5lH+J9U74K5gmMoQERmwTq1m7I0uiWfMU=;
X-ME-Sender: <xms:eYP7aoh4GvwMcUaMuhAFIO8-dWe41cQVVWpU_A5MxwBtLV2ojzP41g>
    <xme:eYP7anAhgwUxbanx15fxRWX760H6Gtyr4urBG6uNw24_RrOPUrLUoB8QJ1cMxAJ8-
    QSM4VVK7BKngzePoA__Bt2VmLB7LevD0x8TFNniCLMvu9XBhOFQBA>
X-ME-Received: <xmr:eYP7atvSaFCw5jqXNRHbgCTQHPzlbk4BD9HAIyje0jc0E2k7rdZBLtjJ5AclHHWP6bpmycQCZQaVlZ_jiFhl4UdThh0>
X-ME-Proxy-Cause: dmFkZTErkaN7fVlPtNDdi51QiCO3Jwu/EXF3J4JMuaS7oz4sQp/qZo92lHHso/nWqftgyo
    shyiFCj0XGRYSExSdsxL4hZ0eCGOLV8mdTnhPW/3IxcPtNhSCwG9wLFNy76VI24xFu4ost
    cdj4rolGfawPJ9mrkc2UnaWOhWCb3qwejaEqCUg6IT1FzkPrNHFz/nHJfXLhgJa24ZebGW
    tQg5xOXzqJu9sqHXTN+/hdVrPyA3Wqmv5hNe+T+H/A6YvWinAi39i2SGqCL26UC4/KTq+9
    m8DHcWgFwNUMzdABkBY/R5529o5EIE0s7v2vMSEh9uYeOz2vbbRYdTM9mx5w9UjtRa2IPu
    qkk3CB48rT0YS/SWrXaOvpLcHaaguDX8XXEur0N/VsSqB7dURXaHqovEZEqMWg9HAXc+W8
    W/zrnUlZEJaQLqzRJ9SeeE0l8FF45NZv2HI/m2jF7igw5v8Vq2FFe/N+ynoUppnQLUzyHs
    T8WboxRZBf6Ip2WpKnLtUXqOpHIbieugL7/r2oNJceRlx97kFlUcg8onORJ4NF4c1MEvob
    30TcTBJ3BCyq4PRDuijhb0pGFd6sKb73XLFt2WjoyuV303/InF9eMOn3npNab5oxiXGq1N
    aVW+Vv2pjJ/za+UoHiHI59W/XDXKZ9DEuajZ3YLzvlGeyRPTzEmuDb23gewA
X-ME-Proxy: <xmx:eYP7akbS0N1tMroVgtNmOQ-PWsdF8x7lQ4yIWGrAurykVcNAzIOBfg>
    <xmx:eYP7aoXpIoWkM5Ha76LW2qq9lj2SU8-Yi4Z0RqD2aOq96eQax3NW1w>
    <xmx:eYP7ag7X3kf3f1PS58UrOGVr8vV0Rd-4yAFfCaKgBlLTaAEoIdR3Lg>
    <xmx:eYP7arjXlA9SfgR7snoTfbOgM_-lXbXimhKPYVrKz8MGRUWTTDRaCA>
    <xmx:eoP7ar5q_qbIvztgTHIYUpupVjTKFCQo9GlJmC8CSCy1-ESI6Lp0PAmT>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:28:08 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 4/6] netconfig: Fix the RFC 4862 2-hour rule
Date: Tue, 17 Nov 2026 11:27:50 +1300
Message-ID: <20261116222756.2921577-5-ryan@testtoast.com>
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

RFC 4862 Section 5.5.3 e) says that when an RA's Valid Lifetime is no
longer than 2 hours or the address's remaining lifetime, the remaining
lifetime is kept if it's 2 hours or less and cut to 2 hours otherwise.
netconfig sets it to 2 hours in both cases, so a prefix being withdrawn
with short lifetimes gets its address's lifetime raised to 2 hours
whenever less than that remained.

Fixes: 6adf0f5db455 ("netconfig: Create SLAAC address")
---
 ell/netconfig.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 7e20de6..2eb9cae 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -823,9 +823,14 @@ static void netconfig_set_slaac_address_lifetimes(struct l_netconfig *nc,
 		if (memcmp(prefix->prefix, addr, 8))
 			continue;
 
-		/* RFC4862 Section 5.5.3 e) */
-		if (v < 120 * 60 && v < remaining)
-			v = 120 * 60; /* 2 hours */
+		/*
+		 * RFC4862 Section 5.5.3 e): use the received Valid Lifetime
+		 * if it's over 2 hours or over the remaining lifetime.
+		 * Otherwise keep the remaining lifetime if that's 2 hours or
+		 * less, else cut it to 2 hours.
+		 */
+		if (v <= 120 * 60 && v <= remaining)
+			v = remaining < 120 * 60 ? remaining : 120 * 60;
 
 		l_rtnl_address_set_lifetimes(nc->v6_address,
 						p != 0xffffffff ? p : 0,
-- 
2.55.0

