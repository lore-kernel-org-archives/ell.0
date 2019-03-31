Content-Type: multipart/mixed; boundary="===============6124131892264198203=="
MIME-Version: 1.0
From: Ramon Henrique <rhpr@cesar.org.br>
Subject: [PATCH 0/2] Allow connection to a tcp dbus address
Date: Sun, 31 Mar 2019 11:00:40 -0300
Message-ID: <20190331140042.6798-1-rhpr@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6124131892264198203==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patch came from a demand in a project with industrial IoT for
monitoring a PLC (creating supervisor apps). The infrastructure was
built from a DBus service that can be accessed by a front-end in the
same local network.

Ramon Ribeiro (2):
  dbus: Add support to tcp address
  unit: dbus: Add unit test to dbus tcp address

 .gitignore           |   1 +
 Makefile.am          |   3 +
 ell/dbus.c           |  95 ++++++++++++++++++-
 unit/dbus.conf       |   2 +
 unit/test-dbus-tcp.c | 261 +++++++++++++++++++++++++++++++++++++++++++++++=
++++
 5 files changed, 358 insertions(+), 4 deletions(-)
 create mode 100644 unit/test-dbus-tcp.c

-- =

2.11.0


--===============6124131892264198203==--

