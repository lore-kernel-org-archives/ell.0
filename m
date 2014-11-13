Content-Type: multipart/mixed; boundary="===============6226313434954861962=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [RFC/PATCH 00/21] Add support for the org.freedesktop.DBus.Properties
 interface
Date: Thu, 13 Nov 2014 12:36:04 +0200
Message-ID: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6226313434954861962==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hello guys,

In order to get ell ready for ObjectManager support, I started to work on t=
he
very first necessary feature: the org.freedesktop.DBus.Properties interface.

I wanted to go with an API that we all know already, which has proven to be
easy to use, which works well and so on: the GDBus API. The other big reason
is that if we have to move from GDBus to ell, it would take a very little
amount of time to do it since it would be a tiny naming issue and that's it.
No logic rework at all. I know this will help a lot when moving our projects
from GDBus to ell.

There is already a dbus service API in ell. I wanted to keep it, wrapping t=
he
gdbus-like API within the existing functions. However that has proven to be
impossible unless I would modify the existing API. Thus my conclusion: if I
have to break the existing API, let's do it all. So I finnally got rid of t=
he
existing API.

That said, I kept the internals as much as they are. There are actually nice
improvements in it compared to GDBus. All objects hold only their subpath, =
and
not the whole path every time, interface instances reduce the memory usage =
(one
interface might be used in 1+ instances), etc...

I also kept the current unit tests, adding module test for this new interfa=
ce.
(it really runs on top of DBus, so it's not a unit test anymore). Tried it =
with
valgrind, which went well.

I am sending it as an RFC/PATCH, since I would like to get your inputs on s=
ome
parts. Like the struct _dbus_pending_data for instance, used to answer a Se=
t()
method call and/or when sending a PropertiesChanged() signal. I tried not to
bloat it, but there are information like the whole patch which is required.
About that one: is it better to do what I did, or to hold a pointer on the
object and recreate the path from it? I went for the quick and easy one,
storing the whole path: after all such pending data are not there for long.=
 But
if you think recreating the path is not a bad idea to keep a bit of memory,=
 I
can change it.

Also, patch 4, due to the port of the constants structure, it looses the
pre-built signature, thus adding the necessity to add a compare_signature()
function as in GDBus. It was nice to get this full pre-built signature that
could be compared at once. If you have ideas how to get it without changing=
 the
API... Like changing the macro L_DBUS_ARGS() or L_DBUS_METHOD, so it would =
set
a const char * in_signature/out_signature in struct l_dbus_method for insta=
nce?

About other improvements:
- patch 1 is a tiny helper I required in patch 15, since ell checks the
  signature of the variant we try to set, before calling the set function.
- patch 2 and 3 are there to separate the code properly. It hads thus a get=
ter
  function for the object tree, but there is no shared structure informatio=
ns
  between dbus.c and dbus-service.c. I figured out it was cleaner that way =
imo.

Minor issues:
- I put the error message macros in dbus-private.h, figuring that some other
  part of the code could need it. But maybe it's better no to share those?

- When it's required to send an empty reply, it would be good to have a hel=
per
  function I think, which wraps l_dbus_message_new_method_return() +
  l_dbus_message_set_arguments + l_dbus_send together (see patch 15 in
  function l_dbus_pending_property_success).

Next:
- Finally implementing ObjectManager interface, with the 2 functions that
  enable/disable it as in GDBus.
- We really need to implement DBus signal watch/filters in ell
- That last task done, we could provide a nice client proxy API as GDBus
  does as well.

Tomasz Bursztyka (21):
  dbus: Add a utility function to check an message iter signature
  dbus: Add a private getter for the unique dbus tree in dbus struct
  dbus: All interface related code is found in dbus-service.c
  dbus: Refactor the interface API so it uses constants methods array
  unit: Apply the DBus interface methods API change to the tests
  examples: Apply the DBus interface methods API change
  dbus: Refactor the interface API so it uses constant signals array
  unit: Apply the DBus interface signals API change to the tests
  examples: Apply the DBus interface signals API change
  dbus: Refactor the interface API so it uses constant properties array
  unit: Apply the DBus interface properties API change to the tests
  examples: Apply the DBus interface properties API change
  dbus: Add support for org.freedesktop.DBus.Properties.Get method
  dbus: Add support for org.freedesktop.DBus.Properties.GetAll method
  dbus: Add support for org.freedesktop.DBus.Properties.Set method
  dbus: Add support for checking if a property exists
  unit: Apply the changes related to interface property API
  examples: Apply the changes related to interface property API
  dbus: Add org.freedesktop.DBus.Properties.PropertiesChanged signal
  unit: Add a test for the org.freedesktop.DBus.Properties interface
  git: Ignoring the org.freedesktop.DBus.Properties interface test
    binary

 .gitignore                   |   1 +
 Makefile.am                  |   3 +
 ell/dbus-message.c           |  13 +
 ell/dbus-private.h           |  48 ++-
 ell/dbus-service.c           | 999 +++++++++++++++++++++++++++++----------=
----
 ell/dbus-service.h           | 158 ++++++-
 ell/dbus.c                   |  29 +-
 ell/dbus.h                   |  11 +-
 examples/dbus-service.c      |  43 +-
 unit/test-dbus-freedesktop.c | 347 +++++++++++++++
 unit/test-dbus-service.c     |  80 ++--
 unit/test-kdbus.c            |  13 +-
 12 files changed, 1302 insertions(+), 443 deletions(-)
 create mode 100644 unit/test-dbus-freedesktop.c

-- =

2.0.4


--===============6226313434954861962==--

