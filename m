Content-Type: multipart/mixed; boundary="===============3862739651115360625=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/5] Support C89 ELL builds
Date: Mon, 04 Mar 2019 10:42:54 -0800
Message-ID: <20190304184259.22809-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3862739651115360625==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patch set provides several simple changes to enable C89 support
in ELL.

Ossama Othman (5):
  ell: Use __inline__ instead of inline for C89.
  ell: Do not use C99 '//' single line comment.
  settings: Explicitly enable strto{u}ll() for C89.
  string: Use __va_copy() for pre-C99 builds.
  unit: Remove C99 loop variable declaration.

 ell/asn1-private.h       | 4 ++++
 ell/dbus.c               | 2 +-
 ell/netlink.c            | 2 +-
 ell/settings.c           | 4 ++++
 ell/string.c             | 4 ++++
 ell/utf8.h               | 4 ++++
 ell/util.h               | 4 ++++
 unit/test-dbus-message.c | 3 ++-
 8 files changed, 24 insertions(+), 3 deletions(-)

-- =

2.17.1


--===============3862739651115360625==--

