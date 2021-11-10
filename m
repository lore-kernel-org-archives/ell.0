Content-Type: multipart/mixed; boundary="===============1066206663862352104=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman at gmail.com>
To: ell at lists.01.org
Subject: [PATCH 0/3] rtnl: Fix address conversion buffer overflow.
Date: Tue, 09 Nov 2021 16:14:45 -0800
Message-ID: <20211110001448.175980-1-ossama.othman@intel.com>

--===============1066206663862352104==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Some l_rtnl functions that return a stringified address could
potentially overrun a user supplied buffer of insufficient length.
Add a buffer length argument to prevent ELL from making incorrect
assumptions.  Impacted functions are l_rtnl_address_get_address(),
l_rtnl_route_get_gateway(), and l_rtnl_route_get_prefsrc().

Ossama Othman (3):
  rtnl: Fix address conversion buffer overflow.
  unit: Add l_rtnl_address_get_address() test case.
  Makefile: Bump library 'current' version.

 Makefile.am      |  4 ++--
 ell/rtnl.c       | 28 +++++++++++++++++-----------
 ell/rtnl.h       |  8 +++++---
 unit/test-rtnl.c | 26 ++++++++++++++++++++++++++
 4 files changed, 50 insertions(+), 16 deletions(-)

-- =

2.32.0

--===============1066206663862352104==--

