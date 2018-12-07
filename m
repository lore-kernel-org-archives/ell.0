Content-Type: multipart/mixed; boundary="===============5290553355736205466=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH 0/2] Fix strict strncpy compiler warnings when building in
 BlueZ
Date: Fri, 07 Dec 2018 10:37:08 -0800
Message-ID: <20181207183710.20822-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5290553355736205466==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Fixes two new strict compiler warnings in bluez for strncpy

Brian Gix (2):
  dbus: fix strict compiler warnings for strncpy
  log: Fix strict compiler warning for strncpy

 ell/dbus.c | 4 ++--
 ell/log.c  | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

-- =

2.17.2


--===============5290553355736205466==--

