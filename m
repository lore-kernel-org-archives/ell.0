Content-Type: multipart/mixed; boundary="===============2950393115127088217=="
MIME-Version: 1.0
From: Szymon Janc <szymon.janc@codecoup.pl>
Subject: [PATCH 0/6] D-Bus client and proxy API
Date: Fri, 01 Dec 2017 16:06:04 +0100
Message-ID: <20171201150610.9696-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2950393115127088217==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

This set adds initial version of D-Bus client and proxy APIs.
With this is it possible to connect to specified service, monitor
proxies being added/removed, set/get properties and call methods
on specific proxy.

First 2 patches are some extensions to message API that were needed for
client code.

This is tested against BlueZ D-Bus API and seems to work fine within
my (simple) application.

Changes since RFC:
 - addressed comments from Denis
 - proxy is now obtained only from added callback - this may be
   extended in future if needed
 - no more proxy ref counting as it is valid from add to remove callback
 - pending set properties and method calls are cancelled on proxy removal
 - added simple API usage example to examples/dbus-client.c

Comments are welcome.

Szymon Janc (6):
  dbus: Add l_dbus_message_builder_append_from_valist
  dbus: Use l_dbus_message_builder_append_from_valist in
    append_arguments
  dbus: Add support for proxy interface
  dbus: Add support for setting properties on D-Bus proxy interface
  dbus: Add convenient API for calling method on proxy interface
  examples: Extend dbus-client example

 Makefile.am            |   2 +
 ell/dbus-client.c      | 714 +++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/dbus-client.h      |  98 +++++++
 ell/dbus-message.c     | 461 +++++++++++++++----------------
 ell/dbus.h             |   4 +
 ell/ell.h              |   1 +
 examples/dbus-client.c |  93 ++++++-
 7 files changed, 1138 insertions(+), 235 deletions(-)
 create mode 100644 ell/dbus-client.c
 create mode 100644 ell/dbus-client.h

-- =

2.14.3


--===============2950393115127088217==--

