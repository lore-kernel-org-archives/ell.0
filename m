Content-Type: multipart/mixed; boundary="===============0667504920463695852=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 0/3] Add DBus disconnect watch support
Date: Tue, 10 Feb 2015 17:46:44 +0200
Message-ID: <1423583207-22917-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0667504920463695852==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

this set allows user to monitor the disconnect status
of a service.

Cheers,
Jukka

Jukka Rissanen (3):
  dbus: Add AddMatch and RemoveMatch support
  dbus: Add disconnect watch support
  unit: dbus: Add test for disconnect watch API

 Makefile.am            |   4 +
 ell/dbus-watch.c       | 267 ++++++++++++++++++++++++++++++++++
 ell/dbus.c             |  26 ++++
 ell/dbus.h             |  21 +++
 unit/test-dbus-watch.c | 388 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 5 files changed, 706 insertions(+)
 create mode 100644 ell/dbus-watch.c
 create mode 100644 unit/test-dbus-watch.c

-- =

1.8.3.1


--===============0667504920463695852==--

