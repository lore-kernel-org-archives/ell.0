Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.145
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868093;
	b=Cu5GwPsm7hU6gEP/VL77giE+VlLcMH1aUvd7Wrx0+jh8sjOMOhKAfjdUb0sUXDEuWyAM
	 Myhq5PJvq+xcQ7Rlfk+eLK3gqhhajnqOp+npksXIckMhbJEaxFQvBJXXfScxTvvUlXclP
	 hhdOWrlOlNupMphxr5z5rKW0+oiJDSathbEGZxzHoR9ZzKnbnqptCMZcV1hJ4uT4E479F
	 7kInnsJvlPy7iVGf0QhZWX3fBD3hEzVF0+1HKSKLqWxfvTxyIkubQj4adi9UYSGTdFRvO
	 KRMtzl3NsYRTeIPWB4Z7aG6Y7IhyJVGGSEdsZ+jch7JBBTAz4WMdkeO/rQYjRh/N7AQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868093;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=cgczpjLHqOGHL/p5KovmFCdhhYTfhA6NMF6fONu/CKc=;
	b=j6BjG6FG163OU+JQlMSoMIcT7fUU/ETUueImLIjNVKYBqaNhW+7ePSUYAOCNS5QZvga5
	 CsNsDJaBQa54RLMEMxw8SXsfvGEm01qazX2rTKp1sbYOWpHLhjy+cvlBRTyEfxT7aqYIm
	 MHV38WEBS9paejhThtDejIGfmat1t+w+ISxIhDGpT892u5rPIpJrlqhluORZwbcLJmAiH
	 219V89/HTJFfIYtznxPh4N3KzB1U1ZjYCXFiGV3od6Kaac1ug8eBU+vJo1oT5yPjnTs9G
	 OcaNezC6LeU0VrIfq0AInfkJQGW2kG7LUI8oZjjy8ig4gpOJuTyZKWntK5pFMhPeKig==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=iSfiHPRR;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=zTIddR6Q;
	arc=none smtp.remote-ip=103.168.172.145
Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6625F606A329
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:28:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6625F606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=iSfiHPRR;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=zTIddR6Q
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfout.phl.internal (Postfix) with ESMTP id 92317EC0862
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:28:04 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Mon, 16 Nov 2026 17:28:04 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1794868084; x=
	1794954484; bh=cgczpjLHqOGHL/p5KovmFCdhhYTfhA6NMF6fONu/CKc=; b=i
	SfiHPRRfECC4OPzdxjcodPtqwDsVlBHu72vH5k4es3X37tF3BPofpIKv8jwq1Mci
	HUT7BemE7Fn5zfLd0/+j1jSZ/J+JghmZIMjCMdHvOICbLCJKWVGrDj/GFNY79T1I
	d6O6We3v7rmmPooviNiiqZDYEA1BbyoKYDNJeoROTziFCV/R5AucTYQvQA5llQ5m
	6eLXHmzIdCKQqoLsD2CcrdhRNIynWzbcvU97jJzWd5vswP88FVRNkjzyFmNefB8R
	Bzoefj41IR2BSxHYrE15BHxtqBmQK9QVfV7QsIEzE1cnUC8DYdSHmcKgLVQ3RzBy
	w5Guyu3MA0zwTnDC748Sw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794868084; x=1794954484; bh=c
	gczpjLHqOGHL/p5KovmFCdhhYTfhA6NMF6fONu/CKc=; b=zTIddR6Q2uYVRbK4X
	3ajLIQerhqWD4hS62AW/CEbp0ejuXGtbEAQoNfRX3jnCXu754sO9J70Wr8M0RZf4
	4sjM5RaNllZFR5exbpsyxzxW5eKsWpjOKazZpEfmVVfEH58v8Gk774Ma7xGeOjMy
	KPWUWNW6dHRMfd3AeO56XwKJLzj09xU3rw3HiP8GwGiuaJYjVzRzynJd2aNID04h
	l2DxCtrX1XB3pcvG+KrJTJKiWW33jov/w43nqsVW4eJ8j14Et6kwFjhMLGG2O5dF
	epa+ZBtZZGYe6aSJAU3+HQKL4u+7uQt0iEvYi3BI/jXoHwyq08kmN9V+hGDjesS6
	C8f3A==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868084; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:mRzYH5AMMBztvXcy+mwCHTfFud9s5vJ+fsCZT9EYsuIAOK1
	gB5PiVwWE8RWdNjsvWZNddEq25zrVJZQ5VZ1g39Bou9CWQh7pq0gAWB7McbpDWgA
	TryUz2jPp9bD3NoU3yaxVhg9v1telvSjLHE/CztmizmRPNdaIcmqbSW74xZsBvFV
	FWUKIEpK0mAaoAespqBWNFg9e/JkSfiHijlA804/9tdUktIvVCitnS9fDQO1ai7O
	+DhcwXFCT5J3LlKn9Pas6kqO0SS60xlSmr8EFQ8jGIkRHtHayLb6DU60gALOCnH3
	6ZLvcJgxj2RLMRF49083ouL5MRLoo/dqDfJzdzQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:nyLIb2pJuEeM/7zsK76ebZ8Pr+VBGsy5ETfksWljJJE=:q6tUWGN/VfFZcYpOVsDg7Zyww8C8gtLGvdMPWnKDeY0=;
X-ME-Sender: <xms:dIP7amlsHtSRu350XisjvbTuK8ZpTBjOVT5P4d48hYaWlKgbKGUk0w>
    <xme:dIP7aj0eun1aMaeVezR8nwSRsWbviKfK9CrPKqI6mhjV23CVDu8-oyJR-EpCy2sCa
    PCtHOXsqrq7TXimoOisJ0yJnrbo0hKMVgvjgb16ynPsC0kdVlr3DQ>
X-ME-Received: <xmr:dIP7aiSk7rm42u5YXrIIVAhKv_JESjfaXvj_U-iuGWbnBI8xoxTuyApXXzM0nRJ0WNO5KD1QrAwwIvXX-JTUB1iAgTg>
X-ME-Proxy-Cause: dmFkZTEEP0tiYnfrv8FOZ1/e/XcawF0bDm8Q8CNNJfgGlGTzEU72oaYms7G0oYWnigKsZE
    exrS0TVgC4VMYNKN9tMRgtVhq7JX7G70NYb4NbB47ABpcOBsnI+UAX9ECEsHZYX383LQyy
    wjQKVfFK2bpkd6rniJ8DOSwKdaPLImMl31mgaEv65z0wlqWyFbsp/dHW3X77DfVnwwqPNv
    1SqOHyMJSpQHvWu8qv7VH0cRxG668rltANRzGKzqCEgz4851QEQOtnKPL/T75QPzMDHUhs
    +Y/pz3rtL3AObiQR+ZIO9M5aqxxjYqNRTcgrkSSbw4+ednrGcDnf5OuY8cYq33vOIDigHM
    q3z6v9IzbHBG7gR5qW7VcRn2rza+/KPwoUC8LouQ1QjS1NHj23scwTZvWybk/7CfeTb9Pk
    WkooFtbhMWcudi0RbUw411vwEDqXwTgVFMQ3cCtMH4YDm98t6CtCZ5FVR7JtmQeHSNSQaV
    BIBJrwqmqNWyVRFNQQAkR0hhsnOo4hrGLtw9rpk2nNSWQjh32rJzv9apBQVTfEB2Tfzem6
    19DDddqtqvxASN9HOH6LIPzzf0YUZal3r7ZWekBq7V5VGp6n/R79Vp6PbPdy5GQ/sF+ctI
    91W0rIm51l0qY5RC8nLN8CgizgKMtgdiFlwPp55GfIPogSV2NnkxIiCpe/pQ
X-ME-Proxy: <xmx:dIP7aluEHkPSVzYveG5CWINn0uZYlmee1bDzhhUNR6ptY8PpuTbRRA>
    <xmx:dIP7anaaktbtTSqaEAsZQiqsmsF4kVQeNcu1b9MulxdYzLNmJEV-Yg>
    <xmx:dIP7aquzkWlPTYuXZTSm-4seQdixYuMNEJFuRV4PPCT-VNDBPjvoGQ>
    <xmx:dIP7apHUraH9QAK5K3DblBYT9DMee7NPe5Omako8320LVCuQ8aTIOA>
    <xmx:dIP7ah_jViH3eRkMvlIBkWRIhRAYpl2J8o4ao0R30dxEL2P0S6AG6IrO>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:28:02 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 1/6] netconfig: Allocate the expired lists
Date: Tue, 17 Nov 2026 11:27:47 +1300
Message-ID: <20261116222756.2921577-2-ryan@testtoast.com>
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

addresses.expired and routes.expired have never been allocated, so
pushing to them silently does nothing.  Expired addresses and routes are
leaked and users never see them on the lists returned by
l_netconfig_get_addresses() and l_netconfig_get_routes().  An IPv6 route
that expires also never causes netconfig_signal_expired() to emit an
update.

Fixes: 18c4434324c2 ("netconfig: Expire addresses and routes")
---
 ell/netconfig.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ell/netconfig.c b/ell/netconfig.c
index 9cebdc3..2444d97 100644
--- a/ell/netconfig.c
+++ b/ell/netconfig.c
@@ -1353,10 +1353,12 @@ LIB_EXPORT struct l_netconfig *l_netconfig_new(uint32_t ifindex)
 	nc->addresses.added = l_queue_new();
 	nc->addresses.updated = l_queue_new();
 	nc->addresses.removed = l_queue_new();
+	nc->addresses.expired = l_queue_new();
 	nc->routes.current = l_queue_new();
 	nc->routes.added = l_queue_new();
 	nc->routes.updated = l_queue_new();
 	nc->routes.removed = l_queue_new();
+	nc->routes.expired = l_queue_new();
 	nc->icmp_route_data = l_queue_new();
 
 	nc->dhcp_client = l_dhcp_client_new(ifindex);
@@ -1405,10 +1407,12 @@ LIB_EXPORT void l_netconfig_destroy(struct l_netconfig *netconfig)
 	l_queue_destroy(netconfig->addresses.added, NULL);
 	l_queue_destroy(netconfig->addresses.updated, NULL);
 	l_queue_destroy(netconfig->addresses.removed, NULL);
+	l_queue_destroy(netconfig->addresses.expired, NULL);
 	l_queue_destroy(netconfig->routes.current, NULL);
 	l_queue_destroy(netconfig->routes.added, NULL);
 	l_queue_destroy(netconfig->routes.updated, NULL);
 	l_queue_destroy(netconfig->routes.removed, NULL);
+	l_queue_destroy(netconfig->routes.expired, NULL);
 	l_queue_destroy(netconfig->icmp_route_data, NULL);
 	l_queue_destroy(netconfig->slaac_domains, NULL);
 	l_queue_destroy(netconfig->slaac_dnses, NULL);
-- 
2.55.0

