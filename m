Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793389711;
	b=H3YXIqoP3wSWZxZI/mxLLTvg11SSMkZHx4sjKp6OLGPZIOFZocFhjFXqc9vHjnUpuIXy
	 bAYtEjbgKPmdws5LUjdy9RJRqAuFIyjcwIS78yE8G/k0KEJ4qIUc7BrEiQAw0gNFCvXXF
	 QS5dPKGhw6dycJ2584WIXCyyZh2fMxvADFIhaMYAztx+4RhnO+BkKDE3DkTl+POreGlTw
	 uae3kJYY7wdtcqsE61yg6UTkW+kmjj2T0grocXWOlRCOyjLJahGygqlClUSisCMmyErO0
	 qO4Qk87OnFupDMMS9OvYrjimKQ65XOItzl1QDAGKFEHXwgUJSll3+GKWicoxaUu2dBQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793389711;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=uKBkSQ7ND37cW1IxBaPve67zUMxweeA6FRTgO4nlzIo=;
	b=YrhUSLy7tDAJV+iTUTq4a1dLx9BhEtS4i8Pbu1hdqstXc2+Z2yNogBp14oVKCiUz6yBi
	 2sgCNbkQihvRvWnV6lY46x+WZm6vfnbJLZNsmreNODjulm7ui8NulFXawZrY+1ivukW0r
	 pPDyVffJ8KzcO+oIj0k5G0NKB29StFmfyhFWJclQVdIwUJ9A610As7y0IGyioOh2K7kgV
	 ZhMqjOXA0D20Ru8MNvkYE+bieo1Sl47WZnMCDOXVmyPCPy8fMlcjhglISlSJd7aWI529t
	 z0CVzPEU6B6Wv60t4OrRaixHainnpAbhK5ibVFEt550gg3dhjlhvQy1ONE8ZD/MPuqw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=cteubner.net;
	spf=pass smtp.mailfrom=cteubner.net;
	dkim=pass header.d=cteubner.net header.i=@cteubner.net header.a=rsa-sha256 header.s=fm1 header.b=WQiA7nHh;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=y3CFy8h2;
	arc=none smtp.remote-ip=202.12.124.144
Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2F65606A31E
	for <ell@lists.linux.dev>; Fri, 30 Oct 2026 19:48:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B2F65606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cteubner.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cteubner.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=cteubner.net header.i=@cteubner.net header.a=rsa-sha256 header.s=fm1 header.b=WQiA7nHh;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=y3CFy8h2
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id 10F281D0011D
	for <ell@lists.linux.dev>; Fri, 30 Oct 2026 15:48:30 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Fri, 30 Oct 2026 15:48:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cteubner.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm1; t=1793389709; x=
	1793476109; bh=uKBkSQ7ND37cW1IxBaPve67zUMxweeA6FRTgO4nlzIo=; b=W
	QiA7nHhOp5HSclSt40WFVJJr7r5foLHbu3ND3QjJMHY4/Tkh7AQOqFpA5vwO2fmh
	wcQwkg6GHbeWqvUvvy2lcWpNsVGpV8Qu9sB7bjqJqKZebXaJrZF0JnpG4c7i7NHf
	h4GiCYIJ3WtbIcTpP1SlegpT1NDGsIw+rYzJT9vtibAhwz1rAN6gPDpFnKIAWKXx
	14gdYSmLBCxBeVs1/ycZwwitvR7FGK1+i+KEAjCIVEY1XIPyuiwC0jos3ibNhWIB
	ymUV4jjjo18ZUZytS1uEfpMNTNQ1N4mS3hITEF8gbY5uge7b5sJhUOyXv2y+WWns
	VvvRIVdhoX+uDotthdl4g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1793389709; x=1793476109; bh=u
	KBkSQ7ND37cW1IxBaPve67zUMxweeA6FRTgO4nlzIo=; b=y3CFy8h23gkZjY4Q4
	DN+u9/kEtHuL5z9X1m6ek7WrZQzvCZdNzPdizmpkRjicfYJ0rcHGWwXN2jAvLv7Q
	kUmOGvupZAY2JDp8fmrccdFoGZvrVpmv41f3Fr7kIpLxbFL+WH1CSqskLJbHeOjB
	oxD4dvTGf8B7v1AfPS7vPy0ikQRRCCw4MUBfx+c6UCnUxGCWtT8GspapxZDNGC0m
	GOwAOMF1Zd3p5Cf7hP5BNV+CyCSHZZ/g++Pu2HxY+SOtpfL760wDth/+oACrF2iG
	C1mfJ05DsWo0UL3PMqFHo6HqatzqAz2dSnMMwPrVp9JShtUtxILl2zqPmzsHi7b4
	N4Z2Q==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=cteubner.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793389709; d=cteubner.net;
	mf=PGNhcmxvQGN0ZXVibmVyLm5ldD4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm1:rsa-sha256:Cqi2k0d+lt0vZ9SinEhNJUCeT1RLQPFI2tV2kG1YVWbk4rY
	TYeO37TyGyjwyevVezBDG5VvtSWpGcfZ0CSIgSMFhO2Zsqueo/ex/2E/ZVN3uF37
	kA0miw2TfekLqyDUcdRwu6leg7+/v/pbf1H2hUtAGWmaHEOe52ONkbrFueess/IC
	KMAl/FYAXvglQkCmRBJKKVPI2WxDcODDpQTWuYRxONI/CXYpxIYqfeEeM9+WkAGT
	oB0I73cL/UkDUw2fQ7IiLD3zT24uKPf8uIPD+U2TafOKPuUR2k97mktgDWvNmNCF
	beX+J980OAdUM+8QMb5RTaVFkqIPoDOnfV7Bo3Q==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:H6GGWEMbo1CVy7Of4PlUXKF6oZxmFyeWT5ldpw6FFRM=:+icdR7vdvk/STYw7bVbCxkdqr4DtXrNjXCvYcptwQes=;
X-ME-Sender: <xms:jfTkamx4flx4IK9Y0ITsiJ4lS_UrazYYMTXURkPAFQEloT9_zaQKxg>
    <xme:jfTkaoTtLYZleRsMti7BbyhNrberNAPgPJpwjmbyJXr7Izz31XjFi1Keh6P8fOzYd
    KHLjQp5edpCecjWDAApT_ikpREVkY1G2qCrfGE6PGQ6RaL_TCYQwNA>
X-ME-Received: <xmr:jfTkal-v6wZG1eH0_zpSZ5coNXWX8pR4kHbCoQHN6dBqiKr6RMKOCQ>
X-ME-Proxy-Cause: dmFkZTEve1XoWMGt7bTlnOxoorkLwy1ZKlnkD9vOYEGRJhRatDOJsEtpQJLUuWz8MNJITS
    AYcJVA4zVDlnCspnoB2f5UDHQOP84gVVy10GmGjA7ZwhnGpNCGBlnbmHcfkqYrljeTw7ic
    5n0XP18Z/utHPA6IwKLEqJcemoshK0gKgLSG97Jsv+NNKVEg6PoeR6GaLzVrEJfwhf26Xi
    X8wtZoIkRsFaexIT+gmBDxP6wVFfwv05ijtdhOge1fU8GQwF9TF4xOZqbnWTLL9iaKbOot
    eaus1g6Bef2XknD0lJM+V2hnX1WaMQI5NtknW7K150eOoJ3rDgNMzIzlBIG9/tx4jULbhB
    Pz4oxeCIfSK3/umjJ2B1nu1zDnm0I94Qz1+bRkYzwsnrynd+Ol15XSz1AUqLvXkS64RmKM
    cRJaOjRWVFgzksOMv/r9TmCQCWO8h/bPStQ4ucp+grbyr0PHGNIX4m0PrRc1xTIoNi15+o
    l8ddoJL9cziPLdkJda/ss36mmp8AkfzjCtZxUppqLTkrq/LKb5QeJ5nNa7VQ6iCQarlLLN
    muiCJsLrHfQzB07WE/ej85V6k+0v7LGlxDy13XBhVC6K40Zs5Kv16bkPbUyZ0pnC5qabzw
    7AmOr3RMt+GojHv8kLAVVORawE6PNSk+A/Ti9nYH69icIYo6fUfn37rDmBKw
X-ME-Proxy: <xmx:jfTkanpOV-dFsn0Eb7RpIUcAqEM4ys1uva0c-LXlk03wLOdrAxLfNw>
    <xmx:jfTkaqmD7P5aVcJS4BPhG7Nf753OKER4G2xOc6dwGBYhBOf1FFVPnw>
    <xmx:jfTkamLQYZRnOETzwVFYhkMtP0YCcjWodF8kx6leKOVWDHC69Z0OJQ>
    <xmx:jfTkanx4ygC6OJyvMB9YHA4taqlyKACouh_0BDnFN4nVX_fSTRZYzg>
    <xmx:jfTkaqIsdNeHkAhAa8vzeTg7Vx6J63XIkIKPZv8lEUNloChSwOzTq9kL>
Feedback-ID: i3cc944ce:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 30 Oct 2026 15:48:29 -0400 (EDT)
From: Carlo Teubner <carlo@cteubner.net>
To: ell@lists.linux.dev
Cc: Carlo Teubner <carlo@cteubner.net>
Subject: [PATCH 1/2] dhcp-lease: Ignore root domain names
Date: Fri, 30 Oct 2026 19:47:59 +0000
Message-ID: <179334935255.3.1163709189217478927@cteubner.net>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <179334935255.3.16564933583527517394@cteubner.net>
References: <528838ce-7599-4268-b7a1-0cc9d7d689bc@app.fastmail.com> <179334935255.3.16564933583527517394@cteubner.net>
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

Some DHCP servers advertise "." (the root domain) in option 15 (Domain
Name); I noticed this when using iwd (EnableNetworkConfiguration=true)
with a public WiFi with captive portal. When ell/iwd sees this domain
option, it rejects the lease, and DHCP never succeeds.

Fix it by treating such domain names as unsetting the Domain Name option
instead.

Closes: https://lore.kernel.org/ell/528838ce-7599-4268-b7a1-0cc9d7d689bc@app.fastmail.com/

---
 ell/dhcp-lease.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index bbf4994..c47239d 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -117,8 +117,11 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct dhcp_message_iter *iter)
 
 			memcpy(lease->domain_name, v, l);
 
-			if (l_net_hostname_is_root(lease->domain_name))
-				goto error;
+			if (l_net_hostname_is_root(lease->domain_name)) {
+				l_free(lease->domain_name);
+				lease->domain_name = NULL;
+				break;
+			}
 
 			if (l_net_hostname_is_localhost(lease->domain_name))
 				goto error;
