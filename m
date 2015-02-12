Content-Type: multipart/mixed; boundary="===============6031290161572616674=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH v2 0/3] Add DBus disconnect watch support
Date: Thu, 12 Feb 2015 13:48:50 +0200
Message-ID: <1423741733-26743-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6031290161572616674==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

v2:
- moved the code to dbus.c
- reworked the logic in the caller of the watcher so no need to
  remove l_dbus_register() and l_dbus_unregister()

this set allows user to monitor the disconnect status
of a service.

Cheers,
Jukka


Jukka Rissanen (3):
  dbus: Add AddMatch and RemoveMatch support
  dbus: Add disconnect watch support
  unit: dbus: Add test for disconnect watch API

 Makefile.am            |   3 +
 ell/dbus.c             | 253 ++++++++++++++++++++++++++++++++
 ell/dbus.h             |  19 +++
 unit/test-dbus-watch.c | 388 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 4 files changed, 663 insertions(+)
 create mode 100644 unit/test-dbus-watch.c

-- =

2.1.0


--===============6031290161572616674==--

