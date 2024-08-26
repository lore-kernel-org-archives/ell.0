Received: from mout-p-101.mailbox.org (mout-p-101.mailbox.org [80.241.56.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B41E1185955
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 12:46:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=80.241.56.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724676419; cv=none; b=H3PM7Vf3x6v8/5/w/V3V7gJ0MHhOvtbdVFe0tGj+JjpzCE376use2hl5ADFCOSlIcli6H7elkEPHyaKpbfAgNl8SWLm3jBUAxhcRV8tKZfkDxq9TdHePzyO4GGu4+dIHipHUtQDBOkbBQxlplpCvzDEplojGwxNZm9KcadUIIbI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724676419; c=relaxed/simple;
	bh=ZiPpGGc5z3dY0qZyoyedro8hv8YOQL6nTtIIKFLMoG0=;
	h=Date:From:To:Subject:Message-ID:MIME-Version:Content-Type; b=ObmYaWsDgus8+KthNjyqVx1RQ71plNDMFp7t7XjwAeahBAIPhwLRALTnaT2bn0QiM4oSTJX3cIFSJXOBnR+4nEtN+x2Nb94R+3Q/k1zMjTdtgyDO6yt6d6QWyRZ4fymNA5iT0uqN06GQGUqdUllh4haWTqWHoDEEWFHi0twMRrE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=mailbox.org; spf=pass smtp.mailfrom=mailbox.org; dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b=qE2n88fy; arc=none smtp.client-ip=80.241.56.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=mailbox.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mailbox.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="qE2n88fy"
Received: from smtp2.mailbox.org (smtp2.mailbox.org [10.196.197.2])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mout-p-101.mailbox.org (Postfix) with ESMTPS id 4Wsqwp43ZJz9t36
	for <ell@lists.linux.dev>; Mon, 26 Aug 2024 14:38:50 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mailbox.org; s=mail20150812;
	t=1724675930;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type;
	bh=ZiPpGGc5z3dY0qZyoyedro8hv8YOQL6nTtIIKFLMoG0=;
	b=qE2n88fyMzaLm6MPO8nrKTQ7Q5uTF3NeD+zCa0BtuUL112UVIVvpG26ADWFi0x5ZaNH9H0
	IJ1WILxj2fowr6mxF+n0EEryXZ8b8TRz0O73zvqOgDVr8wmMuxAqWzG4XUHGukbxbQdjhs
	+KvGTRLHIbAtHc3dy61UfpsRNxfPkX91ogjdaWcw4sQefx1uHT825h835np1ngklHlqP1k
	mmCvQ6bkKjs8NygRO0Eb4aa0ZAljyNhmoEHusPbupTojeRgHFZ8Ws1tnVmxowZi/UvJihf
	axIhDLuwcOSBi6sBYSYvsH+YF/CDET7drbRyfpxnexJccrRNTIFkjtvfzEYrYA==
Date: Mon, 26 Aug 2024 14:38:43 +0200
From: Andreas Radke <andyrtr@mailbox.org>
To: ell@lists.linux.dev
Subject: missing header files
Message-ID: <20240826143746.7ae0fa86@workstation64.local>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="Sig_/RP4_1kWCb_AJp3fNqbUacF_";
 protocol="application/pgp-signature"; micalg=pgp-sha512
X-MBO-RS-META: rccnpn6mjfps1xo8ujyyco5o31ysw4fp
X-MBO-RS-ID: 4e82eed728ae7a68668

--Sig_/RP4_1kWCb_AJp3fNqbUacF_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Using "make install" target seems to not install some of the header
files. I've run into missing ell/useful.h for recent iwd build from git
master.

Can you clarify whether all these header files should be installed when
building a distribution package and please make the Makefile install
those that are expected to be present on the system.

cp ell/*.h "$pkgdir"/usr/include/ell/ shows these additional files now:

/usr/include/ell/asn1-private.h
/usr/include/ell/cert-private.h
/usr/include/ell/dbus-private.h
/usr/include/ell/dhcp-private.h
/usr/include/ell/dhcp6-private.h
/usr/include/ell/ecc-private.h
/usr/include/ell/gvariant-private.h
/usr/include/ell/icmp6-private.h
/usr/include/ell/main-private.h
/usr/include/ell/missing.h
/usr/include/ell/net-private.h
/usr/include/ell/netlink-private.h
/usr/include/ell/pem-private.h
/usr/include/ell/private.h
/usr/include/ell/rtnl-private.h
/usr/include/ell/siphash-private.h
/usr/include/ell/time-private.h
/usr/include/ell/tls-private.h
 usr/include/ell/useful.h

-Andy
Arch Linux

--Sig_/RP4_1kWCb_AJp3fNqbUacF_
Content-Type: application/pgp-signature
Content-Description: Digitale Signatur von OpenPGP

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEErcih/MFeAdRTEEGelGV6sg8qCSsFAmbMd1MACgkQlGV6sg8q
CSsajwf+PAP7Osm/EM4Oty9Hcy6tqR1hkcfcSHQ2Rbcpwb4r/Bf1sWVPDCC5+2zS
adYd5l9tEAAik2ijAD6y2oyTqQci3Uo6Uhv/BTHDMERQIMOn2+DE6X1/zVUk0uyL
TmXI7dK06FHXKTIQoeAMjPvB6EF9UCXADLBoiP86P1Z35i5F8qCUJiphfovyHH7C
aM1aMwHjPfyPhVveLrXZOXopfkB+lJ+HLd0kSXK3VRbnkyyEf7g5xKegzuPD5Ec3
32F9CIAYzI4ypCAcPljNizY2qDSlQCf1TroAc+p+yCrm9fv+4Lw1uGVhEuakLSAt
MtV9pNLe61iqZ7CHzNoufIkHCuKRLA==
=K9j/
-----END PGP SIGNATURE-----

--Sig_/RP4_1kWCb_AJp3fNqbUacF_--
