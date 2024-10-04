Received: from fout-a1-smtp.messagingengine.com (fout-a1-smtp.messagingengine.com [103.168.172.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2AFC51D9A46
	for <ell@lists.linux.dev>; Fri,  4 Oct 2024 14:59:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1728053998; cv=none; b=d10fTbFe0v+3WOmCS3cUgYbI8Fc40M1f/Rg6bGt0Am+NSPxdpbZiDq9H6izyB7KtM4OePo7G8bMgi16cPB2mpPwxoS2GNchCGjuYcKmicUNBOIDqrfSloNHxjYSitX1CX97unsNoxIVZnt4kQgTY8XBq1tOP2bIdLR2yqw5SXIY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1728053998; c=relaxed/simple;
	bh=yRk1ejOY6wUMy4aD6iLgfXQTK/vSxwpBxQffq7gWOGw=;
	h=From:To:Subject:Date:Message-ID:MIME-Version:Content-Type; b=UkJNkEBim5xPtQyKoaHFCMVLD8WFNTwzZNoxHZdvFK3UnhSUX0Q0SerOq0NEUPcG+suvJ6zpTNAGJXtghS0fs+slcr3nRK/AA6PO4bIUPA2KcpIru8n7O/+yb5Ki5sPS2IqWL1f6uJ24cbWtpaPIrxyQVNzc1SUI2zrsIeFpvBM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=alyssa.is; spf=pass smtp.mailfrom=alyssa.is; dkim=pass (2048-bit key) header.d=alyssa.is header.i=@alyssa.is header.b=D0OImj8R; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=PgRDwgWa; arc=none smtp.client-ip=103.168.172.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=alyssa.is
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=alyssa.is
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=alyssa.is header.i=@alyssa.is header.b="D0OImj8R";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="PgRDwgWa"
Received: from phl-compute-01.internal (phl-compute-01.phl.internal [10.202.2.41])
	by mailfout.phl.internal (Postfix) with ESMTP id 052651380258
	for <ell@lists.linux.dev>; Fri,  4 Oct 2024 10:59:54 -0400 (EDT)
Received: from phl-mailfrontend-01 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Fri, 04 Oct 2024 10:59:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alyssa.is; h=cc
	:content-type:content-type:date:date:from:from:in-reply-to
	:message-id:mime-version:reply-to:subject:subject:to:to; s=fm1;
	 t=1728053994; x=1728140394; bh=nwUpd1klCZ2+xWhTR1wCVIfXGPFoaZq3
	VRsPsXw+R0I=; b=D0OImj8RMZS54k+oqkSh/xvS+58PlOKSayZkys8OPmXGpt/g
	clPDn3V0gyVHOHtTKGb4A1KFiAjKI8hLaMWIrH1L5U7EyvD036TmG5f4YEU/pzng
	shfYLW9MnBOIy05ah3o19KH/k1j2MHZVnswJQ8PZ5+BzSOudQZv6Mv/qMGA9kieO
	WdPe4pxQ9O8fHBYLy4U6pXsQpIuESZV1ME3iBxzPbP0JgCPjWuagSBANbvar4bXY
	MtpkuApiFtPS8eUxoimEcZPAi1eBxq2IALWL9tR1vn/x53m1tUAjUBbuptwYhmPs
	5xRDWbF1wLlkW1drx6/+vlfVTxL8l/h2mAAkPQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:content-type:date:date
	:feedback-id:feedback-id:from:from:in-reply-to:message-id
	:mime-version:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=
	1728053994; x=1728140394; bh=nwUpd1klCZ2+xWhTR1wCVIfXGPFoaZq3VRs
	PsXw+R0I=; b=PgRDwgWaZ0mIP7nskU8+pDA5f//b2lRF0FoToPrMcXGqUfBI2ow
	y+trA/BQm/esQZ+glHeDUrqfpAFbKc5z6GLhEfoWJCyXflgf+k/OHeYb1pdU5iDs
	bJyS4YdtX/nsv2x1cA5J5lH3fJhpISMFggte+swFJWElBbmKVQNgoLQStI9WStF2
	0+ksp7O9KYrkzI+u11u54beej1NOsv24URkh7XpN28h7oX4QISj8JkxFFGxzyBOb
	qts0xj5nGHncTuRyTBlO0Pt3mDeVTmypr2B7a+GYDDKjrXPs9yLmpkK5xwmh+gdq
	t/lFPvHUoedWKlT5kNkeXtOBH0Sb1TxtZJg==
X-ME-Sender: <xms:6QIAZ4JpPvY0fNgZeRNQ1QbpGDhTspDVNjjwy3_NPRHkZfNLcMyG6Q>
    <xme:6QIAZ4LUKzMe3P9PLJnSg9Q9DQTLM_qOCRRShjEJolfHdLPCWVbAax9OnEsggvygh
    9i5QZiQM0IGtgPa0w>
X-ME-Received: <xmr:6QIAZ4ufzsUIzrJVZN7FHv2uYhMMhCjdiBT3WbT-n4bblk4N_M8gtzfkT04aW80jZ9ubGnTXxNGpJeU9-KVASQ5FVw2Wx2EH_jmM0xM>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeeftddrvddvfedgkeefucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdggtfgfnhhsuhgsshgtrhhisggvpdfu
    rfetoffkrfgpnffqhgenuceurghilhhouhhtmecufedttdenucenucfjughrpefhvffuff
    fkgggtsehgtderredttddtnecuhfhrohhmpeetlhihshhsrgcutfhoshhsuceohhhisegr
    lhihshhsrgdrihhsqeenucggtffrrghtthgvrhhnpedtkeevtdeitddvteevgfffteeufe
    elvdehhffghefhheeiffekheeuieetjeffffenucevlhhushhtvghrufhiiigvpedtnecu
    rfgrrhgrmhepmhgrihhlfhhrohhmpehhihesrghlhihsshgrrdhishdpnhgspghrtghpth
    htohepuddpmhhouggvpehsmhhtphhouhhtpdhrtghpthhtohepvghllheslhhishhtshdr
    lhhinhhugidruggvvh
X-ME-Proxy: <xmx:6QIAZ1Y8WL8BbDCOINn5eUB21OURMtZOv2LHvWdQwNV_2sY95hT8Bw>
    <xmx:6QIAZ_a4Ui5rrLaUC0-wJqe7zk6R3BxmiBoB-JwBYVgu7lYslu-cpg>
    <xmx:6QIAZxBhFGNUicxYt2rJVcnwfEqOL_sKIStHVgOF620kO3MNTinAUw>
    <xmx:6QIAZ1ZFP0xSUsPmRZPtFWM1120b2CAJlOOYpHuCS3m4p5hl0nFKcQ>
    <xmx:6QIAZ2w8nrWzTDS1SuNxmgdbV2YgyzesEFl_HznSvjGb35UrZ4wFVPA6>
Feedback-ID: i12284293:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA for
 <ell@lists.linux.dev>; Fri, 4 Oct 2024 10:59:53 -0400 (EDT)
Received: by sf.qyliss.net (Postfix, from userid 1000)
	id A592344F6AAA; Fri, 04 Oct 2024 16:52:23 +0200 (CEST)
From: Alyssa Ross <hi@alyssa.is>
To: ell@lists.linux.dev
Subject: TRUSTED CERTIFICATE
Date: Fri, 04 Oct 2024 16:52:11 +0200
Message-ID: <878qv36hus.fsf@alyssa.is>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"

--=-=-=
Content-Type: text/plain

Hello,

I encountered a problem when attempting to connect to a WPA2 Enterprise
network with iwd, that I think is caused by ell not understanding some
certificates.

I'm pretty confident that it should be valid to point EAP-TTLS-CACert to
the /etc/ssl/certs/ca-bundle.crt that comes with my distro.  I believe
this has worked with NetworkManager/wpa_supplicant for me in the past.
It doesn't work with iwd/ell, because
l_pem_load_certificate_list_from_data will error if any of the entries
in the provided PEM data don't have the "CERTIFICATE" label, but some of
the entries in my ca-bundle.crt have the "TRUSTED CERTIFICATE" label.

I think ell should therefore either support trusted certificates (or at
least give up if it finds any), so that users don't need to manually
configure a certificate for networks with certificates signed by a CA in
the system's bundle.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEH9wgcxqlHM/ARR3h+dvtSFmyccAFAmcAARsACgkQ+dvtSFmy
ccBEqw//YdnQshRB39NF5deXJos47gH9SWQ5RMeRArXaq0OT26bwrVPCk2FPgSMu
hTF3gshfFlOj9OyvOrfG7Oc82vEfryC9IolOxafHjebwv4LdFGqxuWPA+3J7PZfO
Ar2LQlurTLKcoNZLokXG4QO7or2di7tT1Gmio0WLJ3QIINFX48lEjtzSfxAxtd0W
PmADJTApIHRSjL21dj57yMNfVKzCchHcecomzP1iNp2MnfNlpdx5skxCbBjeytX4
S71Av2f7ubWLUtPUWpk9IlIABtZSUWo4pfYMnj5XxE8+FfMcrQSpl6OgjklABBAv
ctlKqyVZgBSu8UnnzrwS0dxh9om574xhH3AXYgJh86Plmv6FH8f8E7cZGRGwbIE2
m9oG5flew2Zt9ZxzIL8cFcD17TjEh1JLx5Rs0McX6dh598e+ufS4K7jQDSFpCXvB
U8LvVBiucNQ8bhCCk7dPsREUzk645uaBRUNyhfO079/sGbIHF+OUZptzNjKxENqo
FhR+ptnUtXGgB0SXAqwVkdyLIHd0j1fEmGpsg16rXN0iKSsC/UFzGIvLDVoyRUr7
oMm3he/rNhXVtRCdgndGy6/D69cKB7IO3tzGQgHvtbrQIzGwmpaZjSwSh1WC87vQ
lNj16awW0sTqQ6XUwkXNhOU4hy9s9A2ENN8/XdjAKOrwa+Qk6DI=
=nK7L
-----END PGP SIGNATURE-----
--=-=-=--
