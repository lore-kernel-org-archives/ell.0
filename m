Received: from mohas.pair.com (mohas.pair.com [209.68.5.112])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 076093AC0D
	for <ell@lists.linux.dev>; Mon, 20 Nov 2023 22:36:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from mohas.pair.com (localhost [127.0.0.1])
	by mohas.pair.com (Postfix) with ESMTP id 01007730CA;
	Mon, 20 Nov 2023 17:36:37 -0500 (EST)
Received: from [IPv6:2601:647:5a00:15c1:a424:ec39:b922:7d38] (unknown [IPv6:2601:647:5a00:15c1:a424:ec39:b922:7d38])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mohas.pair.com (Postfix) with ESMTPSA id 6CCCA730F3;
	Mon, 20 Nov 2023 17:36:36 -0500 (EST)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 13.4 \(3608.120.23.2.4\))
Subject: Re: ELL 0.59 Does Not Compile against Linux-4.9.212 and/or GLibC-2.28
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <DC4C03D7-B99E-475A-86AD-CB0AAD934BE3@holtmann.org>
Date: Mon, 20 Nov 2023 14:36:35 -0800
Cc: Denis Kenzior <denkenz@gmail.com>,
 ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <4109CD12-09E3-498F-A088-89847F416EFB@nuovations.com>
References: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
 <2b9a12a2-87a9-4e10-b24d-77268369d01d@gmail.com>
 <124DF4B5-4611-458F-8F68-E386891838AD@nuovations.com>
 <DC4C03D7-B99E-475A-86AD-CB0AAD934BE3@holtmann.org>
To: Marcel Holtmann <marcel@holtmann.org>
X-Mailer: Apple Mail (2.3608.120.23.2.4)
X-Scanned-By: mailmunge 3.11 on 209.68.5.112

On Nov 20, 2023, at 6:55 AM, Marcel Holtmann <marcel@holtmann.org> =
wrote:
>>>> ELL Community:
>>>>=20
>>>> Over on the connman mailing list, Marcel and Denis have been =
advocating, rightly so, for iwd over wpa_supplicant for Wi-Fi.
>>>> Is there a kernel version expectation of ELL?
>>=20
>> Will do. I=E2=80=99m running openssl-1.1.1w.
>>=20
>> Regarding the patches, won=E2=80=99t inclusion of an uprev netlink =
header result in a -ENOSYS or -EINVAL when those symbols hit the downrev =
kernel? Or were they privately defined in the 4.x series but not =
publicly exported?
>=20
> any chance you can give ell-0.60 a spin and let me know if this helps. =
The only thing we left out was the RTA_EXPIRES workaround and I need to =
think about this a bit harder on how to work around it.

Marcel,

Thank you for investing time on this. Here are my latest results against =
linux-4.9.212, glibc-2.37, and the Arm GNU Toolchain 12.3.1 against =
ell-0.60:

Expanding "${BuildRoot}/third_party/ell/ell.tar.xz" to "."
Creating ".build/Makefile/${PRODUCT}/arm/gnu-toolchain/12.3.1/release"
Creating =
".build/Makefile/${PRODUCT}/arm/gnu-toolchain/12.3.1/release/Makefile"
configure: creating cache config.cache
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for arm-dey-linux-gnueabi-strip... =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-strip
checking for a race-free mkdir -p... /bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking how to create a pax tar archive... gnutar
checking whether make supports nested variables... (cached) yes
checking whether to enable maintainer-specific portions of Makefiles... =
no
checking for arm-dey-linux-gnueabi-gcc... =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables...=20
checking whether we are cross compiling... yes
checking for suffix of object files... o
checking whether the compiler supports GNU C... yes
checking whether =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc accepts -g... yes
checking for =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc option to enable C11 features... none =
needed
checking whether =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc understands -c and -o together... yes
checking whether make supports the include directive... yes (GNU style)
checking dependency style of =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc... gcc3
checking whether =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc accepts -fPIE... yes
checking whether =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc accepts -fsanitize=3Daddress... yes
checking whether =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc accepts -fsanitize=3Dleak... yes
checking whether =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc accepts -fsanitize=3Dundefined... yes
checking for stdio.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for strings.h... yes
checking for sys/stat.h... yes
checking for sys/types.h... yes
checking for unistd.h... yes
checking whether char is unsigned... yes
checking whether byte ordering is bigendian... no
checking build system type... x86_64-pc-linux-gnu
checking host system type... arm-dey-linux-gnueabi
checking how to print strings... printf
checking for a sed that does not truncate output... /bin/sed
checking for grep that handles long lines and -e... /bin/grep
checking for egrep... /bin/grep -E
checking for fgrep... /bin/grep -F
checking for ld used by =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc... =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/arm=
-none-linux-gnueabihf/bin/ld
checking if the linker =
(${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/ar=
m-none-linux-gnueabihf/bin/ld) is GNU ld... yes
checking for BSD- or MS-compatible name lister (nm)... no
checking for arm-dey-linux-gnueabi-dumpbin... no
checking for arm-dey-linux-gnueabi-link... no
checking for dumpbin... no
checking for link... link -dump
configure: WARNING: using cross tools not prefixed with host triplet
checking the name lister (nm) interface... BSD nm
checking whether ln -s works... yes
checking the maximum length of command line arguments... 1572864
checking how to convert x86_64-pc-linux-gnu file names to =
arm-dey-linux-gnueabi format... func_convert_file_noop
checking how to convert x86_64-pc-linux-gnu file names to toolchain =
format... func_convert_file_noop
checking for =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/arm=
-none-linux-gnueabihf/bin/ld option to reload object files... -r
checking for arm-dey-linux-gnueabi-file... no
checking for file... file
checking for arm-dey-linux-gnueabi-objdump... no
checking for objdump... objdump
checking how to recognize dependent libraries... pass_all
checking for arm-dey-linux-gnueabi-dlltool... no
checking for dlltool... no
checking how to associate runtime and link libraries... printf %s\n
checking for arm-dey-linux-gnueabi-ar... =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-ar
checking for archiver @FILE support... @
checking for arm-dey-linux-gnueabi-strip... (cached) =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-strip
checking for arm-dey-linux-gnueabi-ranlib... =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-ranlib
checking command to parse nm output from =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc object... ok
checking for sysroot... =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/arm=
-none-linux-gnueabihf/libc
checking for a working dd... /bin/dd
checking how to truncate binary pipes... /bin/dd bs=3D4096 count=3D1
checking for arm-dey-linux-gnueabi-mt... no
checking for mt... mt
checking if mt is a manifest tool... no
checking for dlfcn.h... yes
checking for objdir... .libs
checking if =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc supports -fno-rtti -fno-exceptions... no
checking for =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc option to produce PIC... -fPIC -DPIC
checking if =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc PIC flag -fPIC -DPIC works... yes
checking if =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc static flag -static works... yes
checking if =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc supports -c -o file.o... yes
checking if =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc supports -c -o file.o... (cached) yes
checking whether the =
${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/bin=
/arm-none-linux-gnueabihf-gcc linker =
(${SYSROOT}/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-linux-gnueabihf/ar=
m-none-linux-gnueabihf/bin/ld) supports shared libraries... yes
checking whether -lc should be explicitly linked in... no
checking dynamic linker characteristics... GNU/Linux ld.so
checking how to hardcode library paths into programs... immediate
checking whether stripping libraries is possible... yes
checking if libtool supports shared libraries... yes
checking whether to build shared libraries... yes
checking whether to build static libraries... no
checking for _init in -lasan... yes
checking for _init in -llsan... no
checking for _init in -lubsan... yes
checking for explicit_bzero... yes
checking for rawmemchr... yes
checking for signalfd... yes
checking for timerfd_create... yes
checking for epoll_create... yes
checking for linux/types.h... yes
checking for linux/if_alg.h... yes
configure: updating cache config.cache
checking that generated files are newer than configure... done
configure: creating ./config.status
config.status: creating Makefile
config.status: creating ell/ell.pc
config.status: creating config.h
config.status: executing depfiles commands
config.status: executing libtool commands
Processing =
".build/Makefile/${PRODUCT}/arm/gnu-toolchain/12.3.1/release/Makefile"
make[1]: Entering directory =
'${BuildRoot}/third_party/ell/.build/Makefile/${PRODUCT}/arm/gnu-toolchain=
/12.3.1/release'
make --no-print-directory all-am
  CC       tools/certchain-verify.o
  CC       tools/genl-discover.o
  CC       tools/genl-watch.o
  CC       tools/genl-request.o
  CC       tools/gpio.o
  CC       ell/util.lo
  CC       ell/test.lo
  CC       ell/strv.lo
  CC       ell/utf8.lo
  CC       ell/queue.lo
  CC       ell/hashmap.lo
  CC       ell/string.lo
  CC       ell/settings.lo
  CC       ell/main.lo
  CC       ell/idle.lo
  CC       ell/signal.lo
  CC       ell/timeout.lo
  CC       ell/io.lo
  CC       ell/log.lo
  CC       ell/ringbuf.lo
  CC       ell/checksum.lo
  CC       ell/netlink.lo
  CC       ell/genl.lo
  CC       ell/rtnl.lo
  CC       ell/dbus.lo
${BuildRoot}/third_party/ell/ell-0.60/ell/netlink.c: In function =
'netlink_parse_ext_ack_error':
${BuildRoot}/third_party/ell/ell-0.60/ell/netlink.c:649:36: error: =
'NLM_F_ACK_TLVS' undeclared (first use in this function); did you mean =
'NLM_F_ACK'?
  649 |         if (!(nlmsg->nlmsg_flags & NLM_F_ACK_TLVS))
      |                                    ^~~~~~~~~~~~~~
      |                                    NLM_F_ACK
${BuildRoot}/third_party/ell/ell-0.60/ell/netlink.c:649:36: note: each =
undeclared identifier is reported only once for each function it appears =
in
${BuildRoot}/third_party/ell/ell-0.60/ell/netlink.c:657:36: error: =
'NLM_F_CAPPED' undeclared (first use in this function); did you mean =
'NLM_F_APPEND'?
  657 |         if (!(nlmsg->nlmsg_flags & NLM_F_CAPPED))
      |                                    ^~~~~~~~~~~~
      |                                    NLM_F_APPEND
make[2]: *** [Makefile:2026: ell/netlink.lo] Error 1
make[2]: *** Waiting for unfinished jobs....
make[1]: *** [Makefile:1296: all] Error 2
make[1]: Leaving directory =
'${BuildRoot}/third_party/ell/.build/Makefile/${PRODUCT}/arm/gnu-toolchain=
/12.3.1/release'
make: *** [Makefile:94: build] Error 2

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
http://www.nuovations.com/

