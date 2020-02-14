Content-Type: multipart/mixed; boundary="===============2598003247079464644=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 0/2] rtnl cleanups
Date: Fri, 14 Feb 2020 19:23:35 +0100
Message-ID: <20200214182337.11132-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2598003247079464644==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

As discussed on IRC here are the API changes.

Daniel Wagner (2):
  rtnl: Make IPv4 and IPv6 naming scheme consistent
  rtnl: Rename l_rtnl_ifaddr{4|6|}_get to l_rntl_ifaddr{4|6}_dump

 ell/rtnl.c       | 52 ++++++++++++++++++++++++------------------------
 ell/rtnl.h       | 28 +++++++++++++-------------
 unit/test-rtnl.c | 42 +++++++++++++++++++-------------------
 3 files changed, 61 insertions(+), 61 deletions(-)

-- =

2.25.0
--===============2598003247079464644==--

