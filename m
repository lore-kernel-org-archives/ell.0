Content-Type: multipart/mixed; boundary="===============0742592187379041525=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/2] l_strv_append() test and minor patch
Date: Thu, 14 Feb 2019 12:45:47 -0800
Message-ID: <20190214204549.26138-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0742592187379041525==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The l_strv_append() function needlessly post-incremented an array
index value prior to returning.  Drop the post-increment, and a
l_strv_append() unit test.

Ossama Othman (2):
  unit: Add test for l_strv_append().
  strv: Remove unnecessary post-increment.

 ell/strv.c         |  2 +-
 unit/test-string.c | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

-- =

2.17.1


--===============0742592187379041525==--

