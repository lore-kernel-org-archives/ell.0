Content-Type: multipart/mixed; boundary="===============1977589978047102625=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 0/2] Introduce l_memdup function
Date: Fri, 16 Jan 2015 11:13:50 +0200
Message-ID: <1421399632-19544-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1977589978047102625==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

this patch introduces new l_memdup() function in patch 1.

The new function is then used in patch 2. The genl.c was the only
place in the code base where such a change could be done (at least I
could not spot any other place having malloc+memcpy in the code after
quick review).

Cheers,
Jukka

Jukka Rissanen (2):
  util: Add l_memdup function for allocation and copying a memory buffer
  genl: Convert l_malloc + memcpy to use l_memdup

 ell/genl.c |  4 +---
 ell/util.c | 23 +++++++++++++++++++++++
 ell/util.h |  2 ++
 3 files changed, 26 insertions(+), 3 deletions(-)

-- =

1.8.3.1


--===============1977589978047102625==--

