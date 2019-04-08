Content-Type: multipart/mixed; boundary="===============4319011913808781428=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/2] Fix unit tests under Clang build.
Date: Mon, 08 Apr 2019 13:12:33 -0700
Message-ID: <20190408201235.10846-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4319011913808781428==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patch set addresses unit test build warnings and a segmentation
fault when ELL is built with the Clang C compiler.

Ossama Othman (2):
  unit: Remove unnecessary NULL pointer checks.
  unit: Fixed a test-dbus-message seg fault.

 unit/test-dbus-message.c | 2 +-
 unit/test-dhcp.c         | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

-- =

2.17.1


--===============4319011913808781428==--

