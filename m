Received: from mout-p-101.mailbox.org (mout-p-101.mailbox.org [80.241.56.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B50A113B586
	for <ell@lists.linux.dev>; Sat,  9 Nov 2024 11:30:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=80.241.56.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1731151858; cv=none; b=A9H9bfyrajnpmB6SHScm8Wrc05MBro+DYj1Hch2QYeG0knX9j5+wpS613sdeKKOY1iXssXpbUjctiaSndDjqgMCCIArKBha0LCaE75VlTBTiV6OpIlejAGceWbLe1EZn8qI6OGXMm2OEzOq19MqjdjGLvPKkg1lRihjle2UhHAM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1731151858; c=relaxed/simple;
	bh=uxtUWiniZo8WpWUroXRx9B0pDAQYubBNCc8/SenhVkc=;
	h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=Khg7XIwLNctfwk1XhLXHLMS9PEJFPzjnjuhm/UKN6EAyM4LjufnzRpUlW1FtgR+mBNGeA7hOIheJnIwDquuGuRanHq+TC5HTUo2NNWhs3Huv6FGAsfMuhv79rALpG94+i5e3Ka5OVL3dwOqbhjD5AG0B6uIVummqwCjc48n6IEc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=vonhaugwitz.com; spf=pass smtp.mailfrom=vonhaugwitz.com; dkim=pass (2048-bit key) header.d=vonhaugwitz.com header.i=@vonhaugwitz.com header.b=l1VcaTka; arc=none smtp.client-ip=80.241.56.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=vonhaugwitz.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vonhaugwitz.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=vonhaugwitz.com header.i=@vonhaugwitz.com header.b="l1VcaTka"
Received: from smtp202.mailbox.org (smtp202.mailbox.org [10.196.197.202])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-101.mailbox.org (Postfix) with ESMTPS id 4Xltgj4TqDz9sms
	for <ell@lists.linux.dev>; Sat,  9 Nov 2024 12:22:09 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vonhaugwitz.com;
	s=MBO0001; t=1731151329;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type;
	bh=uxtUWiniZo8WpWUroXRx9B0pDAQYubBNCc8/SenhVkc=;
	b=l1VcaTkax651+cyMsiQauyTGLMHklh4SNgZhq+Chm/WdshN4q786vNbj/BVjPzXLkucOBm
	Vf9iUV6yz0L1Z934V2qT6TX1ln5K7vRrK+yWzsA/ItkuNSGkeUtk520GV6uk5gaiGpYGhY
	5dlMs2W1B+V1cUgY4ThQ83D2PPom+by25WJJP0q3TFoMjP7IxYPucH9PsrhGxBaTBB76fA
	npEgcdIVILyUNHAmy/f9KYYWzrNSu648Zw146m+oUWOQ1rROhG/zGHGqQ0JqZcwCqLxasL
	d4OMDocHrvQrIobebvX32mk3Eq/wzDVvJMF7lX+O8T0ZcMXT7s8wTqSUAsRShw==
Date: Sat, 9 Nov 2024 12:22:06 +0100
From: Hannes von Haugwitz <hannes@vonhaugwitz.com>
To: ell@lists.linux.dev
Subject: IPv6 Privacy Extension support?
Message-ID: <20241109112206.GA25@magnesium.vonhaugwitz.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

I'm running Debian sid and iwd 3.1/libell 0.70.

When I enable network configuration and IPv6 in iwd config, the IPv6
address contains the embedded interface identifier (i.e. the MAC
address), even though IPv6 Privacy Extension is enabled for the device
(net.ipv6.conf.wlan0.use_tempaddr = 2).

It looks like iwd uses the Embedded Linux library for network
configuration and ell seems to hard code the EUI-64-based Interface
Identifier for the IPv6 address[ell/netconfig.c].

Are there any plans to support IPv6 Privacy Extension in ell?

Best regards

Hannes

[ell/netconfig.c] https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ell/netconfig.c?id=4acbb92c0513644900078c348d972ef5e48fdc4c#n760
