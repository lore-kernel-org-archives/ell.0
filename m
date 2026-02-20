Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 3DB3832AAAD
	for <ell@lists.linux.dev>; Fri, 20 Feb 2026 09:57:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771581465; cv=none; b=dtInUgNmlSnQ9CtCRqZt6N1sRUeOkPQ5C/egGQYWLZfCjXJaDUbLX2c+/w1Og6Qj9099FTg3CwHsMVxRvsDkfh+H0lcfnHQCe2/krLMoCvfh+Kp8K+Hnt1X+Acw51PXEYPEofngxWH3/GO3JuZeoFMyGxVzuqmnOiC13dFjfnLU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771581465; c=relaxed/simple;
	bh=yqO2gKONG0eMYcTBkvuN8mS6bm+XoIm7O3DvL3ji5Vs=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=hLmo/a2DFl6OnxgyLuojWLR2KFybaucAFpNOmKosGN6ZLXCLPDLqi9Hdf4suTDBAb+chLT0Ll6H8iEFwwP7i0Qne29kB2x3EXTm0hRu3aO1hsBPAkm2Q+JzeOvNNwDIVkG9+BlLx9+QY4tr6UbkSbdGqrboie0760S4+Me8VQgs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4ff9fa4c.dip0.t-ipconnect.de [79.249.250.76])
	by mail.holtmann.org (Postfix) with ESMTPSA id C1385CECBE;
	Fri, 20 Feb 2026 10:57:42 +0100 (CET)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3864.400.21\))
Subject: Re: [PATCH v3] unit: Skip tests that rely on PKCS#8 when parser is
 missing
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20260219132723.2266067-1-hadess@hadess.net>
Date: Fri, 20 Feb 2026 10:57:31 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <290BE3A7-1669-40DC-A4A7-773D40EE8805@holtmann.org>
References: <20260219132723.2266067-1-hadess@hadess.net>
To: Bastien Nocera <hadess@hadess.net>
X-Mailer: Apple Mail (2.3864.400.21)

Hi Bastien,

> Add pre-check to tests that need the pkcs8_key_parser module loaded
> (whether built-in or external), and allow tests that rely on it to =
fail.
>=20
> This makes it possible to run the test suite successfully even on
> systems where we might not be able to load modules if they're missing
> such as CIs, or other systems where we lack permissions.
>=20
> The test definitions were further simplified by using macros to avoid
> repeated test definition arguments, including the PKCS#8 precheck.
>=20
> ---
> Changes since v2:
> - Use macros for the encrypted pkey and load_file tests
>=20
> Changes since v1:
> - Use precheck test mechanism instead of flags
>=20
>=20
> unit/test-pem.c | 124 ++++++++++++++++++++++--------------------------
> 1 file changed, 58 insertions(+), 66 deletions(-)

patch has been applied, but I fixed the whitespace damage and changed =
the comment style.

Regards

Marcel

