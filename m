Content-Type: multipart/mixed; boundary="===============7727632198047920568=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@gmail.com>
Subject: [PATCH 0/2] C++ syntax error fixes
Date: Mon, 09 Nov 2020 16:57:56 -0800
Message-ID: <20201110005758.55338-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7727632198047920568==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This set of changes addresses compile-time problems encountered when
including <ell/ell.h> in C++ code.  The errors may be reproduced from
the top-level ELL source directory with g++ like so:

    g++ -I. -fsyntax-only ell/ell.h

Ossama Othman (2):
  util: Fix C++ invalid pointer conversion
  ell: Do not use C99 static array index in C++

 ell/icmp6.h | 4 ++++
 ell/rtnl.h  | 4 ++++
 ell/util.h  | 4 ++--
 3 files changed, 10 insertions(+), 2 deletions(-)

-- =

2.25.1

--===============7727632198047920568==--

