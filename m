Received: from mail.archlinux.org (mail.archlinux.org [95.216.189.61])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87E237A
	for <ell@lists.linux.dev>; Thu, 16 Jun 2022 05:26:58 +0000 (UTC)
Received: from workstation64 (ip5b41e765.dynamic.kabel-deutschland.de [91.65.231.101])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.archlinux.org (Postfix) with ESMTPSA id 0B6B21102D0D
	for <ell@lists.linux.dev>; Thu, 16 Jun 2022 05:26:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=archlinux.org;
	s=dkim-rsa; t=1655357216;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=;
	b=cw6xDUK7+Si6stCjJJofm9lcSZKFjIRRyD+RheB5+q7LZUuCRZQ17qTdFdMFJ1q45ZMrSZ
	usLPwQsMk9bj4jqq817mT6ATwHucTz2qwG73fVrls9fntHcHVjqBfOvWREaZIlDr8uzXbK
	o/Cw+oSWVVq+beIvDWTmptOLc4JTUWCntc+GTBKAsVF3nnRiihQGi90021RQ+Mu1CXYjNI
	/UHR82SCTnAtOkkUpIHxCavUnZ6QQxiOySGSH0NfSZ1+D3a56MJPBnnSMnM8zWySql1NPH
	0pFgrTFs07hZ5nBxzBRNysBEda+E4gIUhIGeK4C7LPchmfsTuOVtJwNjPu3S8qflwfpXqm
	APXCPy0apbrBrEqOkLdy62A518lB7fEY9nJ9piwEQwFzIVkXetWZ23xjm7t2TvhYPmVY/G
	s++28OFWrwrKHaY1ZjNKveORasiWqhGL2PFERVMsz9gDEY4ODDSp7fxmnPy4M2ZkMWLxAE
	LV4Sv6VYpJf8HsvCdP0ybPSJ2oiYzaI0lbJz1KHWuubhsXUdNM/9A45+MY55irvWmvNZPb
	MwwOaLa7V5Z/go+cZ8ZSTUGwkbQJ+gq6IbHuQqyqGVTh93ZNX5iERs4RO3ZKmKQdTepBZB
	8rhWKKVi10lwXtiGVbATR1KV310X+pFN2IAQlcX2AS4oIv45y7c8A=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=archlinux.org;
	s=dkim-ed25519; t=1655357216;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=;
	b=ERZGxwx+JKY1eZko3mZiUSwt9UEfUBsU2fc1/ZkgfU1d2Zu2A26KQRnP337hz22u+zerf2
	pkATksB8IOckjmCg==
Date: Thu, 16 Jun 2022 07:26:55 +0200
From: Andreas Radke <andyrtr@archlinux.org>
To: ell@lists.linux.dev
Subject: help
Message-ID: <20220616072655.5990e9c6@workstation64>
Organization: ArchLinux
X-Mailer: Claws Mail 4.1.0 (GTK 3.24.34; x86_64-pc-linux-gnu)
Face: iVBORw0KGgoAAAANSUhEUgAAADAAAAAwBAMAAAClLOS0AAAAJFBMVEXLVzlCOzajNBsxMDJ9Rjo7JB1CJx2jo6JhMh9CPj9gFBAcGRUvqpyyAAACVElEQVQ4jWXTvWvbQBQA8McRSMeqwtQhi/LQcHgTVwghi+sKIncrhRCSKZQY0S4pGNTgycK4D3UymUyXxhAQ5ymEJJD75/pOX1baNxjr/bj37t1JsFw47VjsVH9guKxzHWMeHGf5H5xx3phmKQwXTrH60DxofWvunNYKC7vmWXMYE/xTyjznxLE29y9g0TE5hhxzY3YasDvcfUxhi+Hjt7oLDMstnXgADJFeV7Xgqlj6sAIOrkba1GB7dB77sH3J5EdZA/ZIOjFAYgF8f/2pBbspwDYUIX7dVVAcUwp1iKgNx224b8Gp1wCGX1pw0oBA/6LVvA2ygu8Mr/NNKVGDvVrEFkSfSzjgH3zFUKGg4xL4Yrqe8ACz3GPa2opOS7C9PfQEH+wKMdOzSE+bYxcrEHyrGvXZCZG+aeYQwjbNUrg15jHOpg3YHiBzANLxBa02k/dFtd00o5l8AViBPwApN/AGK0A7uXQb6BKW2Z7HA+5twOny2PiHbQVIe0qp+vXpIs/GL8ogR5lNlaNcF5YVSJ1qOtVEcycIGnDQ6+XY07nOsxvXDRxXMbhcMQWpPUlZnmfnDmcUQ9EqFQJ1KrOvOZ3bFQwBQ6BSnkT0NLcgN7AJBQfKRmRBppyf81NRqoTBAAF79tuZOkWigdCeBtpKqgUHRyIc2GvHotIGnkIRsnCeZi+BxyAaoKT453UN75Q6DD3wiWKiEc3GNewr9fuHvXKaj0aj2TRJ3tfwdtK3nxLvaBSH0ThJxiUEyWS/eDVZZmE0STg+WDhKJk+XdoiwiAKSK/UXmpn5K/owqOUAAAAASUVORK5CYII=
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Authentication-Results: mail.archlinux.org;
	auth=pass smtp.auth=andyrtr smtp.mailfrom=andyrtr@archlinux.org

