Content-Type: multipart/mixed; boundary="===============9039868241156222230=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [RFC 0/6] D-Bus client and proxy API
Date: Wed, 29 Nov 2017 16:16:42 +0100
Message-ID: <20171129151648.24749-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9039868241156222230==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

This set adds initial version of D-Bus client and proxy APIs.
With this is it possible to connect to specified service, monitor
proxies being added/removed, set/get properties and call methods
on specific proxy.

First 3 patches are some extensions to message API that were needed for
client code.

This is tested against BlueZ D-Bus API and seems to work fine within
my (simple) application.

Comments are welcome.

Szymon Janc (6):
  dbus: Add l_dbus_message_get_arguments_valist
  dbus: Add l_dbus_message_builder_append_from_valist
  dbus: Use l_dbus_message_builder_append_from_valist in
    append_arguments
  dbus: Add support for proxy interface
  dbus: Add support for setting properties on D-Bus proxy interface
  dbus: Add convenient API for calling method on proxy interface

 Makefile.am        |   2 +
 ell/dbus-client.c  | 732 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus-client.h  | 102 ++++++++
 ell/dbus-message.c | 476 +++++++++++++++++-----------------
 ell/dbus.h         |   6 +
 ell/ell.h          |   1 +
 6 files changed, 1088 insertions(+), 231 deletions(-)
 create mode 100644 ell/dbus-client.c
 create mode 100644 ell/dbus-client.h

-- =

2.14.3


--===============9039868241156222230==--

