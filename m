Content-Type: multipart/mixed; boundary="===============4174851583862224407=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v3 0/4] Add DBus disconnect watch support
Date: Wed, 18 Feb 2015 18:08:32 +0200
Message-ID: <1424275716-7198-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4174851583862224407==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

v3:
- reworked the unit test

v2:
- moved the code to dbus.c
- reworked the logic in the caller of the watcher so no need to
  remove l_dbus_register() and l_dbus_unregister()

this set allows user to monitor the disconnect status
of a service.

Cheers,
Jukka


Jukka Rissanen (4):
  dbus: Add AddMatch and RemoveMatch support
  gvariant: dbus.h need to be included before private header
  dbus: Add disconnect watch support
  unit: dbus: Add test for disconnect watch API

 Makefile.am            |   3 +
 ell/dbus-private.h     |  35 ++++++++
 ell/dbus.c             | 221 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.h             |   9 ++
 ell/gvariant-util.c    |   2 +-
 unit/test-dbus-watch.c | 153 ++++++++++++++++++++++++++++++++++
 6 files changed, 422 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-dbus-watch.c

-- =

2.1.0


--===============4174851583862224407==--

