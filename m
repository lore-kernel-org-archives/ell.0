Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.158
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868579;
	b=W9MV1B5kh2vGNGwNp/4odm2nKv/3edf0rk+l9o0py87lonGlTQZiNzIyiRs/HYqcCVnB
	 C3YDimZd9qQqqeizqJ3O9yyLHPjP3rHNgZVMBI7sf6pkppIqc6LL+Y1GSTKvYgPDnomMn
	 8zCL73uDurrwl8AVE+xsz8A3YUn/QJXi+A3C0bpMAypSF7Y3zayu7T4QHR++buBaoa/OI
	 5fci6uKwaRkAG0N/RsQT3BOTHMeqT47Nkg7/ujPgDS19an/VgkHzdXCF7brOyJx/N297V
	 F7EYh7AFckm3uQ1fw4qin8wUlNiN78nex4qmR//H5a6tDnCLB++b85On9HJCzrg8HpA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868579;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=/sExBgMG/3l+T/fbnUN919o6UPLky2EqFi8C9b7d2qk=;
	b=q5oC4R6iwymzV1yYhFSq40KqM2G6Mv2GABRCRanoDSzBi3MGIsbVXCu1fky54yA34vVv
	 FA0Dplgu0np+tjTrF1PkuCRD0jldPXoOw9RZ1MD6Z7h+tVwvZQFA7dcz4/UeOp4g73wrL
	 Glqp3GbPsMfSfdphZAj3iJCAZ/7rxh06GapaH+hafZE5cMZXt1aXDqgoGAB+e4dGR71qS
	 W3HQTxcpfK4clxgWea6TkTqfmB8VwwodhFBT+NjzqXbDFnjxSSflqqSZ5KJaVvUptvlZR
	 UBVoeCLM890FvF5BfG/v9aOLrL0jyr4+DWTMJUjlCEoQ3iXgbJbB6ZEhAjoDuT9r2oQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b="Yh/4Wuj6";
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=MEOJ3+gf;
	arc=none smtp.remote-ip=103.168.172.158
Received: from fhigh-a7-smtp.messagingengine.com (fhigh-a7-smtp.messagingengine.com [103.168.172.158])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E35B7606A881
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:36:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E35B7606A881
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=Yh/4Wuj6;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=MEOJ3+gf
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 3B50B140009E
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:36:16 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Mon, 16 Nov 2026 17:36:16 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1794868576; x=
	1794954976; bh=/sExBgMG/3l+T/fbnUN919o6UPLky2EqFi8C9b7d2qk=; b=Y
	h/4Wuj6vHLujeP7UebdffjVO9T0SQlzkwBPQVMiA8ybrku885MoPAG74+2oQx/gG
	mEo0SpdnNVXLJfR73utVYNd10yGyVUI/1ogZeQpqaXuX1A8N7wZls0xwYCz4wfad
	mWNqrh0NWT6e3pwbiUTE1C+um/gFeSJJaaFEVcnMqDc8kld1NH6CH1oc14U8XAeR
	+wyc6bTdz7PQqyxBfEBELtgjxG516OhkMxxAzX+wOxwtcvLh8jbmZ4My3JU9Zp3U
	xDYxzu88q4PI52YiIHcyELNHiX9LnN+5H1qTEONtR6CnkhawSNHTqTaiPLDo9to+
	VHLLj1+3Y0VWjA0dwlzyw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794868576; x=1794954976; bh=/
	sExBgMG/3l+T/fbnUN919o6UPLky2EqFi8C9b7d2qk=; b=MEOJ3+gfljnYF0Vul
	dgMLQVl3/yl7GMMLKX112vYfqdhb4ZlgUAarjY8//MBibAyrY2jKhuje+zpX4vpB
	oBBAzm54zUhCNrfso91gndwG9vweZkkaTBw9PHTWc1FVfqVeJiR/yDVdxWZdQccX
	XHkzkSyTYOWoaD0taQLOpE063kXGfPJUI8N4xpZxsmOjHCkxHguRWmTh1SQgojER
	md39jlPsCABi5kaVlBjkcfNJUOiRo/IBa8CvcLBpyEzwGJF/xl9bZHYVn6R1MiJP
	/Wx31RBVrEwm5/9n6Xv4fV4OG4EKMvBpeOnUJb8hfyj6TV0nMZgUhH9hEuGKsXgh
	IJ0Aw==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868576; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:eRWQDIrMHHHcfJdkQWy+122qKa+CEulQ51aAYRMJYZRz0EN
	lFsx3ZeGpt3PdRoZVdwwoqrUOLYBLtSAEBzcl7mDqfKuYclw4uDXwi7stpUWObU1
	deJeDZvKQI62/ck4RlGR/f0RXu1eEQjcMeQC8RE9i/5ASyDHznXYv6e8aupoW8rb
	Qo8U6hDivQ6NrxiyCXC6INeAO0pvUm/0zMfVERlIhi1usvuNXVTjTpgXsEPfFq8S
	UvwZgu7HGXeAgoNevSD7FlOoh9OUEqmutPbWFbsjo4AKKnrAQ4OkP2oPAPgE4Dez
	ywa+FaSvUw5thm9Dto4gxh2Qg+12xt13F8G367Q==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:OInwMI2Wiyuo+wHNf1BK/80k5y2P7zNJSi7QXahgD8Y=:Tfv5XXl7u3dR8KXHZXxACxpFI8p8GWxp3PbpgLqBABg=;
X-ME-Sender: <xms:YIX7aiOs62b3Ig9tL49b3X0JnIc2BfPIT76832A7eftBWPyaqKf6eg>
    <xme:YIX7am9c13GORfqTaQ1_ByF5hQVYWXojc7zK1ZuneXZEXW8NG2Hi1AGGZLMkoj2t3
    9nUfv4_MruemmULbxnUIC4kB-deTYfrDzJ6-7RGcvCcJ-R9S_WKsyI>
X-ME-Received: <xmr:YIX7am4LW6J38u8uVzsyYDgSTdtX3Px9vXpCm2I-nwUDzrBgyayzKKZ6pWrHToA-hah5SjHFRYFLqVuDhzlHaTHlQ50>
X-ME-Proxy-Cause: dmFkZTFWKSQlCPrvdRXBxpN8MKER7ev+NyDSxhqWKBC0oQ/+4RFSKRJmHjIvZ2v1UCG/OS
    Brgqz7b6vdcbqj6778ue4isvBgQyUEIECZShWjCqXwB8EfW/8L9lLCP2yYaTSh/QoPlMnT
    EXdDRisYp9+xj79dzX0UoAaJLo7vz4DcI8eYU1j8jfjgmZv5BnIWYtqbOiolHo7DtBdy/1
    2Xm9p69O8Ii5cbjSWSZjEoWDa4AV2om8eZzV+ssCyqc9wP9sinsBaTEqHONUuvaptQfQ0i
    9YJ822LbGgvyVeJRZ2fW/0T9ebYBD1YiMa47+nE505BOTnI2IWLrkSQtppAUJddbysGigx
    H5V23O/pSYUz5yx2PLVv6oyQz6IlLuQtoi2ubjPEX0yRthoU/roX+zoRhcHvcV8WyZpgeG
    jKqzbW89Bx4qF9Rl2TAgW8LxwFPjptCvihf6mK+TfASlpQiSKJFzcEk5DyH6HL3uCKSnOt
    FR/rw/elE1owpltFi+bIagsrbO6KzacRlqVIZ/MMdKMfJZdHnKlvT9pDtpT6mocawDp2Jh
    7sZNbDLijVZGro6zGCl7J7VCYeaUiJ8eehKMwQ5V3pDY01kEqjMTmY4/xChow6Q8ts4085
    hP7jUWItPmvT6I0x0jkTHj6nwN7+haN6bM/WE8wvxYjGyrZ7aGYWWTSTwirw
X-ME-Proxy: <xmx:YIX7at36SgI3BHHfEuAuqtDWKNBJcEiT7VrQrnbmgkBmzfv2weaXjg>
    <xmx:YIX7atDb0SrMO8HL9XAOpl4T3oHAI1kiaCbFaxCclPL5VPQsYBDj9g>
    <xmx:YIX7av1iL2igIOz89biZC68v3R5hHMEKoUOV04GuCP6HEaQX0dMx1Q>
    <xmx:YIX7ansm7XE3YMhnNxxHzjxeiRS6n9n2gBDQYekRqssk3BBRDl7MYg>
    <xmx:YIX7atmH8OY0-OFTQR2VVliafkHFA8S71yu1DFO-f6106nNrVDG8zQ83>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:36:14 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 1/2] ie: Fill in pending FILS IP Address responses
Date: Tue, 17 Nov 2026 11:35:38 +1300
Message-ID: <20261116223609.3134127-2-ryan@testtoast.com>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261116223609.3134127-1-ryan@testtoast.com>
References: <20261116223609.3134127-1-ryan@testtoast.com>
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

ie_parse_fils_ip_addr_response() returns 0 without writing to @out when
the IP address assignment pending flag is set.  station_connect_ok()
doesn't initialize its info structure, so it then acts on whatever was
on the stack: it may report the assignment as failed, as OK with all
zeros, or as OK with a garbage address, gateway and DNS server that get
installed as static configuration.  If the garbage doesn't pass
netconfig_load_fils_settings(), netconfig_configure() fails and the
station stays in the connecting (netconfig) state.

An iwd AP with no DHCP lease for the station always sends a pending
response, so this can be seen with an iwd AP and an iwd station that use
different network configuration settings.

Fixes: 8f5f62575db6 ("ie: Add FILS IP Address Assignment parsers and builders")
---
 src/ie.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/src/ie.c b/src/ie.c
index c8bb70b9..836cc587 100644
--- a/src/ie.c
+++ b/src/ie.c
@@ -2419,6 +2419,7 @@ int ie_parse_fils_ip_addr_response(struct ie_tlv_iter *iter,
 	if (info.response_pending) {
 		info.response_timeout =
 			bit_field(*resp_ctrl, 1, 6); /* seconds */
+		memcpy(out, &info, sizeof(info));
 		return 0;
 	}
 
-- 
2.55.0

