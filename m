Content-Type: multipart/mixed; boundary="===============3660276975576955662=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 0/2] Import rntlutil from iwd
Date: Fri, 14 Feb 2020 17:33:26 +0100
Message-ID: <20200214163328.17647-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3660276975576955662==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This just copies over the code from iwd. No changes there except the
prefix of the functions name.

Unfortunatly, the unit test can only test the get/dump function
because the setters need root permissions. For this we need some sort
of sandbox. Does anyone have any ideas for this?

While writing the test case I noticed some inconsistency in the naming
sceme:

The IPv6 functions are consistent in the naming sceme, always
append ipv6 after the first name:

  rtnl_ifaddr_ipv6_extract
  rtnl_ifaddr_ipv6_get
  rtnl_ifaddr_ipv6_add
  rtnl_ifaddr_ipv6_delete

  rtnl_route_ipv6_add_gateway
  rtnl_route_ipv6_delete_gateway


For the IPv4 functions it's either a plain 'ifaddr' infix or somewhere ipv4
in the name:


  rtnl_ifaddr_extract
  rtnl_ifaddr_get
  rtnl_ifaddr_add
  rtnl_ifaddr_delete

  rtnl_route_extract_ipv4
  rtnl_route_dump_ipv4

  -> drop ipv4?

  rtnl_route_ipv4_add_connected
  rtnl_route_ipv4_add_gateway

  -> drop ipv4?


And there are the setters:

  rtnl_set_linkmode_and_operstate
  rtnl_set_mac
  rtnl_set_powered


Is this the standard naming sceme?

Thanks,
Daniel

Daniel Wagner (2):
  rtnl: Add initial rtnl support
  unit: Add l_rtnl_* unit tests

 .gitignore       |   1 +
 Makefile.am      |   5 +
 ell/ell.h        |   1 +
 ell/rtnl.c       | 641 +++++++++++++++++++++++++++++++++++++++++++++++
 ell/rtnl.h       | 119 +++++++++
 unit/test-rtnl.c | 236 +++++++++++++++++
 6 files changed, 1003 insertions(+)
 create mode 100644 ell/rtnl.c
 create mode 100644 ell/rtnl.h
 create mode 100644 unit/test-rtnl.c

-- =

2.25.0
--===============3660276975576955662==--

