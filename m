Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CC6F32C86D
	for <ell@lists.linux.dev>; Tue,  6 Oct 2026 00:24:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791246300; cv=none; b=aIDhSY9whGYfomFSzMAUy2qXtFWYt36FZkJ9/BvyZ4AtEfA8u2rHg+jRqYdO4eyDXVLBg4zj1JhccIao/EeTUrwA2U9PDZVvteqqEsQQpnz54nb+Q2XOEiETNSLXApJ6Cv/Zn4z8iBBLYTT00a7dYsXOO3XU8xCZ3xBNl5ix/u0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791246300; c=relaxed/simple;
	bh=ZiT8XstSasNzD2zdzl4eIc9BXyHE4Ap44fvU/96eAcg=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:Subject:Content-Type; b=O1ciP+ncwn9ZkrOHBvteTlUK7POtdkDAeOc5MDFTzYUYcTZOmNRHzHOt5VzLJncVa90yaoDNkiMUZe8OBPblYLuIr2SoC1KsCiDsCkd0Jqb+APN8GJrQFTlyyNEJLMIicv+q1oZXum1hS5EdcjeTupRIY93V4BXgrNn91iSHBkg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=mckelvie.org; spf=pass smtp.mailfrom=mckelvie.org; dkim=pass (2048-bit key) header.d=mckelvie.org header.i=@mckelvie.org header.b=lIko40zL; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=HCisOmB3; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=mckelvie.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mckelvie.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mckelvie.org header.i=@mckelvie.org header.b="lIko40zL";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="HCisOmB3"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 07E7C7A00C6
	for <ell@lists.linux.dev>; Mon,  5 Oct 2026 20:24:57 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-01.internal (MEProxy); Mon, 05 Oct 2026 20:24:57 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mckelvie.org; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:message-id:mime-version:reply-to
	:subject:subject:to:to; s=fm1; t=1791246296; x=1791332696; bh=wR
	VSzAkxMW8JsEuY+ctHcWkioKuZZCsUEG73B8DYizk=; b=lIko40zLt0AFonKS78
	XrgRMb07slrwP/w1hzrQ3PNxXi7rgF2zKsisQLhM8m+pp6E9IsdmzG//snb+B/14
	IISx6eV32QSMPFWQdFbebLtuAe3ezTLmPQBEmyFWd6YxgZCK0QygsDFr19YM+sqp
	m/Qlr0yjeLafV27ZYXauOLVxlAurNDfiWWe4dh1/2Ubcxea9eJdLoE08gxOrdfkX
	3a0YCCZGRU+dpjeCyTOUVziKOFvipqZNEmvKSqp1w865VlbzKAfvok0FJn3z96Sx
	27MSmPHzhvqMXwigKq5Dm2/ZJ1HGTdawYs27CbNZSLBAmr/+U6oBfhOjcqCSbjOE
	HqLQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:message-id:mime-version:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm2; t=1791246296; x=1791332696; bh=wRVSzAkxMW8JsEuY+ctHcWkioKuZ
	ZCsUEG73B8DYizk=; b=HCisOmB31oGLc3jMS5I+91sB5t/iSnPVDI315Uf2e08y
	kSK5thq6svkwyUOAkuTWh91NtvX2sEDcQsPZHdFQlRuPanOXRF8cIuaTB1703Ycc
	xawbYxqHpouV4onQGNzETBAP0f7hJoBtTlpfHtXIVLXDzJeGKyksMUWsZJVabx6T
	vCvgTYejIOdJgxf2noOrly0ggcRfh79i9ZOjjb1PVdrgrXygZKh7RrD5sv6C5maV
	XBpX8azuWzVWAk82boX/2YSlN8HXEh+/G00ewukqrecWPx6OoqqE2tI3MBWsnN/T
	r+E1i3rlrAolwVEIhll+fKgbliNXsexPBIP/amdBNg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-06;
	repo=github.com/dkim2wg/interop; date=2026-09-30; sw=lmtpprox;
	action=sign d=mckelvie.org a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1791246296; d=mckelvie.org;
	mf=PHdhbHRAbWNrZWx2aWUub3JnPg==;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm1:rsa-sha256:T3bhbCyxYUVh0rvslPia78z0I5BPbRiURdiHYdrpgH73a1K
	tamB2Gf7En0C0x0gvkkOuxHXgS+y1Ja08k4rnfMvDf19AiX8n8AXiB/RgyZ/d1kO
	lfoQDLwp+IikDXswnCMsJL0G6zr6v1H+jm3M57w60s90pnFcgC0/8uPLoLlif4ol
	JLRTdJ9Ql0SDtPGaCZgXGNU6YhLqijXWsty88GNmypKPOeMLnyoz2ezU/DD3RJD9
	+lj54V/wJBnt/3A4SqIV/8Z+w4EI6SOY6y7lfkjxpQXE2821PrVk2vLcF9VAEQSf
	FXuo5Ah+DiMc6ATCQXO0q15u9T0e/4QZBM6oEJg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-06;
	repo=github.com/dkim2wg/interop; date=2026-09-30; sw=lmtpprox;
	action=mi-m=1; hc=10;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,message-id,mime-version,subject,to;
Message-Instance: m=1; h=sha256:3/Zbk9iRu4VOWuJhryuPBzhDpu3VeTbC7YOTOjzfsmc=:ZiT8XstSasNzD2zdzl4eIc9BXyHE4Ap44fvU/96eAcg=;
X-ME-Sender: <xms:2D_EatzOoQfpMpxjHbdiSfRtcCir_8I5Du_zNSqvMJmutSqsNr3ZBw>
    <xme:2D_EaoGPHfb8aVxmb6zik7r8Ehy40dvTdupCN4VbId1zh-VssXZwZnivIcKyEM3ES
    XoLiTTOL_xiy6EX2A1bapSUh-aOgvC-iBbym5iv9d1EgUPFkydA-Q>
X-ME-Proxy-Cause: dmFkZTED2cMGg0S8E2MrmQgjRb+DZfpYcxNQuBKPU0yxCUyA5Ofwa8tZUbIYNQ4eAwW/+v
    8kJrCeaG/H+TK+LOCAqMHJT08tvK+jjbq/zyku5tecqj9ofIWodxWrrv6MlELHcctfR2Hh
    FPp4BfdGbRv3zT9uQXA/tdOu+3bSQ02mMQbaBF0n5mNPCp752wgadQlcCqk0ukUqdwGYt/
    30ZLkDuCHnKPQANeIt+gX9LH/eedoUZr8hmQbIMvFUPmSG7pkbv+82zFhcsv8onWmC+FvB
    za/CgDJWsQ4oHmge++dBZqo+tXaAnEuRRul8sHD6NznvHRcTZIU5Dy78lO/dFVpnY5pmnb
    bqGRI41Q260mT5KDaJB6yQBBmZW5oFoNdA63cJnEjb96HfTvAnZui/bk3UrBQkqJ8skDxe
    yTEPseHUrCly/ezcQaKTt5Hb0PLt2vJdmCrtYHWVOlR5jR7IP8v6kYT2NMeIZoK7P4ULsN
    GSYbKKEkkP2cm52Xf5gr3isn0y+hRTJ2q0ykRVIh3Wp3nn32oy0gLiCJgY5o58w4dHiy0o
    GYhc7MGCNwTF0GKq3KdLxnLnEDtdzbR6mPS6plMfiLbfwso1MT1d+ShKKMKbY+SvUmvvN0
    Y5jKDUfBmxHUJqQGwW9yDC4FKLFndZeJgcW/pwb6OhvQ3FKt13rEOEZhTA1A
X-ME-Proxy: <xmx:2D_EapHVEryW0QZO61JnL6K47ZzYCP2J21moOXMa0IWOcoemsO_UkQ>
    <xmx:2D_EaiogKT1xcpJxBm0KO7F6_TiW4Hje_86Kp_iIFX8xU5pir9ltDw>
    <xmx:2D_EaqQgtevHB_lfWYpl3ALzP9ifVv62ft2VEd-fvYBHJVeo8CF3Cg>
    <xmx:2D_EanM1dBj5tjFeco3yvZdhDHu54IPIIoTnmwA0fd6t9jEi_Bloyw>
    <xmx:2D_EaklGxpWOmsYWoQFYnvmvRgy7d76gdnnmIJZ-jsvkoMsv1bsTvv4l>
Feedback-ID: i53594642:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 99D69B6006E; Mon,  5 Oct 2026 20:24:56 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Date: Mon, 05 Oct 2026 20:24:56 -0400
From: "Walter McKelvie" <walt@mckelvie.org>
To: iwd@lists.linux.dev
Cc: ell@lists.linux.dev
Message-Id: <c5d0cdf2-4716-4f51-a6fb-4f92ae9eb9cf@app.fastmail.com>
Subject: netconfig: only one IPv6 address configured, chosen by first RA (breaks with
 Thread border routers)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Overview
---------

A Thread border router connects a Thread network to a home's LAN. Many
consumer devices take on this role automatically, including the Apple TV
4K, HomePod mini, Google Nest Hub and some Amazon Echo models. To route
traffic from the LAN to the Thread network, the border router sends its
own router advertisements (RAs) with router lifetime 0. These carry a Ro=
ute
Information Option for the Thread mesh's ULA prefix. If the border route=
r does
not find a suitable on-link prefix already on the LAN, it also advertise=
s its own
ULA on-link prefix with the A flag set, so that LAN hosts can autoconfig=
ure
an address for talking to Thread devices.

The definition of a "suitable on-link prefix" used in Apple's open-
source mDNSResponder (last published in mDNSResponder-2200.0.8,
ServiceRegistration/route.c, prefix_usable()) requires a preferred
lifetime strictly greater than 300 seconds, and the behavior I observe
matches this; it does not seem to be configurable [1]. My router (a TP-
Link AXE16000) advertises its IPv6 prefix with a preferred lifetime of
exactly 300 seconds, which also can't be configured. Therefore, my
Apple TV advertises its own on-link ULA prefix on my network.

This is all perfectly valid, but it interacts poorly with ell's IPv6
autoconfiguration. `ell/netconfig.c` chooses the address configuration
method from the first RA received, and configures a single SLAAC address
from that RA's prefixes; autoconfiguration prefixes in subsequent RAs
are ignored (the code comments note this as a deliberate
simplification). Routes from all RAs are still processed. So when the
Apple TV's RA happens to arrive first, the station configures only an
address in the border router's ULA prefix, while the default route
correctly points at the ISP-facing router. Internet-bound traffic is
then sourced from the ULA and dropped, so IPv6 is effectively broken.
RFC 4862 =C2=A75.5.3 expects hosts to autoconfigure an address for every
Prefix Information Option with the A flag set, in every RA received.

Environment
------------

iwd 3.12, ell 0.83, Linux 7.1.13. iwd does network configuration
(EnableNetworkConfiguration=3Dtrue, EnableIPv6=3Dtrue); systemd-networkd
leaves wlan0 unmanaged.

Addresses below are anonymized as follows:

  2001:db8:1::/64        global prefix (ISP-facing router, TP-Link)
  fd00:aaaa:aaaa:1::/64  on-link ULA prefix (Apple TV)
  fd00:bbbb:bbbb::/64    Thread mesh prefix (RIO from the Apple TV)
  fe80::1                TP-Link router
  fe80::2                Apple TV

Router Advertisements on the home network (rdisc6 wlan0)
--------------------------------------------------------

Hop limit                 :    undefined (      0x00)
Stateful address conf.    :           No
Stateful other conf.      :           No
Mobile home agent         :           No
Router preference         :       medium
Neighbor discovery proxy  :           No
Router lifetime           :            0 (0x00000000) seconds
Reachable time            :  unspecified (0x00000000)
Retransmit time           :  unspecified (0x00000000)
 Prefix                   : fd00:aaaa:aaaa:1::/64
  On-link                 :          Yes
  Autonomous address conf.:          Yes
  Valid time              :         1800 (0x00000708) seconds
  Pref. time              :         1800 (0x00000708) seconds
 Route                    : fd00:bbbb:bbbb::/64
  Route preference        :       medium
  Route lifetime          :         1800 (0x00000708) seconds
 Source link-layer address: 02:00:00:00:00:02
 from fe80::2

Hop limit                 :           64 (      0x40)
Stateful address conf.    :           No
Stateful other conf.      :          Yes
Mobile home agent         :           No
Router preference         :       medium
Neighbor discovery proxy  :           No
Router lifetime           :         1800 (0x00000708) seconds
Reachable time            :  unspecified (0x00000000)
Retransmit time           :  unspecified (0x00000000)
 Prefix                   : 2001:db8:1::/64
  On-link                 :          Yes
  Autonomous address conf.:          Yes
  Valid time              :          300 (0x0000012c) seconds
  Pref. time              :          300 (0x0000012c) seconds
 Source link-layer address: 02:00:00:00:00:01
 from fe80::1

On my guest network, which the Apple TV is not on, only the second
(TP-Link) RA is present and IPv6 works.

Resulting state on the home network
-----------------------------------

This is reproducible on every reconnect I have tried.

$ ip -6 addr show dev wlan0
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 ...
    inet6 fd00:aaaa:aaaa:1:1234:56ff:fe78:9abc/128 scope global dynamic =
noprefixroute
       valid_lft 1732sec preferred_lft 1732sec
    inet6 fe80::1234:56ff:fe78:9abc/64 scope link proto kernel_ll
       valid_lft forever preferred_lft forever

$ ip -6 route show dev wlan0
2001:db8:1::/64 proto ra metric 303 expires 159sec pref medium
fd00:bbbb:bbbb::/64 via fe80::2 proto ra metric 303 expires 1731sec pref=
 medium
fd00:aaaa:aaaa:1::/64 proto ra metric 303 expires 1731sec pref medium
fe80::/64 proto kernel metric 256 pref medium
default via fe80::1 proto ra metric 303 expires 1176sec pref medium

All routes are present, including the default route through the TP-Link
and the on-link route for 2001:db8:1::/64, but the only non-link-local
address is in the Apple TV's ULA prefix. Global IPv6 traffic is
therefore sourced from the ULA and fails:

$ ping -6 -c3 2606:4700:4700::1111
3 packets transmitted, 0 received, 100% packet loss

(IPv4 on the same connection works normally.)

Relevant code (ell 0.83)
------------------------

- ell/netconfig.c:1233-1240: comment stating the method is chosen from
  the first RA and that only one SLAAC address is configured "regardless
  of how many prefixes are available".
- ell/netconfig.c:1242-1266: DHCPv6 vs. SLAAC chosen once, from the
  first RA (v6_auto_method is only set while UNSET).
- ell/netconfig.c:744, netconfig_add_slaac_address(): creates a single
  address from the prefix with the longest preferred lifetime in that
  one RA. If both prefixes were in the same RA, the ULA (preferred lifet=
ime
  1800s) would still be chosen over the global prefix (300s).
- ell/netconfig.c:1286: if the first RA has no autoconfiguration prefix
  and no M flag, IPv6 configuration fails outright. A border router RA
  containing only a RIO would trigger this.
- ell/dhcp6-lease.c:219: the DHCPv6 path keeps only the first IA_ADDR in
  an IA_NA, so the same single-address limitation applies to DHCPv6.

The SLAAC code was introduced in 6adf0f5 ("netconfig: Create SLAAC
address"), whose commit message also describes it as generating "a
single IPv6 address".

I'm happy to test patches.

[1] https://github.com/apple-oss-distributions/mDNSResponder/blob/mDNSRe=
sponder-2200.0.8/ServiceRegistration/route.c#L860-L869
