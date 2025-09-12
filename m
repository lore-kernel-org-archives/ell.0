Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 6B42F1114
	for <ell@lists.linux.dev>; Fri, 12 Sep 2025 09:39:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.132.17
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757669990; cv=none; b=AXy0m0xWymNZDDMQWJmBDAwLUuoy62PXQYqUFHierbiLt/SkRV60uKMT0P8R+TgS0EiSTZWJPTxvhc2P4vxu7dCVI5seUiFm23EiAd48lGWw9c/J1on59ySb/tSu0sLyz1SocU5BBd4o6xjPjUSmqWP8TSmX/9PjW6YNei9d4ts=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757669990; c=relaxed/simple;
	bh=uCAr/7sBRGl11FbQMAedG+zEBwsjskyhGJ69ux/vEfw=;
	h=Content-Type:Mime-Version:Subject:From:In-Reply-To:Date:Cc:
	 Message-Id:References:To; b=YeRu2mCw/+WunWWdQli4jqnNxiSIMKIOheDqb9RHTlr3dHQnRh06mUpOvCxRKZ9YZNn7fQiwb4iEH3olNK8v0z1hHtz7ot70ehjmtly7w9YxEOwESOBv4xWzSN97bfm8fssAzAN8wpyWxhHQ9VUSEWWA6356qiHimhBS0Bp7nA8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org; spf=pass smtp.mailfrom=holtmann.org; arc=none smtp.client-ip=212.227.132.17
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p4ff9f066.dip0.t-ipconnect.de [79.249.240.102])
	by mail.holtmann.org (Postfix) with ESMTPSA id 664DECECCA;
	Fri, 12 Sep 2025 11:30:33 +0200 (CEST)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3826.700.81\))
Subject: Re: [PATCH v5 1/1] build: Add meson build system
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <20250807134859.930870-2-hadess@hadess.net>
Date: Fri, 12 Sep 2025 11:30:22 +0200
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <32B20CF0-291C-422A-92AF-9102E473ADDB@holtmann.org>
References: <20250807134859.930870-1-hadess@hadess.net>
 <20250807134859.930870-2-hadess@hadess.net>
To: Bastien Nocera <hadess@hadess.net>
X-Mailer: Apple Mail (2.3826.700.81)

Hi Bastien,

> --enable-pie is replaced by the meson base option "b_pie":
> https://mesonbuild.com/Builtin-options.html#base-options
>=20
> --enable-maintainer-mode is replaced by the "debug" build-types:
> https://mesonbuild.com/Builtin-options.html#core-options
>=20
> --enable-debug and --disable-optimization are replaced by the
> debug build type:
> https://mesonbuild.com/Builtin-options.html#details-for-buildtype
>=20
> Each of the sanitisers have their own b_sanitize option:
> - asan: b_sanitize=3Daddress
> - lsan: b_sanitize=3Dleak
> - ubsan: b_sanitize=3Daddress,undefined
> https://mesonbuild.com/Builtin-options.html#base-options
>=20
> --enable-coverage is replaced by the b_coverage option:
> https://mesonbuild.com/Builtin-options.html#base-options
> ---
> ell/meson.build              | 187 +++++++++++++
> examples/meson.build         |  32 +++
> meson.build                  |  69 +++++
> meson_options.txt            |   5 +
> tools/meson.build            |  18 ++
> unit/gen-cert-expired-pem.sh |  14 +
> unit/meson.build             | 501 +++++++++++++++++++++++++++++++++++
> unit/xxd.sh                  |   3 +
> 8 files changed, 829 insertions(+)
> create mode 100644 ell/meson.build
> create mode 100644 examples/meson.build
> create mode 100644 meson.build
> create mode 100644 meson_options.txt
> create mode 100644 tools/meson.build
> create mode 100755 unit/gen-cert-expired-pem.sh
> create mode 100644 unit/meson.build
> create mode 100755 unit/xxd.sh

I am not a big fan of having two build tools. The reason why none of my =
projects have moved away from autoconf is that they just work fine and =
with that have as little dependencies as possible. Personally I have not =
yet seen the benefit of Meson at all. Adding more shell scripts is also =
not a solution.

ELL build has still a few issues that I would like to eradicate first. =
The usage of xxd and the openssl binary is a pain and also leaves =
artifacts around. Frankly, it would be best all the certs are created by =
a dedicated tool using libssl directly.

Regards

Marcel

