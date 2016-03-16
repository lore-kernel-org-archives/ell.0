Content-Type: multipart/mixed; boundary="===============4651103879191732893=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v2 0/3] Sanitizers and race test/fix
Date: Wed, 16 Mar 2016 13:00:33 -0700
Message-ID: <1458158433-16513-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4651103879191732893==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

v2: Fix whitespace in patch 2/3.

Mat Martineau (3):
  build: Add sanitizer options
  unit: Add race condition test to test-main
  main: Safely free watch_data structures

 acinclude.m4     | 36 ++++++++++++++++++++++++++++++++++++
 configure.ac     | 45 +++++++++++++++++++++++++++++++++++++++++++++
 ell/main.c       | 28 +++++++++++++++++++++++++++-
 unit/test-main.c | 35 +++++++++++++++++++++++++++++++----
 4 files changed, 139 insertions(+), 5 deletions(-)

-- =

2.7.3


--===============4651103879191732893==--

