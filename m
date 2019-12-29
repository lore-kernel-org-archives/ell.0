Content-Type: multipart/mixed; boundary="===============3141490394383402372=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Warn-to-error on -Werror=cast-align
Date: Sun, 29 Dec 2019 23:38:58 +0000
Message-ID: <e741508b7df80bb143ceb95d2dd31d70b522a439.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3141490394383402372==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In the BlueZ build, we apparently use stricter Warn to Error checking than =
what is currently set up for ELL.

I got my son a new Raspberry PI, and the first thing he tried to build was =
ELL and BlueZ...  On THAT PATFORM
ONLY, Raspbian (Raspbian 10 (buster)) with kernel 4.19, we get failures bui=
lding ell/dbus.c.  Everything builds
correctly in the ELL tree, using standard bootstrap-configure, however when=
 using -Werror=3Dcast-align, I get the
following (see below) build issues in dbus.c, genl.c, dhcp-transport.c, plu=
s a few unit tests...  In BlueZ
these errors show up with the *default* build procedure:

So my question for Marcel is:  Do we need the alignment check in BlueZ?

And for Denis and Marcel, Do we care if there are alignment warnings in ELL?

Here is a dump of the make output after:

$ export CFLAGS=3D-Werror=3Dcast-align
$ ./bootstrap-configure

pi(a)raspberrypi:~/ell $ make -k
make --no-print-directory all-am
  CC       ell/genl.lo
ell/genl.c: In function =E2=80=98l_genl_attr_next=E2=80=99:
ell/genl.c:1677:5: error: cast increases required alignment of target type =
[-Werror=3Dcast-align]
     (struct nlattr*)(((char*)(nla)) + \
     ^
ell/genl.c:1738:20: note: in expansion of macro =E2=80=98NLA_NEXT=E2=80=99
  attr->next_data =3D NLA_NEXT(nla, attr->next_len);
                    ^~~~~~~~
cc1: all warnings being treated as errors
make[1]: *** [Makefile:1864: ell/genl.lo] Error 1
  CC       ell/dbus.lo
In file included from ell/dbus.c:38:
ell/dbus.c: In function =E2=80=98classic_free=E2=80=99:
ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
ell/dbus.c:582:3: note: in expansion of macro =E2=80=98l_container_of=E2=80=
=99
   l_container_of(dbus, struct l_dbus_classic, super);
   ^~~~~~~~~~~~~~
ell/dbus.c: In function =E2=80=98classic_recv_message=E2=80=99:
ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
ell/dbus.c:661:3: note: in expansion of macro =E2=80=98l_container_of=E2=80=
=99
   l_container_of(dbus, struct l_dbus_classic, super);
   ^~~~~~~~~~~~~~
ell/dbus.c: In function =E2=80=98classic_add_match=E2=80=99:
ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
ell/dbus.c:812:3: note: in expansion of macro =E2=80=98l_container_of=E2=80=
=99
   l_container_of(dbus, struct l_dbus_classic, super);
   ^~~~~~~~~~~~~~
ell/dbus.c: In function =E2=80=98classic_remove_match=E2=80=99:
ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
ell/dbus.c:836:3: note: in expansion of macro =E2=80=98l_container_of=E2=80=
=99
   l_container_of(dbus, struct l_dbus_classic, super);
   ^~~~~~~~~~~~~~
cc1: all warnings being treated as errors
make[1]: *** [Makefile:1864: ell/dbus.lo] Error 1
  CC       ell/dhcp-transport.lo
In file included from ell/dhcp-transport.c:44:
ell/dhcp-transport.c: In function =E2=80=98_dhcp_default_transport_broadcas=
t=E2=80=99:
ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
ell/dhcp-transport.c:203:3: note: in expansion of macro =E2=80=98l_containe=
r_of=E2=80=99
   l_container_of(s, struct dhcp_default_transport, super);
   ^~~~~~~~~~~~~~
ell/dhcp-transport.c: In function =E2=80=98_dhcp_default_transport_send=E2=
=80=99:
ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
ell/dhcp-transport.c:246:3: note: in expansion of macro =E2=80=98l_containe=
r_of=E2=80=99
   l_container_of(s, struct dhcp_default_transport, super);
   ^~~~~~~~~~~~~~
ell/dhcp-transport.c: In function =E2=80=98_dhcp_default_transport_bind=E2=
=80=99:
ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
ell/dhcp-transport.c:316:3: note: in expansion of macro =E2=80=98l_containe=
r_of=E2=80=99
   l_container_of(s, struct dhcp_default_transport, super);
   ^~~~~~~~~~~~~~
ell/dhcp-transport.c: In function =E2=80=98_dhcp_default_transport_open=E2=
=80=99:
ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
ell/dhcp-transport.c:454:3: note: in expansion of macro =E2=80=98l_containe=
r_of=E2=80=99
   l_container_of(s, struct dhcp_default_transport, super);
   ^~~~~~~~~~~~~~
ell/dhcp-transport.c: In function =E2=80=98_dhcp_default_transport_close=E2=
=80=99:
ell/util.h:40:3: error: cast increases required alignment of target type [-=
Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
ell/dhcp-transport.c:476:3: note: in expansion of macro =E2=80=98l_containe=
r_of=E2=80=99
   l_container_of(s, struct dhcp_default_transport, super);
   ^~~~~~~~~~~~~~
cc1: all warnings being treated as errors
make[1]: *** [Makefile:1864: ell/dhcp-transport.lo] Error 1
  CC       unit/test-genl-msg.o
unit/test-genl-msg.c: In function =E2=80=98parse_set_station=E2=80=99:
unit/test-genl-msg.c:63:10: error: cast increases required alignment of tar=
get type [-Werror=3Dcast-align]
  nlmsg =3D (struct nlmsghdr *) set_station_request;
          ^
unit/test-genl-msg.c: In function =E2=80=98parse_set_rekey_offload=E2=80=99:
unit/test-genl-msg.c:159:10: error: cast increases required alignment of ta=
rget type [-Werror=3Dcast-align]
  nlmsg =3D (struct nlmsghdr *) set_rekey_offload_request;
          ^
unit/test-genl-msg.c: In function =E2=80=98parse_libnl_nested=E2=80=99:
unit/test-genl-msg.c:287:10: error: cast increases required alignment of ta=
rget type [-Werror=3Dcast-align]
  nlmsg =3D (struct nlmsghdr *) libnl_nested;
          ^
cc1: all warnings being treated as errors
make[1]: *** [Makefile:1848: unit/test-genl-msg.o] Error 1
  CC       unit/test-dbus-watch.o
In file included from ./ell/ell.h:23,
                 from unit/test-dbus-watch.c:30:
unit/test-dbus-watch.c: In function =E2=80=98test_add_match=E2=80=99:
./ell/util.h:40:3: error: cast increases required alignment of target type =
[-Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
unit/test-dbus-watch.c:111:3: note: in expansion of macro =E2=80=98l_contai=
ner_of=E2=80=99
   l_container_of(dbus, struct filter_test_state, dbus);
   ^~~~~~~~~~~~~~
unit/test-dbus-watch.c: In function =E2=80=98test_remove_match=E2=80=99:
./ell/util.h:40:3: error: cast increases required alignment of target type =
[-Werror=3Dcast-align]
   (type *)((char *) __mptr - offsetof(type, member)); \
   ^
unit/test-dbus-watch.c:127:3: note: in expansion of macro =E2=80=98l_contai=
ner_of=E2=80=99
   l_container_of(dbus, struct filter_test_state, dbus);
   ^~~~~~~~~~~~~~
cc1: all warnings being treated as errors
make[1]: *** [Makefile:1848: unit/test-dbus-watch.o] Error 1
make[1]: Target 'all-am' not remade because of errors.
make: *** [Makefile:1199: all] Error 2
pi(a)raspberrypi:~/ell $=20

--===============3141490394383402372==--

