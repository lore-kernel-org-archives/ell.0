Content-Type: multipart/mixed; boundary="===============1506747391346830594=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/2] Correct l_uintset_isempty() logic
Date: Mon, 16 Sep 2019 13:36:08 -0700
Message-ID: <20190916203610.19722-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1506747391346830594==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The loop iteration over the 'bits' array in l_uintset_isempty()
exceeded the maximum offset for the given l_uintset, resulting in
out-of-bounds bits being considered for emptiness.  Add a test that
demonstrates the problem, and correct the maximum offset when
iterating over the l_uintset 'bits' field.

Ossama Othman (2):
  unit: Add l_uintset_isempty() test
  uintset: Do not exceed max offset in empty check

 ell/uintset.c       |  5 ++++-
 unit/test-uintset.c | 17 +++++++++++++++++
 2 files changed, 21 insertions(+), 1 deletion(-)

-- =

2.20.1


--===============1506747391346830594==--

