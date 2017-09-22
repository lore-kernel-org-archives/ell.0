Content-Type: multipart/mixed; boundary="===============2442734867342052507=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH 0/4] Static analysis fixes
Date: Fri, 22 Sep 2017 15:12:40 -0700
Message-ID: <20170922221244.12670-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2442734867342052507==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The asn1 fix is straightforward.

I'm not sure Denis likes strlcpy any more than strncpy, but given that
strncpy was being misused within ELL and a strlcpy is seen as a
preferred option in some circles, I added l_strlcpy to our utils.

Mat Martineau (4):
  asn1: Call va_end() before every return
  util: Add l_strlcpy
  unit: Add l_strlcpy tests
  genl: Fix termination of name strings

 ell/asn1-private.h |  4 +++-
 ell/genl.c         |  6 +++---
 ell/util.c         | 32 ++++++++++++++++++++++++++++++++
 ell/util.h         |  2 ++
 unit/test-util.c   | 41 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 81 insertions(+), 4 deletions(-)

-- =

2.14.1


--===============2442734867342052507==--

