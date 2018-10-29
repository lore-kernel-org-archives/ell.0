Content-Type: multipart/mixed; boundary="===============0882715238627109875=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/5] C99 related fixes
Date: Mon, 29 Oct 2018 13:07:10 -0700
Message-ID: <20181029200715.28427-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0882715238627109875==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This set of patches addresses some issues related to C library
features that were disabled, or were at least affected, by explicitly
enabling C99 in gcc via the -std=3Dc99 command line option.

ELL itself won't build cleanly when constrained solely to C99.  A
successful build in that case requires defining the appropriate
feature test macro(s) (e.g. _POSIX_SOURCE, _POSIX_C_SOURCE, etc)
either in ELL's config.h header, the build command line, or individual
source files that require the disabled C library feature.


Ossama Othman (5):
  ell: Use __typeof__ instead of typeof in headers.
  settings: Include strings.h for strcasecmp() proto
  dbus-client: Only include required ELL headers.
  ell: Make tls-private.h header self-contained.
  tools: Only include required ELL headers.

 ell/cipher.h             | 1 +
 ell/dbus-client.c        | 4 +++-
 ell/private.h            | 2 +-
 ell/settings.c           | 1 +
 ell/tls-private.h        | 4 ++++
 ell/util.h               | 8 ++++----
 tools/certchain-verify.c | 5 ++++-
 7 files changed, 18 insertions(+), 7 deletions(-)

-- =

2.17.1


--===============0882715238627109875==--

