Received: from mohas.pair.com (mohas.pair.com [209.68.5.112])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 89511374D5
	for <ell@lists.linux.dev>; Wed,  8 Nov 2023 21:21:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; dkim=none
Received: from mohas.pair.com (localhost [127.0.0.1])
	by mohas.pair.com (Postfix) with ESMTP id 3D5AD731ED;
	Wed,  8 Nov 2023 16:21:32 -0500 (EST)
Received: from [IPv6:2601:647:5a00:15c1:ec32:172b:4c97:6a74] (unknown [IPv6:2601:647:5a00:15c1:ec32:172b:4c97:6a74])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mohas.pair.com (Postfix) with ESMTPSA id B9924732BF;
	Wed,  8 Nov 2023 16:21:31 -0500 (EST)
From: Grant Erickson <gerickson@nuovations.com>
Content-Type: text/plain;
	charset=utf-8
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 13.4 \(3608.120.23.2.4\))
Subject: ELL 0.59 Does Not Compile against Linux-4.9.212 and/or GLibC-2.28
Message-Id: <EE577BA9-358B-44E1-BC6E-810EBFA4998F@nuovations.com>
Date: Wed, 8 Nov 2023 13:21:30 -0800
Cc: Marcel Holtmann <marcel@holtmann.org>,
 Denis Kenzior <denkenz@gmail.com>
To: ell@lists.linux.dev
X-Mailer: Apple Mail (2.3608.120.23.2.4)
X-Scanned-By: mailmunge 3.11 on 209.68.5.112

ELL Community:

Over on the connman mailing list, Marcel and Denis have been advocating, =
rightly so, for iwd over wpa_supplicant for Wi-Fi.

Is there a kernel version expectation of ELL?

For the current project I am engaged on, the kernel is locked at =
linux-4.9.212, glibc-2.28, and GCC 8.2. With that combination, I have =
found that the absolutely latest version of ELL I can build is 0.28. =
Regrettably, iwd requires a more recent version than that. However, =
neither the version of ELL that iwd embeds nor the latest independent =
version of ELL, 0.59 compile against the aforementioned combination. I =
see the following errors:

    Processing =
".build/Makefile/${PRODUCT}/arm/gnu-toolchain/8.2-2018.11/release/Makefile=
"
    make[1]: Entering directory =
'third_party/ell/.build/Makefile/${PRODUCT}/arm/gnu-toolchain/8.2-2018.11/=
release'
    make --no-print-directory all-am
      CC       ell/netlink.lo
      CC       ell/genl.lo
      CC       ell/dbus.lo
      CC       ell/rtnl.lo
    In file included from third_party/ell/ell-0.59/ell/rtnl.c:13:
    =
${BuildRoot}/results/${PRODUCT}/arm/gnu-toolchain/8.2-2018.11/release/thir=
d_party/linux/linux-dey/include/linux/if.h:234:19: error: field =
'ifru_addr' has incomplete type
       struct sockaddr ifru_addr;
                       ^~~~~~~~~
    =
${BuildRoot}/results/${PRODUCT}/arm/gnu-toolchain/8.2-2018.11/release/thir=
d_party/linux/linux-dey/include/linux/if.h:235:19: error: field =
'ifru_dstaddr' has incomplete type
       struct sockaddr ifru_dstaddr;
                       ^~~~~~~~~~~~
    =
${BuildRoot}/results/${PRODUCT}/arm/gnu-toolchain/8.2-2018.11/release/thir=
d_party/linux/linux-dey/include/linux/if.h:236:19: error: field =
'ifru_broadaddr' has incomplete type
       struct sockaddr ifru_broadaddr;
                       ^~~~~~~~~~~~~~
    =
${BuildRoot}/results/${PRODUCT}/arm/gnu-toolchain/8.2-2018.11/release/thir=
d_party/linux/linux-dey/include/linux/if.h:237:19: error: field =
'ifru_netmask' has incomplete type
       struct sockaddr ifru_netmask;
                       ^~~~~~~~~~~~
    =
${BuildRoot}/results/${PRODUCT}/arm/gnu-toolchain/8.2-2018.11/release/thir=
d_party/linux/linux-dey/include/linux/if.h:238:20: error: field =
'ifru_hwaddr' has incomplete type
       struct  sockaddr ifru_hwaddr;
                        ^~~~~~~~~~~
    third_party/ell/ell-0.59/ell/netlink.c: In function =
'l_netlink_set_debug':
    third_party/ell/ell-0.59/ell/netlink.c:629:56: error: =
'NETLINK_EXT_ACK' undeclared (first use in this function); did you mean =
'NETLINK_CAP_ACK'?
      if (setsockopt(l_io_get_fd(netlink->io), SOL_NETLINK, =
NETLINK_EXT_ACK,
                                                            =
^~~~~~~~~~~~~~~
                                                            =
NETLINK_CAP_ACK
    third_party/ell/ell-0.59/ell/netlink.c:629:56: note: each undeclared =
identifier is reported only once for each function it appears in
    third_party/ell/ell-0.59/ell/netlink.c: In function =
'netlink_parse_ext_ack_error':
    third_party/ell/ell-0.59/ell/netlink.c:649:29: error: =
'NLM_F_ACK_TLVS' undeclared (first use in this function); did you mean =
'NLM_F_ACK'?
      if (!(nlmsg->nlmsg_flags & NLM_F_ACK_TLVS))
                                 ^~~~~~~~~~~~~~
                                 NLM_F_ACK
    third_party/ell/ell-0.59/ell/netlink.c:657:29: error: 'NLM_F_CAPPED' =
undeclared (first use in this function); did you mean 'NLM_F_APPEND'?
      if (!(nlmsg->nlmsg_flags & NLM_F_CAPPED))
                                 ^~~~~~~~~~~~
                                 NLM_F_APPEND
    third_party/ell/ell-0.59/ell/netlink.c:677:8: error: =
'NLMSGERR_ATTR_MSG' undeclared (first use in this function)
       case NLMSGERR_ATTR_MSG:
            ^~~~~~~~~~~~~~~~~
    third_party/ell/ell-0.59/ell/genl.c: In function 'l_genl_new':
    third_party/ell/ell-0.59/ell/netlink.c:681:8: error: =
'NLMSGERR_ATTR_OFFS' undeclared (first use in this function)
       case NLMSGERR_ATTR_OFFS:
            ^~~~~~~~~~~~~~~~~~
    third_party/ell/ell-0.59/ell/genl.c:1088:30: error: =
'NETLINK_EXT_ACK' undeclared (first use in this function); did you mean =
'NETLINK_CAP_ACK'?
      setsockopt(fd, SOL_NETLINK, NETLINK_EXT_ACK,
                                  ^~~~~~~~~~~~~~~
                                  NETLINK_CAP_ACK
    third_party/ell/ell-0.59/ell/genl.c:1088:30: note: each undeclared =
identifier is reported only once for each function it appears in
    make[2]: *** [Makefile:2009: ell/netlink.lo] Error 1
    make[2]: *** Waiting for unfinished jobs....
    make[2]: *** [Makefile:2009: ell/genl.lo] Error 1
    make[2]: *** [Makefile:2009: ell/rtnl.lo] Error 1
    make[1]: *** [Makefile:1288: all] Error 2
    make[1]: Leaving directory =
'third_party/ell/.build/Makefile/${PRODUCT}/arm/gnu-toolchain/8.2-2018.11/=
release'
    make: *** [Makefile:94: build] Error 2

I expect the =E2=80=99sockaddr=E2=80=99 issues to be easily resolved =
with a different set of include directives; however, the rest appear to =
be new symbols introduced in later kernels.

Best,

Grant=
