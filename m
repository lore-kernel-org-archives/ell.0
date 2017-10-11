Content-Type: multipart/mixed; boundary="===============5052668658458977354=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/2] genl: Make iovec parameter const
Date: Wed, 11 Oct 2017 15:12:37 -0700
Message-ID: <20171011221239.8656-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5052668658458977354==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This set of patches makes the iovec parameter of
l_genl_msg_append_attrv() function const since it isn't modified by
that function.  This allows a pointer to a const struct iovec to be
passed as an argument without casting away the const.  Of course, a
pointer to a non-const iovec may still be passed without a cast as
well.  A new unit test for l_genl_msg_append_attrv() is also added.


Ossama Othman (2):
  genl: Make iovec parameter const
  unit: Added test for l_genl_msg_append_attrv()

 ell/genl.c           |  3 ++-
 ell/genl.h           |  2 +-
 unit/test-genl-msg.c | 47 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+), 2 deletions(-)

-- =

2.11.0


--===============5052668658458977354==--

