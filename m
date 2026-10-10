Received: from fout-b5-smtp.messagingengine.com (fout-b5-smtp.messagingengine.com [202.12.124.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE33B3DD849
	for <ell@lists.linux.dev>; Sat, 10 Oct 2026 11:06:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791630397; cv=none; b=tasOnsfP1VBLFoI6a4my6qU9XwwctvG19Om6XIFkJdXUN/yHsU54rG8E4AGKY/ji7arj/6rCck77qDIZ4p+wMjIgLnBucf4cl7g6MW7FSC4cRQlCoreP9xUVI7nY7PJ+PLzOdbjxuw7T+2lLBK56ZCK+Xt7QZfsxbKRE69OJC3Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791630397; c=relaxed/simple;
	bh=BXie2NIcIEEXPrScYjMKHS4pRBW0yVOSfIpA8L2thmY=;
	h=MIME-Version:Date:From:To:Message-Id:Subject:Content-Type; b=LRnehrSc8tp9bbZdv5xz/Va58BGdMxAjNS5bCdGnyz7P9Uw8Ix94yHL1/CsQQK+B9ZBA4oYmCQ1Pr18zUUTl4AdiiTKCbCwYhLtixwA/xzbUiRETgvNvQT6D7YC8t3cNocG1F4lDq/CsrXrCyz2vAaBpUVGYYmon83ubzL1FoNc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cteubner.net; spf=pass smtp.mailfrom=cteubner.net; dkim=pass (2048-bit key) header.d=cteubner.net header.i=@cteubner.net header.b=aQCK5OyA; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=aESFqQkB; arc=none smtp.client-ip=202.12.124.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cteubner.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cteubner.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cteubner.net header.i=@cteubner.net header.b="aQCK5OyA";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="aESFqQkB"
Received: from ams-compute-01.internal (ams-compute-01.internal [10.64.2.61])
	by mailfout.stl.internal (Postfix) with ESMTP id 5EC391D000B9
	for <ell@lists.linux.dev>; Sat, 10 Oct 2026 07:06:32 -0400 (EDT)
Received: from ams-imap-03 ([10.64.2.23])
  by ams-compute-01.internal (MEProxy); Sat, 10 Oct 2026 07:06:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cteubner.net; h=
	cc:content-transfer-encoding:content-type:content-type:date:date
	:from:from:in-reply-to:message-id:mime-version:reply-to:subject
	:subject:to:to; s=fm1; t=1791630391; x=1791716791; bh=Gp3UnAeHhx
	AxDP3ucujUNpg8JE2DlpEB3Vt0LE+omEA=; b=aQCK5OyAzpl6C4x0+UtjBbdhp5
	9pMlzuI5vP/rbZ1YvZ8vRUKVzk4vSf7FycqS/RQyqTjzApv2GexmbvaPp0c3YA8g
	4HvAjnceJ5SeaBiG2rAePdonlXTzRBsbg+ToFN5cj4nmPeydQEp0338hN0kkigwD
	iknGytUOavg6ClJpYdnoq31787YCCCxAQl8NSweHDrGD48UsRbKhNaVBJezvrhzQ
	eKOklGtqWQyw2bmlE3NRdAY4kvQror1qDDby7vq6CvxrWqru43ryexkVm1eYjCYM
	P5j9mdUmNqY66ui3kBlC9noWrLMOH1F2RBlNnPNUNU7TsEt7Q4XJgiZamsyQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:subject:subject:to
	:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=
	1791630391; x=1791716791; bh=Gp3UnAeHhxAxDP3ucujUNpg8JE2DlpEB3Vt
	0LE+omEA=; b=aESFqQkBTzUgRcXjjQqmmVQBWFFjZCcSjzJRpDQprvjhnCQCeqn
	zEcBdo83zdxFUjekRZEV9+vzX8WyUcvBAMGesup/YbllsZ8ipmYMYlfTBQMiCfrT
	F/7NHCnFZZQrmHCHfEkc7IaWfTw2oEY93jym4klHrlc0I5N1PsTzxsVOuvCvXGYH
	ATOtsmI+K7/vz0chpF+SY5RNoFhmS0mwJH56gRKkPGeMnEVV30ctMPhsyDBWlGMO
	GyBq0sXzB8ikd4FeTnGyBUMsbhC+Y6ZJbXZtBJsjeQpgf7XXfJ9nZ7Zkjm4Sjy0a
	5iTQfEjplSTxAkkmz2TJlTMOENTI1rXpAFA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-06;
	repo=github.com/dkim2wg/interop; date=2026-10-04; sw=lmtpprox;
	action=sign d=cteubner.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1791630391; d=cteubner.net;
	mf=PGNhcmxvQGN0ZXVibmVyLm5ldD4=;
	rt=PGVsbEBsaXN0cy5saW51eC5kZXY+;
	s=fm1:rsa-sha256:P5P0Hf4imphdz8V+XLrG4IYDwxAlBPiczBVgtcwNpcF78Co
	Rxp7/fPQKCvFD9llWODV3fxiCgWs5/kmUIB5K7AQQHrzrwLk2C0rqPuhvITNsF7G
	/8ZNr4jxmuumTC9BbESV5xRrDL0gLxG/SZh9b1srrmaL5HNnfLydw5X0v8SWE4Gb
	8TWYNUjvGPLuNX3sVAIRFQaQJcSDyJpAL+paPBmhN886LMlMZoHssxliELS24p5E
	oe54F6R0iFrk1lkz30iKMuUOUsXdGs8ve9Uoj/AIoRh1n9k4mblIzOQvo2QfH2Qx
	qB7zFyXa8RS2Ou3GfSEyGQbF/DOgvAasSFxadTQ==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-06;
	repo=github.com/dkim2wg/interop; date=2026-10-04; sw=lmtpprox;
	action=mi-m=1; hc=9;
	hn=content-transfer-encoding,content-type,date,feedback-id,from,
	message-id,mime-version,subject,to;
Message-Instance: m=1; h=sha256:O3m6ZwT2N/4SuypTo4Kh+9TvC/EUGU51sjIhSddXUZQ=:BXie2NIcIEEXPrScYjMKHS4pRBW0yVOSfIpA8L2thmY=;
X-ME-Sender: <xms:NRzKags2BqYcpA0E7O6xOR1KFGAoZidIqJTk2M2pgGOAUhUX5wiGLg>
    <xme:NRzKaoS45XwYkBg67nd2do2anfK3OFimfsntnkWpIPL4t0Nc5O8m-2gCuRoi0dNSs
    Lp_kNCgcwHRpOkWvVFDk4_iRbQ9klRDzr9m42ZJznXaFJOML3PJgbj0>
X-ME-Proxy-Cause: dmFkZTFo7IXVcw+GdX3dcVJriCG2tqxqIPrT7+J7tCYA0Lp02op8/Wfvl/gTB1sSfWf6zX
    uC1XqmOtLk6oP5D/Anl+wx2ewDC9/xWNmosRWyJxcONgiyvca9uF6Sr7cmVawHgCPDH0dp
    qaSreRyApgpkMfTXJWDvZ0JvyDZ+AxgtCAQ0tfHCjbww5586SEOULC7OfcHin44qGofY9T
    6yu8iEcaqDAlWLbDd/BdEENTAH2pDUD42Ol11S/KF405VMWQ6i9uM00F1nmapp/P7+6xK1
    IGVcf8p/ut4O4VNwGld79KR0Ge5TeV8jEco3RG9wzQ0yIW7EBnS0X6oj0HPf1nhqFWQ4lk
    WnEqfpxPjCb+NkNo5KJC3shz9+nvR2Mc8cBhNgrv6CuwWHOP3miF5FunN++etJkcSmfRfc
    HXbb05yCUHn6CGOaNRBVxjYfICjUhXRJKMdRNFSo2mtF0dxQdQkoqemQVVUSgpGLQvuQZE
    7Z4p2k67xqNLvDdWeHyn3WyVmnqIHKpoJv4s9Wr0qGG4J2M6SxvGerCGIQ3CMetijsWDZd
    X9+MMauvLpa22PowPdih1ebUze4hhdsJVtW558BKNihjQNQEyPL1aCaMqCdfO92HL4zsPA
    iC7czaWruFAwkQsQROyyBfp+4IdPrg1PUz/3BuKJBTkGMJs+XltXTIvc293A
X-ME-Proxy: <xmx:NhzKarcmSrZe7jjaQZwhUdWrBjRAyv2WoSlVHGeNv9xxJunlixgymg>
    <xmx:NhzKahJnhAfJ1BYuKdjxOUwhKYY6LRyyF779VvYKVCcpLLTk-TCFaA>
    <xmx:NhzKahYEt2lrShOxVwvCubVkhaV6ZJ-RbkxrTveRMwRXOVb_vrFaIA>
    <xmx:NhzKaktuiwqnkD8DRXRoFk2-k0IHiNWip0TDajOEyB7whnT4b_C-pQ>
    <xmx:NxzKapzEmgY7ey57UEoesluxkISgpmbpu7J-47OoDsQMrYSFyjSNWMyM>
Feedback-ID: i3cc944ce:Fastmail
Received: by mailuser.ams.internal (Postfix, from userid 501)
	id 54E1E32A008E; Sat, 10 Oct 2026 07:06:29 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Date: Sat, 10 Oct 2026 12:05:22 +0100
From: "Carlo Teubner" <carlo@cteubner.net>
To: ell@lists.linux.dev
Message-Id: <528838ce-7599-4268-b7a1-0cc9d7d689bc@app.fastmail.com>
Subject: DHCP Domain-Name "." causes iwd connection timeout
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello,

I'm using iwd 3.12 with ell 0.83 on Arch Linux, with iwd's built-in DHCP
client enabled. On a hotel guest network, Wi-Fi association succeeds,
but iwd remains in "connecting (netconfig)" and disconnects after about
30 seconds.

My /etc/iwd/main.conf contains:

  [General]
  EnableNetworkConfiguration=true

  [Network]
  NameResolvingService=resolvconf

No other network configuration service was running.

A tcpdump capture shows repeated DHCP Discover/Offer exchanges. The
offers match my laptop's transaction ID and client MAC address, but the
laptop never sends a DHCP Request. Offers look like:

  DHCP-Message (53): Offer
  Your-IP: 10.128.14.43
  Server-ID (54): 10.128.255.254
  Lease-Time (51): 3600
  Subnet-Mask (1): 255.255.0.0
  Default-Gateway (3): 10.128.255.254
  Domain-Name-Server (6): 8.8.8.8, 8.8.4.4
  Domain-Name (15), length 1: "."

The BOOTP server-name field is "dhcp.antlabs.com".

Disabling iwd's network configuration and using dhcpcd instead allows
my laptop to connect successfully. dhcpcd then logs:

  wlan0: Invalid domain name: .

but retains the lease and configures the connection.

I suspect the cause is _dhcp_lease_parse_options() in ell/dhcp-lease.c:
when l_net_hostname_is_root() matches the domain name, the parser
rejects the entire lease.

I found the original implementation in Tim Kourt's December 2019 patch,
"[PATCH 4/5] dhcp-lease: Add domain name option handler":

https://lore.kernel.org/ell/20191211232121.23129-4-tim.a.kourt@linux.intel.com/

That patch explicitly disallows root and localhost domain names.

RFC 2132 section 3.17 defines option 15 as the domain name to use when
resolving hostnames, with a minimum length of one octet. It does not
explicitly exclude "." or specify how clients should handle that value:

https://www.rfc-editor.org/rfc/rfc2132.html#section-3.17

So is rejecting the entire offer necessary here, or could the client
discard the unusable domain option and accept the remaining
configuration, like dhcpcd does?

I can provide the full DHCP capture and iwd logs if desired.

Thanks,
Carlo
