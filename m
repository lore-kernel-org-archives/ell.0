Content-Type: multipart/mixed; boundary="===============3631611237041080372=="
MIME-Version: 1.0
From: Ramon Ribeiro <rhpr@cesar.org.br>
Subject: [PATCH v1 0/2] Allow connection to a tcp dbus address
Date: Mon, 15 Apr 2019 09:23:25 -0300
Message-ID: <1555331007-26977-1-git-send-email-rhpr@cesar.org.br>
In-Reply-To: <20190331140042.6798-1-rhpr@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3631611237041080372==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patch came from a demand in a project with industrial IoT for
monitoring a PLC (creating supervisor apps). The infrastructure was
built from a DBus service that can be accessed by a front-end in the
same local network.

Changes from v0 to v1:
 - Changes from atoi to strtoul
 - Handle port of zero as invalid
 - Use syscall `select` to avoid a blocking connect

Note: Maybe there is another approach using struct l_io and the
callback l_io_write but I'm not sure if that is enough, due TCP
connection timeout.

Ramon Ribeiro (2):
  dbus: Add support to tcp address
  unit: dbus: Add unit test to dbus tcp address

 .gitignore           |   1 +
 Makefile.am          |   3 +
 ell/dbus.c           | 151 ++++++++++++++++++++++++++++-
 unit/dbus.conf       |   2 +
 unit/test-dbus-tcp.c | 261 +++++++++++++++++++++++++++++++++++++++++++++++=
++++
 5 files changed, 413 insertions(+), 5 deletions(-)
 create mode 100644 unit/test-dbus-tcp.c

-- =

2.7.4


--===============3631611237041080372==--

