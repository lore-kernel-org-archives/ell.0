Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A07072A1BA
	for <ell@lists.linux.dev>; Fri, 12 Sep 2025 14:30:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1757687439; cv=none; b=DeXM7QlyOYELmBH24UJ94Vc/UIgPUOvBjUt8JPG2tlLfdjutLzcWfkACenZv3LXW3VTnM3JVagvqvrXJHJdgZLiq3KmubddCkIluc9SWBemUohc/qPcASbVP+a5cVJKfobleaXY4vkqj86b1iKhJt13vgfT8qZMG6CXHDaX+EZE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1757687439; c=relaxed/simple;
	bh=lrEhbzawRv597g6eNZWJaSrYiQ8mm3uRoccoYjwZZno=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=ZcswyfVMGhFf++pyGUgrxqkuHvsswkAbEW4qTbKzwcK915TljhkJxDS1HHT2/7cYB2uzI3IBtttI+FGXvSVq0e6+tXkhSzW+/Lfl44LRv21b4QDbLQgFiKTCQAYHK0KjPEMYI8zVjyjgQ/buRZIwfmYIc/YIw+nzoYc9QLPG1sE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id 0AA131F47A;
	Fri, 12 Sep 2025 14:30:28 +0000 (UTC)
Message-ID: <ffc81c3b372278a616d73de309b362ae62d8f722.camel@hadess.net>
Subject: Re: [PATCH v5 1/1] build: Add meson build system
From: Bastien Nocera <hadess@hadess.net>
To: Marcel Holtmann <marcel@holtmann.org>
Cc: ell@lists.linux.dev
Date: Fri, 12 Sep 2025 16:30:28 +0200
In-Reply-To: <32B20CF0-291C-422A-92AF-9102E473ADDB@holtmann.org>
References: <20250807134859.930870-1-hadess@hadess.net>
	 <20250807134859.930870-2-hadess@hadess.net>
	 <32B20CF0-291C-422A-92AF-9102E473ADDB@holtmann.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2 (3.56.2-2.fc42) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-GND-State: clean
X-GND-Score: -100
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdeggddvledvlecutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfitefpfffkpdcuggftfghnshhusghstghrihgsvgenuceurghilhhouhhtmecufedtudenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujfgurhepkffuhffvveffjghftgfgfgggsehtqhertddtreejnecuhfhrohhmpeeurghsthhivghnucfpohgtvghrrgcuoehhrgguvghssheshhgruggvshhsrdhnvghtqeenucggtffrrghtthgvrhhnpeffgefftdekveekledtgfektdevueeujeejgfdttdegfefhgfeuteejhfdvfeelfeenucffohhmrghinhepmhgvshhonhgsuhhilhgurdgtohhmnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfedphhgvlhhopeglkffrvheimedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemsggrgeefmegrieejieemtgdvugefmeejrgehfegnpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpnhgspghrtghpthhtohepvddprhgtphhtthhopehmrghrtggvlheshhholhhtmhgrnhhnrdhorhhgpdhrtghpthhtohepvghllheslhhishhtshdrlhhinhhugidruggvvh
X-GND-Sasl: hadess@hadess.net

Hey Marcel,

On Fri, 2025-09-12 at 11:30 +0200, Marcel Holtmann wrote:
> Hi Bastien,
>=20
> > --enable-pie is replaced by the meson base option "b_pie":
> > https://mesonbuild.com/Builtin-options.html#base-options
> >=20
> > --enable-maintainer-mode is replaced by the "debug" build-types:
> > https://mesonbuild.com/Builtin-options.html#core-options
> >=20
> > --enable-debug and --disable-optimization are replaced by the
> > debug build type:
> > https://mesonbuild.com/Builtin-options.html#details-for-buildtype
> >=20
> > Each of the sanitisers have their own b_sanitize option:
> > - asan: b_sanitize=3Daddress
> > - lsan: b_sanitize=3Dleak
> > - ubsan: b_sanitize=3Daddress,undefined
> > https://mesonbuild.com/Builtin-options.html#base-options
> >=20
> > --enable-coverage is replaced by the b_coverage option:
> > https://mesonbuild.com/Builtin-options.html#base-options
> > ---
> > ell/meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 | 187 +++++++++++++
> > examples/meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=
=C2=A0 32 +++
> > meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 69 +++++
> > meson_options.txt=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 |=C2=A0=C2=A0 5 +
> > tools/meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 |=C2=A0 18 ++
> > unit/gen-cert-expired-pem.sh |=C2=A0 14 +
> > unit/meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 | 501
> > +++++++++++++++++++++++++++++++++++
> > unit/xxd.sh=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0 3 +
> > 8 files changed, 829 insertions(+)
> > create mode 100644 ell/meson.build
> > create mode 100644 examples/meson.build
> > create mode 100644 meson.build
> > create mode 100644 meson_options.txt
> > create mode 100644 tools/meson.build
> > create mode 100755 unit/gen-cert-expired-pem.sh
> > create mode 100644 unit/meson.build
> > create mode 100755 unit/xxd.sh
>=20
> I am not a big fan of having two build tools.

Me neither, pretty happy to provide patches to get rid of autotools
later, once everyone is happy that we have parity between the build
systems.

>  The reason why none of my projects have moved away from autoconf is
> that they just work fine and with that have as little dependencies as
> possible.

meson replaces m4 and shell scripting, as well as autoconf and automake
dialects with one "meson" dialect which just needs Python.

>  Personally I have not yet seen the benefit of Meson at all.

In short:
- it's more readable than autotools
- easier to debug as syntax is not run through 2 or 3 pre-processors
before error messages are generated
- provides fortify/ubsan/asan/valgrind support built-in
- faster to build by default (and is easier to make faster)
- required to port bluez to meson, which is needed to introduce, to
start with, Rust plugins and/or port existing plugins to Rust, to lower
the security burden

>  Adding more shell scripts is also not a solution.

gen-cert-expired-pem.sh is the only one that's strictly necessary. I
mentioned in another thread that xxd.sh could be removed but that would
require changes in both the meson and autotools build systems, and I
didn't want to require that as part of adding the meson build system.

> ELL build has still a few issues that I would like to eradicate
> first. The usage of xxd and the openssl binary is a pain and also
> leaves artifacts around. Frankly, it would be best all the certs are
> created by a dedicated tool using libssl directly.

Those seem like tangential issues to a new build system. meson, as it
requires a separate build dir, doesn't leave any "artifacts" around,
the source directory is completely untouched during builds.

As I mentioned earlier in this thread, I'm happy to do what's needed to
add the ell build to the CI, expanding it with ABI checking, making
tests faster, maybe even implementing the changes you mentioned. But
that requires getting a foot in the door, as I can't justify
contributing more when I'm being blocked for my end goal.

I'm happy to have the burden put on me to keep up with other changes in
the autotools variant of the build system and adapt.

I should add that this makes ell more appealing to be used in other
projects, as it makes it easier to use either an external or a vendored
library.

I need this to finish the bluez port, which would bring it in line with
an increasingly large majority of system utilities and daemons
targetting Linux, whether that's Mesa, NetworkManager, libvirt, and
nearly every freedesktop project, most of GNOME, an increasing number
of KDE projects, etc.

Cheers
