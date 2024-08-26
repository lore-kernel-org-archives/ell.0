Received: from mout-p-101.mailbox.org (mout-p-101.mailbox.org [80.241.56.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06C0B194C71
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 16:39:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=80.241.56.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724690378; cv=none; b=A90SlWqRpoen6EKJf+fAY07gKZrwzzhaw+poC/8snU/Eq2GH59Ou4mK/pUuoRiEEKloB/q05f4Uy5EwFFLXeuBfHY3eR0tGVG/ih82F9Tc/1OQ2wHQe9X72TcW8r3mufh/pPRyRjAJy0+XK03SoSBALYdLXOFE6GKKKKn4p8xOI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724690378; c=relaxed/simple;
	bh=25fFOG94W68dhxWK7/gjUpo/5UDOqTfn15M4qQ2r92Q=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=I9oWjEsX+8TRE8gBGEN9KU/NU31vjvZRz7TVEpATuTESq1K5OZ5WMPK8zbMnxnf8Z27FYik2BjT2ka8eAJfQHv+ER6hwPPvQXIykXHnN5LkswQKX1x99LgsUHUqhkR707goLaSfy9Upw7o5yjU0SILGF6069zTO0xmUaYsVTQM0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=mailbox.org; spf=pass smtp.mailfrom=mailbox.org; dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b=FKcFfQia; arc=none smtp.client-ip=80.241.56.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=mailbox.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mailbox.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="FKcFfQia"
Received: from smtp102.mailbox.org (smtp102.mailbox.org [IPv6:2001:67c:2050:b231:465::102])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-101.mailbox.org (Postfix) with ESMTPS id 4WsxGX1lxVz9stT;
	Mon, 26 Aug 2024 18:39:32 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mailbox.org; s=mail20150812;
	t=1724690372;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=RNr4bH36mhDWqMpiigkr0xZRIjWdBFsYi4I72HeiU7c=;
	b=FKcFfQiaiFyn+XBm6+lrWUf/9dsuOQGqfcGSXjNjKH9D/E8A9JFWPdiSuWHddTzDGNNvTX
	ghltvfYAm/TxibMHDpYzR/VgtoUoJZvkyp/SSPDT7OPugbw77/pfmW9FvzvzltGRubuzfC
	KnqBOEqr4wbsCWjU7kWnb5WcqZ7CmTy+dvjmz4LYfGXzqJG2rawMWFmK8znitsfL+/m5ol
	4Lvv5NKyquVRrPM1mZ2k9t/b+M8277q5aI9qraIpJGgstkLoob2B/9WivC2DpfQti6kkBe
	rNaf5MWRsXY5GuxeIQg696eNwuyy4jhgB/4ZxvHSaY+T47t6cV283oQSLKb5yg==
Date: Mon, 26 Aug 2024 18:39:26 +0200
From: Andreas Radke <andyrtr@mailbox.org>
To: Denis Kenzior <denkenz@gmail.com>
Cc: ell@lists.linux.dev
Subject: Re: missing header files
Message-ID: <20240826183926.6cd4fd33@workstation64.local>
In-Reply-To: <14a637ae-0f31-4429-963a-5f5012841ee0@gmail.com>
References: <20240826143746.7ae0fa86@workstation64.local>
	<14a637ae-0f31-4429-963a-5f5012841ee0@gmail.com>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/C9AzMUnXnMHFDQVBUiLnNK7";
 protocol="application/pgp-signature"; micalg=pgp-sha512
X-MBO-RS-ID: 60c6346f0149fc782e4
X-MBO-RS-META: 985jbnjnsokeq6kiia1bzybiz7mpapfr

--Sig_/C9AzMUnXnMHFDQVBUiLnNK7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Am Mon, 26 Aug 2024 10:38:37 -0500
schrieb Denis Kenzior <denkenz@gmail.com>:

> Hi Andreas,
>=20
> On 8/26/24 7:38 AM, Andreas Radke wrote:
>  [...] =20
>=20
> ell/useful.h and ell/asn1-private.h are special.  They're copied from
> the ell tree when iwd is built.  Even if using shared ell, you need
> to setup ell as described in the README
>=20
>  [...] =20
>=20
> These files are included in the distribution package.
> [denkenz@archdev iwd]$ tar -Jtvf iwd-2.19.tar.xz | grep useful
> -rw-r--r-- denkenz/denkenz   1979 2024-08-16 10:31
> iwd-2.19/ell/useful.h [denkenz@archdev iwd]$ tar -Jtvf
> iwd-2.19.tar.xz | grep asn1 -rw-r--r-- denkenz/denkenz   4406
> 2024-08-16 10:31 iwd-2.19/ell/asn1-private.h
>=20
>  [...] =20
>=20
> None of these files are to be installed by ell, they're not part of
> the public API.
>=20
> Regards,
> -Denis
>=20

Compiling is broken here when using --enable-external-ell with iwd git
master no matter if I put ell source along iwd as described in README
but succeeds with --disable-external-ell.

The README ist somewhat misleading here. When building from git and
placing ell into toplevel dir it's failing. A cp ell/ell into iwd/ is
required when building from git.

-Andy


--Sig_/C9AzMUnXnMHFDQVBUiLnNK7
Content-Type: application/pgp-signature
Content-Description: Digitale Signatur von OpenPGP

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEErcih/MFeAdRTEEGelGV6sg8qCSsFAmbMr74ACgkQlGV6sg8q
CSt4QAf/aBNpXzz9AcHkkFOK9tiRpedmzlJe306yjl2U6VZDAgwmEMlhz13LQ5gg
NYztiLGYL1sN4miJJ42clLMa2X8hVZiDrPnVKdtQOd6JkHp5UDqwmz25R2vpjJLt
M4hKuzjScH0baWzau27yK/f1jm4GmLSEQhnuMI2pEGxh1HIYiEqf88onA1yAYW7L
85Q3XSN43n26Qsd4FJV62UpbMX8a5I3PQOmQKAEtMTo776lNh586/G5p8gGYGSgf
O7ztIrQ1WKFVWn4ufyOZ0SPfgnFyySokkYLtJnyu/E7m1mraEJVEFovJ9QW8iy/n
LWlP9KRN8L1sm5Gqg8oU+nisoMra/g==
=Wiwj
-----END PGP SIGNATURE-----

--Sig_/C9AzMUnXnMHFDQVBUiLnNK7--
