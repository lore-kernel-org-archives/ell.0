Content-Type: multipart/mixed; boundary="===============5981069141461185606=="
MIME-Version: 1.0
From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH 0/3] rtnl: add missing APIs
Date: Fri, 14 Feb 2020 19:52:50 +0100
Message-ID: <20200214185253.32658-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5981069141461185606==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The first two patches make the API for both protocol version
complete. The last patch adds the table, priority and preference to
the extract functions, which is a very uselful information.

This series is based on the cleanup series send before.

Daniel Wagner (3):
  rtnl: Add l_rtnl_route6_dump() and l_rtnl_route6_extract()
  unit: Add unit test for l_rtnl_route6_{dump|extract}
  rtnl: Extract table, priority and pref

 ell/rtnl.c       | 130 ++++++++++++++++++++++++++++++++---------------
 ell/rtnl.h       |  10 +++-
 unit/test-rtnl.c |  42 +++++++++++++--
 3 files changed, 137 insertions(+), 45 deletions(-)

-- =

2.25.0
--===============5981069141461185606==--

