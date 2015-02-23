Content-Type: multipart/mixed; boundary="===============3982716547608360415=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v5 0/4] Add DBus disconnect watch support
Date: Mon, 23 Feb 2015 13:54:56 +0200
Message-ID: <1424692500-21681-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3982716547608360415==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

v5:
- rebased the set
- fixed filter rule testing and added more tests there

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


Jukka Rissanen (4):
  unit: dbus: Add test for filter rule
  dbus: Add AddMatch and RemoveMatch support
  dbus: Add disconnect watch support
  unit: dbus: Add test for disconnect watch API

 Makefile.am            |   3 +
 ell/dbus-private.h     |   3 +
 ell/dbus.c             | 134 +++++++++++++++++++++++++
 ell/dbus.h             |   7 ++
 unit/test-dbus-watch.c | 268 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 5 files changed, 415 insertions(+)
 create mode 100644 unit/test-dbus-watch.c

-- =

2.1.0


--===============3982716547608360415==--

