Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net [217.70.183.193])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B020725D21A
	for <ell@lists.linux.dev>; Wed, 20 Aug 2025 09:02:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=217.70.183.193
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1755680553; cv=none; b=ohHbf4k0k+BI1XOAiZYZCWfS2dU0KTeS1womy2NLmJOuvey/JYihGNec0OOJel463nX0+M4lJdNvRUCF+coZ3QcxKbUnWNcHP+XrZVYx6R7MzDdXX2C9Iioc0MLYeX2wAuPU7BgZqBwutugGTvU4n+sGOfqivktGSSOPH7QOWkM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1755680553; c=relaxed/simple;
	bh=afZW4mDmdy1plsyNHyrSUncJRd2EHaGyC1sFNcyffmI=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=JtqoiQKAiUB2qwfq647g7tIN6xUYA9tjhGuhTyUIjY0n3OUdG4V5d0RMUAjJsVY2TSQjt3mYGQSXzFIg7a5wNmqi6lNZyubk2fzkdkoFz/PAo3QkopOJcTgYJ4bJtsR0S5lHY7CZTXuLIBpAl9I0ZPrf5jw8MQgX0sXSuI2uMX8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net; spf=pass smtp.mailfrom=hadess.net; arc=none smtp.client-ip=217.70.183.193
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=hadess.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hadess.net
Received: by mail.gandi.net (Postfix) with ESMTPSA id A218C43279
	for <ell@lists.linux.dev>; Wed, 20 Aug 2025 09:02:21 +0000 (UTC)
Message-ID: <bd05acb2cb6bb96ff13d1c82b0fb2d28c199a843.camel@hadess.net>
Subject: Re: [PATCH v5 1/1] build: Add meson build system
From: Bastien Nocera <hadess@hadess.net>
To: ell@lists.linux.dev
Date: Wed, 20 Aug 2025 11:02:21 +0200
In-Reply-To: <5939828972792a22be2680c6b2bf377f1cd0d437.camel@hadess.net>
References: <20250807134859.930870-1-hadess@hadess.net>
		 <20250807134859.930870-2-hadess@hadess.net>
	 <5939828972792a22be2680c6b2bf377f1cd0d437.camel@hadess.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2 (3.56.2-1.fc42) 
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
X-GND-State: clean
X-GND-Score: 0
X-GND-Cause: gggruggvucftvghtrhhoucdtuddrgeeffedrtdefgdduheejleehucetufdoteggodetrfdotffvucfrrhhofhhilhgvmecuifetpfffkfdpucggtfgfnhhsuhgsshgtrhhisggvnecuuegrihhlohhuthemuceftddunecunecujfgurhepkffuhffvffgjfhgtgfgfggesthhqredttderjeenucfhrhhomhepuegrshhtihgvnhcupfhotggvrhgruceohhgruggvshhssehhrgguvghsshdrnhgvtheqnecuggftrfgrthhtvghrnhepveejkeejvdfhgedvjeethedtgfdvjeeiheffleetleeljefhleelgefgvedtleeknecuffhomhgrihhnpehkvghrnhgvlhdrohhrghdpmhgvshhonhgsuhhilhgurdgtohhmnecukfhppedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffeenucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepihhnvghtpedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffedphhgvlhhopeglkffrvheimedvrgdtudemvgefgeemvggtjeefmegtfhdvtdemjeduuggrmeefsggumedvtdgrleemudeffegnpdhmrghilhhfrhhomhephhgruggvshhssehhrgguvghsshdrnhgvthdpnhgspghrtghpthhtohepuddprhgtphhtthhopegvlhhlsehlihhsthhsrdhlihhnuhigrdguvghv
X-GND-Sasl: hadess@hadess.net

Sorry to nag, I'd really appreciate if you could review and merge this,
as it's blocking any further work on bluez.

Cheers

On Mon, 2025-08-11 at 23:23 +0200, Bastien Nocera wrote:
> Hello,
>=20
> Any feedback? This doesn't make any changes to the autotools build
> system, so should be easy to ignore for folks that don't like meson
> or
> want more time to experiment with it.
>=20
> I've posted the bluez meson patches today, after getting some prep
> patches merged:
> https://patchwork.kernel.org/project/bluetooth/list/?series=3D990211
>=20
> On Thu, 2025-08-07 at 15:47 +0200, Bastien Nocera wrote:
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
> > =C2=A0ell/meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 187 +++++++++++++
> > =C2=A0examples/meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 |=C2=A0 32 +++
> > =C2=A0meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 69 +++++
> > =C2=A0meson_options.txt=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0 5 +
> > =C2=A0tools/meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 |=C2=A0 18 ++
> > =C2=A0unit/gen-cert-expired-pem.sh |=C2=A0 14 +
> > =C2=A0unit/meson.build=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 | 501
> > +++++++++++++++++++++++++++++++++++
> > =C2=A0unit/xxd.sh=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0=C2=A0 3 +
> > =C2=A08 files changed, 829 insertions(+)
> > =C2=A0create mode 100644 ell/meson.build
> > =C2=A0create mode 100644 examples/meson.build
> > =C2=A0create mode 100644 meson.build
> > =C2=A0create mode 100644 meson_options.txt
> > =C2=A0create mode 100644 tools/meson.build
> > =C2=A0create mode 100755 unit/gen-cert-expired-pem.sh
> > =C2=A0create mode 100644 unit/meson.build
> > =C2=A0create mode 100755 unit/xxd.sh
> >=20
> > diff --git a/ell/meson.build b/ell/meson.build
> > new file mode 100644
> > index 000000000000..ba61a39a8cc3
> > --- /dev/null
> > +++ b/ell/meson.build
> > @@ -0,0 +1,187 @@
> > +lib_headers =3D [
> > +=C2=A0 'ell.h',
> > +=C2=A0 'util.h',
> > +=C2=A0 'test.h',
> > +=C2=A0 'strv.h',
> > +=C2=A0 'utf8.h',
> > +=C2=A0 'queue.h',
> > +=C2=A0 'hashmap.h',
> > +=C2=A0 'string.h',
> > +=C2=A0 'settings.h',
> > +=C2=A0 'main.h',
> > +=C2=A0 'idle.h',
> > +=C2=A0 'signal.h',
> > +=C2=A0 'timeout.h',
> > +=C2=A0 'io.h',
> > +=C2=A0 'ringbuf.h',
> > +=C2=A0 'log.h',
> > +=C2=A0 'checksum.h',
> > +=C2=A0 'netlink.h',
> > +=C2=A0 'genl.h',
> > +=C2=A0 'rtnl.h',
> > +=C2=A0 'dbus.h',
> > +=C2=A0 'dbus-service.h',
> > +=C2=A0 'dbus-client.h',
> > +=C2=A0 'hwdb.h',
> > +=C2=A0 'cipher.h',
> > +=C2=A0 'random.h',
> > +=C2=A0 'uintset.h',
> > +=C2=A0 'base64.h',
> > +=C2=A0 'pem.h',
> > +=C2=A0 'tls.h',
> > +=C2=A0 'uuid.h',
> > +=C2=A0 'key.h',
> > +=C2=A0 'file.h',
> > +=C2=A0 'dir.h',
> > +=C2=A0 'net.h',
> > +=C2=A0 'dhcp.h',
> > +=C2=A0 'dhcp6.h',
> > +=C2=A0 'cert.h',
> > +=C2=A0 'ecc.h',
> > +=C2=A0 'ecdh.h',
> > +=C2=A0 'time.h',
> > +=C2=A0 'gpio.h',
> > +=C2=A0 'path.h',
> > +=C2=A0 'icmp6.h',
> > +=C2=A0 'acd.h',
> > +=C2=A0 'tester.h',
> > +=C2=A0 'cleanup.h',
> > +=C2=A0 'netconfig.h',
> > +=C2=A0 'sysctl.h',
> > +=C2=A0 'minheap.h',
> > +=C2=A0 'notifylist.h'
> > +]
> > +
> > +lib_sources =3D [
> > +=C2=A0 'private.h',
> > +=C2=A0 'useful.h',
> > +=C2=A0 'missing.h',
> > +=C2=A0 'util.c',
> > +=C2=A0 'test-private.h',
> > +=C2=A0 'test.c',
> > +=C2=A0 'test-dbus.c',
> > +=C2=A0 'strv.c',
> > +=C2=A0 'utf8.c',
> > +=C2=A0 'queue.c',
> > +=C2=A0 'hashmap.c',
> > +=C2=A0 'string.c',
> > +=C2=A0 'settings.c',
> > +=C2=A0 'main-private.h',
> > +=C2=A0 'main.c',
> > +=C2=A0 'idle.c',
> > +=C2=A0 'signal.c',
> > +=C2=A0 'timeout.c',
> > +=C2=A0 'io.c',
> > +=C2=A0 'ringbuf.c',
> > +=C2=A0 'log.c',
> > +=C2=A0 'checksum.c',
> > +=C2=A0 'netlink-private.h',
> > +=C2=A0 'netlink.c',
> > +=C2=A0 'genl.c',
> > +=C2=A0 'rtnl-private.h',
> > +=C2=A0 'rtnl.c',
> > +=C2=A0 'dbus-private.h',
> > +=C2=A0 'dbus.c',
> > +=C2=A0 'dbus-message.c',
> > +=C2=A0 'dbus-util.c',
> > +=C2=A0 'dbus-service.c',
> > +=C2=A0 'dbus-client.c',
> > +=C2=A0 'dbus-name-cache.c',
> > +=C2=A0 'dbus-filter.c',
> > +=C2=A0 'gvariant-private.h',
> > +=C2=A0 'gvariant-util.c',
> > +=C2=A0 'siphash-private.h',
> > +=C2=A0 'siphash.c',
> > +=C2=A0 'hwdb.c',
> > +=C2=A0 'cipher.c',
> > +=C2=A0 'random.c',
> > +=C2=A0 'uintset.c',
> > +=C2=A0 'base64.c',
> > +=C2=A0 'asn1-private.h',
> > +=C2=A0 'pem-private.h',
> > +=C2=A0 'pem.c',
> > +=C2=A0 'tls-private.h',
> > +=C2=A0 'tls.c',
> > +=C2=A0 'tls-record.c',
> > +=C2=A0 'tls-extensions.c',
> > +=C2=A0 'tls-suites.c',
> > +=C2=A0 'uuid.c',
> > +=C2=A0 'key.c',
> > +=C2=A0 'file.c',
> > +=C2=A0 'dir.c',
> > +=C2=A0 'net-private.h',
> > +=C2=A0 'net.c',
> > +=C2=A0 'dhcp-private.h',
> > +=C2=A0 'dhcp.c',
> > +=C2=A0 'dhcp-transport.c',
> > +=C2=A0 'dhcp-lease.c',
> > +=C2=A0 'dhcp6-private.h',
> > +=C2=A0 'dhcp6.c',
> > +=C2=A0 'dhcp6-transport.c',
> > +=C2=A0 'dhcp6-lease.c',
> > +=C2=A0 'dhcp-util.c',
> > +=C2=A0 'dhcp-server.c',
> > +=C2=A0 'cert-private.h',
> > +=C2=A0 'cert.c',
> > +=C2=A0 'cert-crypto.c',
> > +=C2=A0 'ecc-private.h',
> > +=C2=A0 'ecc.h',
> > +=C2=A0 'ecc-external.c',
> > +=C2=A0 'ecc.c',
> > +=C2=A0 'ecdh.c',
> > +=C2=A0 'time.c',
> > +=C2=A0 'time-private.h',
> > +=C2=A0 'gpio.c',
> > +=C2=A0 'path.c',
> > +=C2=A0 'icmp6.c',
> > +=C2=A0 'icmp6-private.h',
> > +=C2=A0 'acd.c',
> > +=C2=A0 'tester.c',
> > +=C2=A0 'netconfig.c',
> > +=C2=A0 'sysctl.c',
> > +=C2=A0 'minheap.c',
> > +=C2=A0 'notifylist.c'
> > +]
> > +
> > +linux_headers =3D [
> > +=C2=A0 '../linux/gpio.h'
> > +]
> > +
> > +libell =3D library('ell',
> > +=C2=A0 sources: lib_headers + lib_sources + linux_headers,
> > +=C2=A0 include_directories: include_directories('..'),
> > +=C2=A0 implicit_include_directories: false,
> > +=C2=A0 gnu_symbol_visibility: 'hidden',
> > +=C2=A0 version: '0.2.0',
> > +=C2=A0 install: get_option('default_library') !=3D 'static'
> > +)
> > +
> > +libell_dep =3D declare_dependency(include_directories:
> > include_directories('..'),
> > +=C2=A0 link_with: libell)
> > +
> > +if get_option('default_library') !=3D 'static'
> > +=C2=A0 install_headers(lib_headers,
> > +=C2=A0=C2=A0=C2=A0 subdir: 'ell'
> > +=C2=A0 )
> > +
> > +=C2=A0 pkgconfig =3D import('pkgconfig')
> > +=C2=A0 pkgconfig.generate(
> > +=C2=A0=C2=A0=C2=A0 name: 'ell',
> > +=C2=A0=C2=A0=C2=A0 description: 'Embedded Linux library',
> > +=C2=A0=C2=A0=C2=A0 version: meson.project_version(),
> > +=C2=A0=C2=A0=C2=A0 libraries: libell,
> > +=C2=A0=C2=A0=C2=A0 # FIXME requires meson 1.9.0
> > +=C2=A0=C2=A0=C2=A0 # license: meson.project_license()
> > +=C2=A0 )
> > +endif
> > +
> > +libell_private =3D static_library('ell_private',
> > +=C2=A0 sources: lib_headers + lib_sources + linux_headers,
> > +=C2=A0 include_directories: include_directories('..'),
> > +=C2=A0 implicit_include_directories: false,
> > +=C2=A0 install: false
> > +)
> > +
> > +libell_private_dep =3D declare_dependency(
> > +=C2=A0 link_with: libell_private
> > +)
> > diff --git a/examples/meson.build b/examples/meson.build
> > new file mode 100644
> > index 000000000000..831abb58be46
> > --- /dev/null
> > +++ b/examples/meson.build
> > @@ -0,0 +1,32 @@
> > +examples =3D [
> > +=C2=A0 'dbus-service',
> > +=C2=A0 'https-client-test',
> > +=C2=A0 'https-server-test',
> > +=C2=A0 'dbus-client',
> > +=C2=A0 'dhcp-client',
> > +=C2=A0 'dhcp6-client',
> > +=C2=A0 'dhcp-server',
> > +=C2=A0 'acd-client',
> > +=C2=A0 'netconfig-test',
> > +]
> > +
> > +if get_option('examples')
> > +=C2=A0 foreach example: examples
> > +=C2=A0=C2=A0=C2=A0 exe =3D executable(example,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '@0@.c'.format(example),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 include_directories: include_directorie=
s('..'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 dependencies: libell_private_dep,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 install: false
> > +=C2=A0=C2=A0=C2=A0 )
> > +=C2=A0 endforeach
> > +endif
> > +
> > +if get_option('glib') and get_option('examples')
> > +=C2=A0 exe =3D executable('glib-eventloop',
> > +=C2=A0=C2=A0=C2=A0 'glib-eventloop.c',
> > +=C2=A0=C2=A0=C2=A0 include_directories: include_directories('..'),
> > +=C2=A0=C2=A0=C2=A0 dependencies: [ libell_private_dep, glib_dep ],
> > +=C2=A0=C2=A0=C2=A0 install: false
> > +=C2=A0 )
> > +endif
> > +
> > diff --git a/meson.build b/meson.build
> > new file mode 100644
> > index 000000000000..5701dab77e5f
> > --- /dev/null
> > +++ b/meson.build
> > @@ -0,0 +1,69 @@
> > +# SPDX-License-Identifier: LGPL-2.1-or-later
> > +project(
> > +=C2=A0 'ell', 'c',
> > +=C2=A0 version: '0.79',
> > +=C2=A0 license: 'LGPL-2.1-or-later',
> > +=C2=A0 default_options: [
> > +=C2=A0=C2=A0=C2=A0 'buildtype=3Ddebugoptimized',
> > +=C2=A0=C2=A0=C2=A0 'default_library=3Dshared'
> > +=C2=A0 ],
> > +=C2=A0 meson_version: '>=3D 1.3.0'
> > +)
> > +
> > +cc =3D meson.get_compiler('c')
> > +find_program('awk', required: true)
> > +config_h =3D configuration_data()
> > +
> > +checked_funcs =3D [
> > +=C2=A0 'explicit_bzero',
> > +=C2=A0 'rawmemchr',
> > +]
> > +
> > +foreach func: checked_funcs
> > +=C2=A0 config_h.set('HAVE_' + func.to_upper(), cc.has_function(func))
> > +endforeach
> > +
> > +required_funcs =3D [
> > +=C2=A0 'getrandom',
> > +=C2=A0 'signalfd',
> > +=C2=A0 'timerfd_create',
> > +=C2=A0 'epoll_create'
> > +]
> > +
> > +foreach func: required_funcs
> > +=C2=A0 cc.has_function(func, required: true)
> > +endforeach
> > +
> > +required_headers =3D [
> > +=C2=A0 'linux/types.h',
> > +=C2=A0 'linux/if_alg.h'
> > +]
> > +
> > +foreach header: required_headers
> > +=C2=A0 cc.has_header(header, required: true)
> > +endforeach
> > +
> > +glib_dep =3D dependency('glib-2.0', version: '>=3D 2.32', required:
> > get_option('glib'))
> > +openssl =3D find_program('openssl', required: get_option('cert-
> > tests'))
> > +sh =3D find_program('sh', required: get_option('cert-tests'))
> > +xxd =3D find_program('xxd', required: get_option('cert-tests'))
> > +
> > +if openssl.found()
> > +=C2=A0 r =3D run_command(openssl, 'list', '-providers', check: false)
> > +=C2=A0 if r.returncode() =3D=3D 0
> > +=C2=A0=C2=A0=C2=A0 openssl_legacy =3D [ '-provider', 'legacy', '-provi=
der',
> > 'default'
> > ]
> > +=C2=A0 else
> > +=C2=A0=C2=A0=C2=A0 openssl_legacy =3D ''
> > +=C2=A0 endif
> > +endif
> > +
> > +add_project_arguments('-DHAVE_CONFIG_H', language: 'c')
> > +configure_file(
> > +=C2=A0 output: 'config.h',
> > +=C2=A0 configuration: config_h
> > +)
> > +
> > +subdir('ell')
> > +subdir('tools')
> > +subdir('unit')
> > +subdir('examples')
> > diff --git a/meson_options.txt b/meson_options.txt
> > new file mode 100644
> > index 000000000000..5effa15916b4
> > --- /dev/null
> > +++ b/meson_options.txt
> > @@ -0,0 +1,5 @@
> > +option('glib', type: 'boolean', value: true, description: 'Enable
> > ell/glib main loop example')
> > +option('tests', type: 'boolean', value: true, description: 'Enable
> > unit tests compilation')
> > +option('cert-tests', type: 'boolean', value: true, description:
> > 'Enable OpenSSL cert tests')
> > +option('tools', type: 'boolean', value: true, description: 'Enable
> > extra tools compilation')
> > +option('examples', type: 'boolean', value: true, description:
> > 'Enable code examples compilation')
> > diff --git a/tools/meson.build b/tools/meson.build
> > new file mode 100644
> > index 000000000000..01505f266631
> > --- /dev/null
> > +++ b/tools/meson.build
> > @@ -0,0 +1,18 @@
> > +tools =3D [
> > +=C2=A0 'certchain-verify',
> > +=C2=A0 'genl-discover',
> > +=C2=A0 'genl-watch',
> > +=C2=A0 'genl-request',
> > +=C2=A0 'gpio'
> > +]
> > +
> > +if get_option('tools')
> > +=C2=A0 foreach tool: tools
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 exe =3D executable(tool,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '@0@.c'.format(tool),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 include_directories: includ=
e_directories('..'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 dependencies: libell_privat=
e_dep,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 install: false
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 )
> > +=C2=A0 endforeach
> > +endif
> > diff --git a/unit/gen-cert-expired-pem.sh b/unit/gen-cert-expired-
> > pem.sh
> > new file mode 100755
> > index 000000000000..f3e0b9d28424
> > --- /dev/null
> > +++ b/unit/gen-cert-expired-pem.sh
> > @@ -0,0 +1,14 @@
> > +#!/bin/sh -e
> > +
> > +echo -n > cert-ca-index.txt
> > +OUTDIR=3D`mktemp -d`
> > +openssl ca -batch \
> > +	-config "$4" -name example \
> > +	-cert "$2" \
> > +	-keyfile "$3" \
> > +	-outdir $OUTDIR \
> > +	-rand_serial -extensions cert_ext \
> > +	-extfile "$5" -md sha256 \
> > +	-startdate 000101120000Z -enddate 010101120000Z \
> > +	-preserveDN -notext -in "$1" -out "$6"
> > +rm -rf $OUTDIR cert-ca-index.txt*
> > diff --git a/unit/meson.build b/unit/meson.build
> > new file mode 100644
> > index 000000000000..be9f2655f010
> > --- /dev/null
> > +++ b/unit/meson.build
> > @@ -0,0 +1,501 @@
> > +tests =3D [
> > +=C2=A0 'test-unit',
> > +=C2=A0 'test-queue',
> > +=C2=A0 'test-hashmap',
> > +=C2=A0 'test-endian',
> > +=C2=A0 'test-string',
> > +=C2=A0 'test-utf8',
> > +=C2=A0 'test-main',
> > +=C2=A0 'test-io',
> > +=C2=A0 'test-ringbuf',
> > +=C2=A0 'test-checksum',
> > +=C2=A0 'test-settings',
> > +=C2=A0 'test-netlink',
> > +=C2=A0 'test-genl-msg',
> > +=C2=A0 'test-rtnl',
> > +=C2=A0 'test-siphash',
> > +=C2=A0 'test-cipher',
> > +=C2=A0 'test-random',
> > +=C2=A0 'test-util',
> > +=C2=A0 'test-uintset',
> > +=C2=A0 'test-base64',
> > +=C2=A0 'test-uuid',
> > +=C2=A0 'test-pbkdf2',
> > +=C2=A0 'test-dhcp',
> > +=C2=A0 'test-dhcp6',
> > +=C2=A0 'test-dir-watch',
> > +=C2=A0 'test-ecc',
> > +=C2=A0 'test-ecdh',
> > +=C2=A0 'test-time',
> > +=C2=A0 'test-path',
> > +=C2=A0 'test-net',
> > +=C2=A0 'test-sysctl',
> > +=C2=A0 'test-minheap',
> > +=C2=A0 'test-notifylist',
> > +=C2=A0 'test-hwdb',
> > +=C2=A0 'test-dbus',
> > +=C2=A0 'test-dbus-util',
> > +=C2=A0 'test-dbus-message',
> > +=C2=A0 'test-dbus-message-fds',
> > +=C2=A0 'test-dbus-properties',
> > +=C2=A0 'test-dbus-service',
> > +=C2=A0 'test-dbus-watch',
> > +=C2=A0 'test-gvariant-util',
> > +=C2=A0 'test-gvariant-message'
> > +]
> > +
> > +gen_headers =3D []
> > +test_pem_cert_deps =3D []
> > +
> > +if get_option('cert-tests')
> > +=C2=A0 tests +=3D [
> > +=C2=A0=C2=A0=C2=A0 'test-pem',
> > +=C2=A0=C2=A0=C2=A0 'test-tls',
> > +=C2=A0=C2=A0=C2=A0 'test-key'
> > +=C2=A0 ]
> > +
> > +=C2=A0 cert_server_key_pem_tgt =3D custom_target('cert-server-key.pem'=
,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-server-key.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'genrsa', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 ec_cert_server_key_pem_tgt =3D custom_target('ec-cert-server-
> > key.pem',
> > +=C2=A0=C2=A0=C2=A0 output: 'ec-cert-server-key.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'ecparam', '-out', '@OUTPUT@', =
'-name',
> > 'secp384r1', '-genkey' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_server_key_pkcs8_pem_tgt =3D custom_target('cert-server-ke=
y-
> > pkcs8.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_server_key_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-server-key-pkcs8.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs8', '-topk8', '-nocrypt', =
'-in',
> > '@INPUT@', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_server_csr_tgt =3D custom_target('cert-server.csr',
> > +=C2=A0=C2=A0=C2=A0 input: cert_server_key_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-server.csr',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'req', '-new', '-extensions', '=
cert_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-subj', '/O=3DFoo Example Organization=
/CN=3DFoo Example
> > Organization/emailAddress=3Dfoo@mail.example',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 ec_cert_server_csr_tgt =3D custom_target('ec-cert-server.csr',
> > +=C2=A0=C2=A0=C2=A0 input: ec_cert_server_key_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'ec-cert-server.csr',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'req', '-new', '-extensions', '=
cert_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-subj', '/O=3DFoo Example Organization=
/CN=3DFoo Example
> > Organization/emailAddress=3Dfoo@mail.example',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_ca_key_pem_tgt =3D custom_target('cert-ca-key.pem',
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-ca-key.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'genrsa', '-out', '@OUTPUT@', '=
2048' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_ca_pem_tgt =3D custom_target('cert-ca.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_ca_key_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-ca.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'req', '-x509', '-new', '-nodes=
', '-
> > extensions', 'ca_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'), '-sub=
j', '/O=3DInternational
> > Union of Example Organizations/CN=3DCertificate issuer
> > guy/emailAddress=3Dca@mail.example',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-sha256', '-days', =
'10000', '-out',
> > '@OUTPUT@' ],
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_server_pem_tgt =3D custom_target('cert-server.pem',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_server_csr_tgt, cert_ca_pem_tgt,
> > cert_ca_key_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-server.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'x509', '-req', '-extensions',
> > 'server_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-extfile', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-in', '@INPUT0@', '-CA', '@INPUT1@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAkey', '@INPUT2@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAserial', 'cert-ca.srl',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAcreateserial', '-sha256', '-days', =
'10000', '-out',
> > '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 ec_cert_ca_key_pem_tgt =3D custom_target('ec-cert-ca-key.pem',
> > +=C2=A0=C2=A0=C2=A0 output: 'ec-cert-ca-key.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'ecparam', '-out', '@OUTPUT@', =
'-name',
> > 'secp384r1', '-genkey' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 ec_cert_ca_pem_tgt =3D custom_target('ec-cert-ca.pem',
> > +=C2=A0 input: ec_cert_ca_key_pem_tgt,
> > +=C2=A0 output: 'ec-cert-ca.pem',
> > +=C2=A0 command: [ openssl, 'req', '-x509', '-new', '-nodes', '-
> > extensions', 'ca_ext',
> > +=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'), '-subj', '/O=3DIn=
ternational
> > Union of Example Organizations/CN=3DCertificate issuer
> > guy/emailAddress=3Dca@mail.example',
> > +=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-sha256', '-days', '10000', '-o=
ut',
> > '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 ec_cert_server_pem_tgt =3D custom_target('ec-cert-server.pem',
> > +=C2=A0=C2=A0=C2=A0 input: [ ec_cert_server_csr_tgt, ec_cert_ca_pem_tgt=
,
> > ec_cert_ca_key_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'ec-cert-server.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'x509', '-req', '-extensions',
> > 'server_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-extfile', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-in', '@INPUT0@', '-CA', '@INPUT1@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAkey', '@INPUT2@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAserial', 'cert-ca.srl',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAcreateserial', '-sha256', '-days', =
'10000', '-out',
> > '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_key_pkcs1_pem_tgt =3D custom_target('cert-client-ke=
y-
> > pkcs1.pem',
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client-key-pkcs1.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'genrsa', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_key_pkcs8_pem_tgt =3D custom_target('cert-client-ke=
y-
> > pkcs8.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs1_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client-key-pkcs8.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs8', '-topk8', '-nocrypt', =
'-in',
> > '@INPUT@', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_key_pkcs8_md5_des_pem_tgt =3D custom_target('cert-
> > client-key-pkcs8-md5-des.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs8_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client-key-pkcs8-md5-des.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs8', '-in', '@INPUT@', '-ou=
t',
> > '@OUTPUT@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-topk8', '-v1', 'PBE-MD5-DES', '-passo=
ut', 'pass:abc',
> > openssl_legacy ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_key_pkcs8_v2_des_pem_tgt =3D custom_target('cert-
> > client-
> > key-pkcs8-v2-des.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs8_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client-key-pkcs8-v2-des.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs8', '-in', '@INPUT@', '-ou=
t',
> > '@OUTPUT@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-topk8', '-v2', 'des-cbc', '-v2prf', '=
hmacWithSHA1', '-
> > passout', 'pass:abc',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 openssl_legacy ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_key_pkcs8_v2_des_ede3_pem_tgt =3D custom_target('ce=
rt-
> > client-key-pkcs8-v2-des-ede3.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs8_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client-key-pkcs8-v2-des-ede3.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs8', '-in', '@INPUT@', '-ou=
t',
> > '@OUTPUT@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-topk8', '-v2', 'des-ede3-=
cbc', '-v2prf',
> > 'hmacWithSHA224',
> > '-passout', 'pass:abc' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_key_pkcs8_v2_aes128_pem_tgt =3D custom_target('cert=
-
> > client-key-pkcs8-v2-aes128.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs8_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client-key-pkcs8-v2-aes128.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs8', '-in', '@INPUT@', '-ou=
t',
> > '@OUTPUT@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-topk8', '-v2', 'aes128', '-v2prf', 'h=
macWithSHA256', '-
> > passout', 'pass:abc' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_key_pkcs8_sha1_des_pem_tgt =3D custom_target('cert-
> > client-key-pkcs8-sha1-des.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs8_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client-key-pkcs8-sha1-des.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs8', '-in', '@INPUT@', '-ou=
t',
> > '@OUTPUT@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-topk8', '-v1', 'PBE-SHA1-DES', '-pass=
out', 'pass:abc',
> > openssl_legacy ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_key_pkcs8_v2_aes256_pem_tgt =3D custom_target('cert=
-
> > client-key-pkcs8-v2-aes256.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs8_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client-key-pkcs8-v2-aes256.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs8', '-in', '@INPUT@', '-ou=
t',
> > '@OUTPUT@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-topk8', '-v2', 'aes256', '-v2prf', 'h=
macWithSHA512', '-
> > passout', 'pass:abc' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_csr_tgt =3D custom_target('cert-client.csr',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs1_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client.csr',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'req', '-new', '-extensions', '=
cert_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-subj', '/O=3DBar Example Organization=
/CN=3DBar Example
> > Organization/emailAddress=3Dbar@mail.example',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-out', '@OUTPUT@'
> > +=C2=A0=C2=A0=C2=A0 ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_pem_tgt =3D custom_target('cert-client.pem',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_client_csr_tgt, cert_ca_pem_tgt,
> > cert_ca_key_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'x509', '-req', '-extensions', =
'cert_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-extfile', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-in', '@INPUT0@', '-CA', '@INPUT1@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAkey', '@INPUT2@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAserial', 'cert-ca.srl',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAcreateserial', '-sha256', '-days', =
'10000', '-out',
> > '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_crt_tgt =3D custom_target('cert-client.crt',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client.crt',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'x509', '-in', '@INPUT@', '-out=
',
> > '@OUTPUT@', '-outform', 'der' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_intca_key_pem_tgt =3D custom_target('cert-intca-key.pem',
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-intca-key.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'genrsa', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_intca_csr_tgt =3D custom_target('cert-intca.csr',
> > +=C2=A0=C2=A0=C2=A0 input: cert_intca_key_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-intca.csr',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'req', '-new', '-extensions', '=
int_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-subj', '/O=3DInternational Union of E=
xample
> > Organizations/CN=3DCertificate issuer
> > guy/emailAddress=3Dca@mail.example',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_intca_pem_tgt =3D custom_target('cert-intca.pem',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_intca_csr_tgt, cert_ca_pem_tgt,
> > cert_ca_key_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-intca.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'x509', '-req', '-extensions', =
'int_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-extfile', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-in', '@INPUT0@', '-CA', '@INPUT1@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAkey', '@INPUT2@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAserial', 'cert-ca.srl',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAcreateserial', '-sha256', '-days', =
'10000', '-out',
> > '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cat =3D find_program('cat')
> > +
> > +=C2=A0 cert_chain_pem_tgt =3D custom_target('cert-chain.pem',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_intca_pem_tgt, cert_ca_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-chain.pem',
> > +=C2=A0=C2=A0=C2=A0 capture: true,
> > +=C2=A0=C2=A0=C2=A0 command: [ cat, '@INPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_entity_int_key_pem_tgt =3D custom_target('cert-entity-int-
> > key.pem',
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-entity-int-key.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'genrsa', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_entity_int_csr_tgt =3D custom_target('cert-entity-int.csr'=
,
> > +=C2=A0=C2=A0=C2=A0 input: cert_entity_int_key_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-entity-int.csr',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'req', '-new', '-extensions', '=
cert_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-subj', '/O=3DBaz Example Organization=
/CN=3DBaz Example
> > Organization/emailAddress=3Dbaz@mail.example',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_entity_int_pem_tgt =3D custom_target('cert-entity-int.pem'=
,
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_entity_int_csr_tgt, cert_intca_pem_tg=
t,
> > cert_intca_key_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-entity-int.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'x509', '-req', '-extensions', =
'cert_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-extfile', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-in', '@INPUT0@', '-CA', '@INPUT1@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAkey', '@INPUT2@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAserial', 'cert-intca.srl',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAcreateserial', '-sha256', '-days', =
'10000', '-out',
> > '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_ca2_pem_tgt =3D custom_target('cert-ca2.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_ca_key_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-ca2.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'req', '-x509', '-new', '-nodes=
', '-
> > extensions', 'ca_no_akid_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-subj', '/O=3DInternational Union of E=
xample
> > Organizations/CN=3DCertificate issuer
> > guy/emailAddress=3Dca-no-akid@mail.example',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-sha256', '-days', =
'10000', '-out',
> > '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_client_key_pkcs1_des_pem_tgt =3D custom_target('cert-clien=
t-
> > key-pkcs1-des.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs1_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-client-key-pkcs1-des.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'rsa', '-in', '@INPUT@', '-out'=
,
> > '@OUTPUT@',
> > '-des', '-passout', 'pass:abc', openssl_legacy ],
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_no_keyid_csr_tgt =3D custom_target('cert-no-keyid.csr',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs1_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-no-keyid.csr',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'req', '-new',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-subj', '/O=3DBaz Example Organization=
/CN=3DBaz Example
> > Organization/emailAddress=3Dbaz@mail.example',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_no_keyid_pem_tgt =3D custom_target('cert-no-keyid.pem',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_no_keyid_csr_tgt, cert_ca2_pem_tgt,
> > cert_ca_key_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-no-keyid.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'x509', '-req', '-extensions',
> > 'no_keyid_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-extfile', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-in', '@INPUT0@', '-CA', '@INPUT1@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAkey', '@INPUT2@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAserial', 'cert-ca2.srl',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-CAcreateserial', '-sha256', '-days', =
'10000', '-out',
> > '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_expired_csr_tgt =3D custom_target('cert-expired.csr',
> > +=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs1_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-expired.csr',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'req', '-new', '-extensions', '=
cert_ext',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-config', files('gencerts.cnf'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-subj', '/O=3DBar Example Organization=
/CN=3DBar Example
> > Organization/emailAddress=3Dbar@mail.example',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-key', '@INPUT@', '-out', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 echo =3D find_program('echo')
> > +
> > +=C2=A0 cert_ca_cnf_tgt =3D custom_target('cert-ca.cnf',
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-ca.cnf',
> > +=C2=A0=C2=A0=C2=A0 capture: true,
> > +=C2=A0=C2=A0=C2=A0 command: [ echo, '-e',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '[example]\ndatabase=3Dcert-ca-index.tx=
t\nserial=3Dcert-
> > ca.srl\npolicy=3Ddummy\n[dummy]' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_entity_pkcs12_rc2_sha1_p12_tgt =3D custom_target('cert-
> > entity-
> > pkcs12-rc2-sha1.p12',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_entity_int_key_pem_tgt, cert_entity_i=
nt_pem_tgt,
> > cert_chain_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-entity-pkcs12-rc2-sha1.p12',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs12', '-inkey', '@INPUT0@',=
 '-in',
> > '@INPUT1@', '-certfile', '@INPUT2@', '-out', '@OUTPUT@', '-export',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-passout', 'pass:abc', '-certpbe', 'PB=
E-SHA1-RC2-40', '-
> > keypbe', 'PBE-SHA1-RC2-128', '-macalg', 'sha1', openssl_legacy ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_entity_combined_pem_tgt =3D custom_target('cert-entity-
> > combined.pem',
> > +=C2=A0=C2=A0=C2=A0 input: cert_entity_pkcs12_rc2_sha1_p12_tgt,
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-entity-combined.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs12', '-in', '@INPUT@', '-o=
ut',
> > '@OUTPUT@', '-passin', 'pass:abc', '-passout', 'pass:abc',
> > openssl_legacy ]
> > +=C2=A0 )
> > +
> > +=C2=A0 gen_cert_expired_pem_sh =3D find_program('gen-cert-expired-
> > pem.sh')
> > +=C2=A0 cert_expired_pem_tgt =3D custom_target('cert-expired.pem',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_expired_csr_tgt, cert_ca_pem_tgt,
> > cert_ca_key_pem_tgt, cert_ca_cnf_tgt, files('gencerts.cnf') ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-expired.pem',
> > +=C2=A0=C2=A0=C2=A0 command: [ gen_cert_expired_pem_sh, '@INPUT0@', '@I=
NPUT1@',
> > '@INPUT2@', '@INPUT3@', '@INPUT4@', '@OUTPUT@' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_entity_pkcs12_nomac_p12_tgt =3D custom_target('cert-entity=
-
> > pkcs12-nomac.p12',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_entity_int_key_pem_tgt, cert_entity_i=
nt_pem_tgt
> > ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-entity-pkcs12-nomac.p12',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs12', '-inkey', '@INPUT0@',=
 '-in',
> > '@INPUT1@', '-out', '@OUTPUT@', '-export', '-passout', 'pass:abc',
> > '-
> > nomac' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_entity_pkcs12_des_sha256_p12_tgt =3D custom_target('cert-
> > entity-pkcs12-des-sha256.p12',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_entity_int_key_pem_tgt, cert_entity_i=
nt_pem_tgt,
> > cert_chain_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-entity-pkcs12-des-sha256.p12',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs12', '-inkey', '@INPUT0@',=
 '-in',
> > '@INPUT1@', '-certfile', '@INPUT2@', '-out', '@OUTPUT@', '-export',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-passout', 'pass:abc', '-certpbe', 'PB=
E-SHA1-3DES', '-
> > keypbe', 'PBE-SHA1-2DES', '-macalg', 'sha256' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_entity_pkcs12_rc4_sha384_p12_tgt =3D custom_target('cert-
> > entity-pkcs12-rc4-sha384.p12',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_entity_int_key_pem_tgt, cert_entity_i=
nt_pem_tgt,
> > cert_chain_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-entity-pkcs12-rc4-sha384.p12',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs12', '-inkey', '@INPUT0@',=
 '-in',
> > '@INPUT1@', '-certfile', '@INPUT2@', '-out', '@OUTPUT@', '-export',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-passout', 'pass:abc', '-certpbe', 'PB=
E-SHA1-RC4-128', '-
> > keypbe', 'PBE-SHA1-RC2-40', '-macalg', 'sha384', openssl_legacy ]
> > +=C2=A0 )
> > +
> > +=C2=A0 cert_entity_pkcs12_pkcs5_sha512_p12_tgt =3D custom_target('cert=
-
> > entity-pkcs12-pkcs5-sha512.p12',
> > +=C2=A0=C2=A0=C2=A0 input: [ cert_entity_int_key_pem_tgt, cert_entity_i=
nt_pem_tgt,
> > cert_chain_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'cert-entity-pkcs12-pkcs5-sha512.p12',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'pkcs12', '-inkey', '@INPUT0@',=
 '-in',
> > '@INPUT1@', '-certfile', '@INPUT2@', '-out', '@OUTPUT@', '-export',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-passout', 'pass:abc', '-certpbe', 'de=
s-cbc', '-keypbe',
> > 'des-cbc', '-macalg', 'sha512', openssl_legacy ]
> > +=C2=A0 )
> > +
> > +=C2=A0 key_ciphertext_dat_tgt =3D custom_target('key-ciphertext.dat',
> > +=C2=A0=C2=A0=C2=A0 input: [ 'plaintext.txt', cert_client_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 output: 'key-ciphertext.dat',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'rsautl', '-encrypt', '-pkcs', =
'-in',
> > '@INPUT0@', '-certin',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-inkey', '@INPUT1@', '-out', '@OUTPUT@=
' ]
> > +=C2=A0 )
> > +
> > +=C2=A0 key_signature_dat_tgt =3D custom_target('key-signature.dat',
> > +=C2=A0=C2=A0=C2=A0 input: 'plaintext.txt',
> > +=C2=A0=C2=A0=C2=A0 output: 'key-signature.dat',
> > +=C2=A0=C2=A0=C2=A0 command: [ openssl, 'rsautl', '-sign', '-pkcs', '-i=
n',
> > '@INPUT@',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-inkey', cert_client_key_pkcs1_pem_tgt=
, '-out', '@OUTPUT@'
> > ]
> > +=C2=A0 )
> > +
> > +=C2=A0 pem_rsa_files =3D [
> > +=C2=A0=C2=A0=C2=A0 [ 'cert-client-key-pkcs1-des3.pem', '-des3' ],
> > +=C2=A0=C2=A0=C2=A0 [ 'cert-client-key-pkcs1-aes128.pem', '-aes128' ],
> > +=C2=A0=C2=A0=C2=A0 [ 'cert-client-key-pkcs1-aes192.pem', '-aes192' ],
> > +=C2=A0=C2=A0=C2=A0 [ 'cert-client-key-pkcs1-aes256.pem', '-aes256' ],
> > +=C2=A0 ]
> > +
> > +=C2=A0 foreach file: pem_rsa_files
> > +=C2=A0=C2=A0=C2=A0 test_pem_cert_deps +=3D custom_target(file[0],
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 input: cert_client_key_pkcs1_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 output: file[0],
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 command: [ openssl, 'rsa', '-in', '@INP=
UT@', '-out',
> > '@OUTPUT@', file[1], '-passout', 'pass:abc' ]
> > +=C2=A0=C2=A0=C2=A0 )
> > +=C2=A0 endforeach
> > +
> > +=C2=A0 built_headers =3D [
> > +=C2=A0=C2=A0=C2=A0 [ 'plaintext.txt', 'key-plaintext.h' ],
> > +=C2=A0=C2=A0=C2=A0 [ key_ciphertext_dat_tgt, 'key-ciphertext.h' ],
> > +=C2=A0=C2=A0=C2=A0 [ key_signature_dat_tgt, 'key-signature.h' ]
> > +=C2=A0 ]
> > +
> > +=C2=A0 xxd_sh =3D find_program('xxd.sh')
> > +
> > +=C2=A0 foreach header: built_headers
> > +=C2=A0=C2=A0=C2=A0 gen_headers +=3D custom_target(header[1],
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 input: header[0],
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 output: header[1],
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 command: [ xxd_sh,'@INPUT@', '@OUTPUT@'=
 ]
> > +=C2=A0=C2=A0=C2=A0 )
> > +=C2=A0 endforeach
> > +
> > +=C2=A0 cert_verifs =3D [
> > +=C2=A0=C2=A0=C2=A0 [ cert_server_pem_tgt, cert_ca_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 [ ec_cert_server_pem_tgt, ec_cert_ca_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 [ cert_client_pem_tgt, cert_ca_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 [ cert_intca_pem_tgt, cert_ca_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 [ cert_entity_int_pem_tgt, cert_chain_pem_tgt ],
> > +=C2=A0=C2=A0=C2=A0 [ cert_no_keyid_pem_tgt, cert_ca2_pem_tgt ]
> > +=C2=A0 ]
> > +=C2=A0 foreach cert_verif: cert_verifs
> > +=C2=A0=C2=A0=C2=A0 test(cert_verif[0].full_path() + '-verify',
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 openssl,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 args: [ 'verify', '-CAfile', cert_verif=
[1].full_path(),
> > cert_verif[0].full_path() ]
> > +=C2=A0=C2=A0=C2=A0 )
> > +=C2=A0 endforeach
> > +
> > +=C2=A0 test_pem_cert_deps +=3D [
> > +=C2=A0=C2=A0=C2=A0 # test_pem
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs8_md5_des_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs8_sha1_des_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs8_v2_des_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs8_v2_des_ede3_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs8_v2_aes128_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs8_v2_aes256_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs1_des_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs1_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs1_des_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs8_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs8_sha1_des_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_crt_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_entity_combined_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_entity_pkcs12_nomac_p12_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_entity_pkcs12_rc2_sha1_p12_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_entity_pkcs12_des_sha256_p12_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_entity_pkcs12_rc4_sha384_p12_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_entity_pkcs12_pkcs5_sha512_p12_tgt,
> > +=C2=A0=C2=A0=C2=A0 # test_key
> > +=C2=A0=C2=A0=C2=A0 cert_ca_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_server_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_intca_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_entity_int_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_client_key_pkcs8_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 # test_tls
> > +=C2=A0=C2=A0=C2=A0 cert_chain_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_expired_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_ca2_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_no_keyid_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 ec_cert_ca_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 ec_cert_server_pem_tgt,
> > +=C2=A0=C2=A0=C2=A0 cert_server_key_pkcs8_pem_tgt
> > +=C2=A0 ]
> > +endif
> > +
> > +# Mocking l_getrandom() to get a stable random seed
> > +libell_private_ecdh_dep =3D declare_dependency(
> > +=C2=A0 link_with: libell_private,
> > +=C2=A0 link_args: '-Wl,-wrap,l_getrandom'
> > +)
> > +
> > +if get_option('tests') or get_option('cert-tests')
> > +=C2=A0 foreach test_name: tests
> > +=C2=A0=C2=A0=C2=A0 dep =3D test_name =3D=3D 'test-ecdh' ? libell_priva=
te_ecdh_dep :
> > libell_private_dep
> > +=C2=A0=C2=A0=C2=A0 exe =3D executable(test_name,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 [ '@0@.c'.format(test_name), gen_header=
s, test_pem_cert_deps
> > ],
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 include_directories: include_directorie=
s('..'),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 c_args: [
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-
> > DUNITDIR=3D"@0@/unit/"'.format(meson.project_source_root()),
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 '-DCERTDIR=3D"@0@/unit/"'.f=
ormat(meson.project_build_root())
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ],
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 dependencies: dep,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 install: false
> > +=C2=A0=C2=A0=C2=A0 )
> > +
> > +=C2=A0=C2=A0=C2=A0 test(test_name, exe,
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 protocol: 'tap')
> > +=C2=A0 endforeach
> > +endif
> > diff --git a/unit/xxd.sh b/unit/xxd.sh
> > new file mode 100755
> > index 000000000000..3fd26d2bce90
> > --- /dev/null
> > +++ b/unit/xxd.sh
> > @@ -0,0 +1,3 @@
> > +#!/bin/sh
> > +
> > +xxd -i < "$1" > "$2"
