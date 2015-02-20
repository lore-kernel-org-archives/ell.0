Content-Type: multipart/mixed; boundary="===============5743052254258549092=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v4 0/6] Add DBus disconnect watch support
Date: Fri, 20 Feb 2015 14:16:35 +0200
Message-ID: <1424434601-2211-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5743052254258549092==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

v4:
- minor tweaking here and there
- filter rule and corresponding unit test in a separate patch

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


Jukka Rissanen (6):
  dbus: Add AddMatch and RemoveMatch support
  gvariant: dbus.h need to be included before private header
  dbus: Add filter rule creator
  unit: dbus: Add test for filter rule
  dbus: Add disconnect watch support
  unit: dbus: Add test for disconnect watch API

 Makefile.am            |   3 +
 ell/dbus-private.h     |  19 +++++
 ell/dbus.c             | 217 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus.h             |   9 ++
 ell/gvariant-util.c    |   2 +-
 unit/test-dbus-watch.c | 166 +++++++++++++++++++++++++++++++++++++
 6 files changed, 415 insertions(+), 1 deletion(-)
 create mode 100644 unit/test-dbus-watch.c

-- =

2.1.0


--===============5743052254258549092==--

