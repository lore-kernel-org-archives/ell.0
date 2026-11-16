Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.145
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868583;
	b=So0C7T+sByTpxqx1gCgcQ/u+ZYR3OEnTjOx773PsU5z6xnNvR8ouEth4X3PmutEGXqhD
	 Uxq7+C5qjHRY96miwT62NxFwZLc5f3UrmCgUsE0nHKpUyhcGBcgMmsCmVTVPfrINOO+XE
	 yne6L8bjvxNUdMv8cDU5/XJcyhHGQVu+sQnrST3yEJJsGy1DshwsT6O7OfnHWs12wtSdj
	 HPODI8f3tCeLwjqWRuUKqb/ZASs0uSuauDgcqwL3CLe9jQKdInp1eaFJZsClh+1icQgnx
	 EdK6JaVpQ/ybwfLZ3lu4S4LFtb5VRwwEAhC12hcruOjglt9XOIYzFVk7ubC1oUzPJBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868583;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:MIME-Version:Content-Transfer-Encoding;
	bh=yN1gagJ9fGfQQ+a7Lm589tx3Q3842QeuyvWmspICW8w=;
	b=tyXqzQwZpyIwyGVDdj/8GO+fvGloYNk8urIKbQxEWHJUpLVmafkVjzgQq7qkYtqDY33d
	 Kxc2XpThFtgxvrTJkfOvDzAmF0HlGsefEgXkjGb7eJ8j1yv5EhAuxPISJ3BR4XKA0b2EG
	 X0jn3sSsRbCVrkUo7lzP4uf7A0FJE4RxfGWbwZ5o+XY6UZTEo36r4PNHK9JUVxJ7IimXc
	 Hh7IrOBXBVjilpKM9PiM14jp2PW9k54ISAr0mrtwaBfUdae8485SlPiMsRjakTaAUL/uL
	 rpt5uY+EZ1Bxuugs1lEGRFOdpVB2SF4bRjOk4KFAWcK7h+zjVVx7dNifHn1fRQPGCDQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=testtoast.com;
	spf=pass smtp.mailfrom=testtoast.com;
	dkim=pass header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=rvA+Otys;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=NL8x2EJS;
	arc=none smtp.remote-ip=103.168.172.145
Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E25D606A883
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 22:36:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2E25D606A883
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=testtoast.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=testtoast.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=testtoast.com header.i=@testtoast.com header.a=rsa-sha256 header.s=fm3 header.b=rvA+Otys;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm3 header.b=NL8x2EJS
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.phl.internal (Postfix) with ESMTP id 4E3EEEC064B
	for <ell@lists.linux.dev>; Mon, 16 Nov 2026 17:36:18 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Mon, 16 Nov 2026 17:36:18 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=testtoast.com;
	 h=cc:cc:content-transfer-encoding:content-type:date:date:from
	:from:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1794868578; x=
	1794954978; bh=yN1gagJ9fGfQQ+a7Lm589tx3Q3842QeuyvWmspICW8w=; b=r
	vA+Otys1hOYR40IC9n59rJuErN3jqAcN5d53D/qjlfAhFmkyVY3fX16SEtdwdZyb
	mYS3nmomms88qp/OINFDUf3xPZN2/zS+se/FHCIaT2fG7jL/qqUR9Uar/LmPmZFH
	ShhQ/9Oct0cxbSFJ6nDbSkaum3sYO4HWotxL+kXxSfNz5wtPZIvUhTfhe132Q4ud
	jICq6WUW3MzHcSxD3bxfK7LhJxS3BNU+tUTgZ7oOoz/SdMaUmxE6tn2Y1++vpPEm
	/B3iXlAM1HpJL+VsgzP4Mfj02RZ4N6oSUqu/ZJLRaEQwrQywybBFc3Kdxgp3Ekvp
	W8pS7p8wAu1XqrjQe9GDg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1794868578; x=1794954978; bh=y
	N1gagJ9fGfQQ+a7Lm589tx3Q3842QeuyvWmspICW8w=; b=NL8x2EJSkq/I6e/Jf
	X7AxG+Tq2F3aTeaAOEyHkiEv7NSNJb8K98Tc/huN9XTLA2xcuCogStLPulOS1ABU
	CYHMAQuFWYghYtUtIunmYRX4r2nQnpMaiS6najQ/imQSYMiuQN6rO53TTv2a5egV
	Vgw9k8YIslvCR7vZJQ6yNcM+QYkGSC7rzAyUYbaWGs209YSQRd3v7vrR4BuFgVh3
	gdLJHPzODXqhqWoHtbXO3W1Fm+2GlhtiNBkN67Qi1mO6tElM8jlbCTFUFZBj6pcS
	TsvG6nlqohF0wFe96kv20lyOIYxss9wCP75Eua4akzafGFFDC9hByzhr+2zETvrF
	ZZe1w==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=sign d=testtoast.com a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1794868578; d=testtoast.com;
	mf=PHJ5YW5AdGVzdHRvYXN0LmNvbT4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm3:rsa-sha256:JLcbwsWeGZtAXc4p5UGk3v9j5tb41usYAErPlffzOvyeBqb
	bXUrEXKRJBYUvFipVkcXviFEiNqw84SMJSJGxBFBZYhTbiVfsd4XIyR/X18MJoVw
	0XnaGVDuiqoImhFVurQEROPm6sGR79Dw589Zr2QT+F9JsoKeza3l1VTRFjDez3A0
	OH815q7T2+eTgpOgCPh0/C7kufjrswlmXI0PtnJfmqRW8ZLC5zFo3rp0sXGVrerI
	SzJMEYYIXE59AIQQrPZCtbEvrYQ3YaMEuz2jeqEcE6KbvijsXLmMD06qy+eBbDFQ
	TBUR9Lbg+jUzTVb9YIP6zceqsGGTfLp3a4MtnIg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-09;
	repo=github.com/dkim2wg/interop; date=2026-11-03; sw=lmtpprox;
	action=mi-m=1; hc=11;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,subject,to;
Message-Instance: m=1; h=sha256:qwob5cMG6nmjOnUB9WOsBrBGyCHd0V76UOYU7qovZck=:l5ekAZbEbm7xuVV9afrRXppGdTiB1pZ6UQC3LWQpW2g=;
X-ME-Sender: <xms:YoX7auOj0v9P5EEOsJGMxaC5IRfKHA5G0SFXX_RM4v6oK_aYt1FUUw>
    <xme:YoX7ai9ZxfNef-JxhcnQdDUsXFBbJfPfYNPkZtrY_pbkQPbEY8a_YbkvmHgrRyVoC
    J7on9dY7AIxIHQrUfv8UPQYnYC2NJFDG0Sdqeupe_5a1-qbsK2AOA>
X-ME-Received: <xmr:YoX7ai4pxEYDzpcCveTQzlkf-OZTmVoys-hiUVew22_3pMCCYW9feQ3xmDk5hXkBbydEneA6ecPFxRt8gXrjC0J5nXo>
X-ME-Proxy-Cause: dmFkZTF36C3NT7cHnVWiWCI6bCfNYMDlwKEQAZwnmNaEgQ4Q2+9Z96+SVG7rJuQQpPHVo+
    F5qanRWAZdphUmDpNr8zEmrk0ZCF9TkCQZEMxQwnGl4QgVztlgvx16YIPhwXd6i2kwKQeb
    5Vjzn5j13ZP2qID9CfQlbkRTL26bScgdXoh/1EPAbS5wVlrJMfz7/J54Zxox8fUp+JyEEw
    GUmAJw9+u/WN6k25SzoYAIpwp5e2gVVHCJf2z+bF27f8X+MkVX5HH7ZZCutOIbR50KzG3l
    4QyQ79lZ56FFxxrKprlZkINDsoeIopI0dguP2UvcXtqg5IWm4zfd70+RTFDxwTJC+Q96Y6
    EFMTdT3u/hhM62fh1x/uhTtmpaE3bpxU67IF/6GfMZDGRu3OOh+HDmv/ZRZMGRiZlHgGGp
    FlkaaGg0raPsvSnVtQFBmr67pqckBRRqxV/6GLHPZH/eJYldxkwgiK/B4BIPpgImTHl83X
    r5j5q9rTC/RGXPF3zzD+ecECVP/NTsCt5R6IEaK/jdWGF7rUXpt7Z+x/tM/GjdX/CoVcPk
    4fRLusXi0smyDEoUf/M+mRe/b6/+MmQYHsWu44YfBwNizv6K8rMrgv4EXM3k75mD+OB9YW
    tr7MnaBeP1WiKz6j9SLwqKuXdNX1ULGXKbfwEaU865KbWk/jxlsru9LZvgfw
X-ME-Proxy: <xmx:YoX7ap0lx2A99EX30kb2TDrRMIY8fVlfT3SdsXvylX-fxda_LvMw4w>
    <xmx:YoX7apCPGN3JPU5ibKm0W9sfSl39u1D8VqV6_VfolN4y6gAGSX7cIw>
    <xmx:YoX7ar1ryApoRTR1V4TQmEZOLNp7-Rl5hiAkdRDdp4bxbcFaStjk8w>
    <xmx:YoX7ajtg8rs827TuymQ60536n3OgDroqRWGIKhaKxyBoxUSCwDMeQw>
    <xmx:YoX7aplfbtthXB5IciJ9uDmps94z14SaVRlz5ZDmEchknfVSyRHklaIw>
Feedback-ID: idc0145fc:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 17:36:16 -0500 (EST)
From: Ryan Walklin <ryan@testtoast.com>
To: ell@lists.linux.dev
Cc: Ryan Walklin <ryan@testtoast.com>
Subject: [PATCH 2/2] station: Unregister BSS objects before freeing
Date: Tue, 17 Nov 2026 11:35:39 +1300
Message-ID: <20261116223609.3134127-3-ryan@testtoast.com>
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

station_free() frees the BSSes in bss_list without unregistering their
D-Bus objects.  Removing the network objects doesn't remove the BSS
objects below them, so a GetManagedObjects call while iwd is shutting
down still reaches the BSSes through the object tree and
network_bss_property_get_address() reads freed memory:

  ERROR: AddressSanitizer: heap-use-after-free
    #0 util_address_to_string src/util.c:115
    #1 network_bss_property_get_address src/network.c:2197
    #2 get_properties_dict ell/dbus-service.c:824
    ...
  freed by thread T0 here:
    #3 station_free src/station.c:5269
    #4 station_destroy_interface src/station.c:5337
    ...
    #8 netdev_free src/netdev.c:1047
    #9 netdev_shutdown src/netdev.c:6896

Unregister each BSS object first.  station_unregister_bss() isn't used
since it warns about BSSes without an object path, which bss_list has
when the security type can't be determined.

Fixes: c639bf0b1942 ("station: move BasicServiceSet DBus management into station")
---
 src/station.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/src/station.c b/src/station.c
index 8fcf8c70..bc04b3e8 100644
--- a/src/station.c
+++ b/src/station.c
@@ -5193,6 +5193,8 @@ static struct station *station_create(struct netdev *netdev)
 
 static void station_free(struct station *station)
 {
+	struct scan_bss *bss;
+
 	l_debug("");
 
 	if (!l_queue_remove(station_list, station))
@@ -5264,9 +5266,22 @@ static void station_free(struct station *station)
 
 	station_roam_state_clear(station);
 
+	/*
+	 * Unregister the BSS objects before freeing the BSSes, otherwise a
+	 * GetManagedObjects call can still reach them through the object tree.
+	 */
+	while ((bss = l_queue_pop_head(station->bss_list))) {
+		const char *path = station_get_bss_path(station, bss);
+
+		if (path)
+			l_dbus_unregister_object(dbus_get_bus(), path);
+
+		scan_bss_free(bss);
+	}
+
+	l_queue_destroy(station->bss_list, NULL);
 	l_queue_destroy(station->networks_sorted, NULL);
 	l_hashmap_destroy(station->networks, network_free);
-	l_queue_destroy(station->bss_list, bss_free);
 	l_queue_destroy(station->hidden_bss_list_sorted, NULL);
 	l_queue_destroy(station->autoconnect_list, NULL);
 
-- 
2.55.0

