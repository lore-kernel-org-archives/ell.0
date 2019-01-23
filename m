Content-Type: multipart/mixed; boundary="===============8735722637101017268=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/2] Correct ELL header errors included C++ code.
Date: Wed, 23 Jan 2019 11:06:08 -0800
Message-ID: <20190123190610.3787-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8735722637101017268==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Including <ell/ell.h> in C++ code revealed a few C++ related conflicts
in <ell/key.h>.  These patches address those errors, and add a simple
C++ build test that enabled if a C++ compiler is found when maintainer
mode is enabled.

Ossama Othman (2):
  key: Avoid using C++ keywords as param names.
  unit: Added a minimal C++ build test.

 .gitignore              |  1 +
 Makefile.am             |  6 ++++++
 configure.ac            |  3 +++
 ell/key.h               |  6 +++---
 unit/test-cxx-build.cpp | 42 +++++++++++++++++++++++++++++++++++++++++
 5 files changed, 55 insertions(+), 3 deletions(-)
 create mode 100644 unit/test-cxx-build.cpp

-- =

2.17.1


--===============8735722637101017268==--

