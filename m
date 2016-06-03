Content-Type: multipart/mixed; boundary="===============3230250892616258029=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: ell/main.c Memory leak
Date: Fri, 03 Jun 2016 16:09:55 -0500
Message-ID: <5751F223.6070901@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3230250892616258029==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is from iwd:

[DBUS] > 6c 04 01 01 98 00 00 00 04 00 00 00 68 00 00 00  l...........h...
[DBUS]   01 01 6f 00 01 00 00 00 2f 00 00 00 00 00 00 00  ..o...../.......
[DBUS]   03 01 73 00 0f 00 00 00 49 6e 74 65 72 66 61 63  ..s.....Interfac
[DBUS]   65 73 41 64 64 65 64 00 02 01 73 00 22 00 00 00  esAdded...s."...
[DBUS]   6f 72 67 2e 66 72 65 65 64 65 73 6b 74 6f 70 2e  org.freedesktop.
[DBUS]   44 42 75 73 2e 4f 62 6a 65 63 74 4d 61 6e 61 67  DBus.ObjectManag
[DBUS]   65 72 00 00 00 00 00 00 08 01 67 00 0a 6f 61 7b  er........g..oa{
[DBUS]   73 61 7b 73 76 7d 7d 00                          sa{sv}}.
[DBUS]   02 00 00 00 2f 33 00 00 88 00 00 00 00 00 00 00  ..../3..........
[DBUS]   16 00 00 00 6e 65 74 2e 63 6f 6e 6e 6d 61 6e 2e  ....net.connman.
[DBUS]   69 77 64 2e 44 65 76 69 63 65 00 00 33 00 00 00  iwd.Device..3...
[DBUS]   04 00 00 00 4e 61 6d 65 00 01 73 00 06 00 00 00  ....Name..s.....
[DBUS]   77 6c 70 32 73 30 00 00 07 00 00 00 41 64 64 72  wlp2s0......Addr
[DBUS]   65 73 73 00 01 73 00 00 06 00 00 00 a0 a8 cd 1c  ess..s..........
[DBUS]   7e c9 00 00 00 00 00 00 27 00 00 00 6e 65 74 2e  ~.......'...net.
[DBUS]   63 6f 6e 6e 6d 61 6e 2e 69 77 64 2e 57 69 46 69  connman.iwd.WiFi
[DBUS]   53 69 6d 70 6c 65 43 6f 6e 66 69 67 75 72 61 74  SimpleConfigurat
[DBUS]   69 6f 6e 00 00 00 00 00                          ion.....
src/scan.c:scan_notify() Scan notification 33
[DBUS] disconnect
D-Bus disconnected, quitting...
src/eap.c:__eap_method_disable()
src/eap.c:eap_md5_exit()
src/eap-tls.c:eap_tls_exit()
src/eap-ttls.c:eap_ttls_exit()
src/main.c:nl80211_vanished() Lost nl80211 interface
src/wsc.c:wsc_exit()
src/scan.c:scan_exit()
src/scan.c:scan_context_free() sc: 0x53f4690
src/netdev.c:netdev_free() Freeing netdev wlp2s0[3]
src/netdev.c:netdev_exit() Closing route netlink socket
src/wiphy.c:wiphy_free() Freeing wiphy phy0
src/dbus.c:dbus_exit()
=3D=3D11733=3D=3D
=3D=3D11733=3D=3D HEAP SUMMARY:
=3D=3D11733=3D=3D     in use at exit: 1,048 bytes in 2 blocks
=3D=3D11733=3D=3D   total heap usage: 759 allocs, 757 frees, 88,760 bytes a=
llocated
=3D=3D11733=3D=3D
=3D=3D11733=3D=3D 24 bytes in 1 blocks are still reachable in loss record 1=
 of 2
=3D=3D11733=3D=3D    at 0x4C2C970: malloc (vg_replace_malloc.c:296)
=3D=3D11733=3D=3D    by 0x41CA37: l_malloc (util.c:62)
=3D=3D11733=3D=3D    by 0x41DE00: l_queue_new (queue.c:63)
=3D=3D11733=3D=3D    by 0x422B9D: create_epoll (main.c:102)
=3D=3D11733=3D=3D    by 0x422B9D: idle_add (main.c:263)
=3D=3D11733=3D=3D    by 0x42361A: l_idle_create (idle.c:108)
=3D=3D11733=3D=3D    by 0x4397AF: schedule_emit_signals (dbus-service.c:108=
1)
=3D=3D11733=3D=3D    by 0x43A6EE: _dbus_object_tree_remove_interface =

(dbus-service.c:1503)
=3D=3D11733=3D=3D    by 0x439F45: check_interface_used (dbus-service.c:1306)
=3D=3D11733=3D=3D    by 0x41F342: l_hashmap_foreach (hashmap.c:532)
=3D=3D11733=3D=3D    by 0x439FBC: _dbus_object_tree_unregister_interface =

(dbus-service.c:1320)
=3D=3D11733=3D=3D    by 0x42CC6B: l_dbus_unregister_interface (dbus.c:1715)
=3D=3D11733=3D=3D    by 0x418BE9: wsc_exit (wsc.c:341)
=3D=3D11733=3D=3D
=3D=3D11733=3D=3D 1,024 bytes in 1 blocks are still reachable in loss recor=
d 2 of 2
=3D=3D11733=3D=3D    at 0x4C2C970: malloc (vg_replace_malloc.c:296)
=3D=3D11733=3D=3D    by 0x422B85: create_epoll (main.c:98)
=3D=3D11733=3D=3D    by 0x422B85: idle_add (main.c:263)
=3D=3D11733=3D=3D    by 0x42361A: l_idle_create (idle.c:108)
=3D=3D11733=3D=3D    by 0x4397AF: schedule_emit_signals (dbus-service.c:108=
1)
=3D=3D11733=3D=3D    by 0x43A6EE: _dbus_object_tree_remove_interface =

(dbus-service.c:1503)
=3D=3D11733=3D=3D    by 0x439F45: check_interface_used (dbus-service.c:1306)
=3D=3D11733=3D=3D    by 0x41F342: l_hashmap_foreach (hashmap.c:532)
=3D=3D11733=3D=3D    by 0x439FBC: _dbus_object_tree_unregister_interface =

(dbus-service.c:1320)
=3D=3D11733=3D=3D    by 0x42CC6B: l_dbus_unregister_interface (dbus.c:1715)
=3D=3D11733=3D=3D    by 0x418BE9: wsc_exit (wsc.c:341)
=3D=3D11733=3D=3D    by 0x4029D3: nl80211_vanished (main.c:117)
=3D=3D11733=3D=3D    by 0x428D49: l_genl_family_unref (genl.c:1057)
=3D=3D11733=3D=3D
=3D=3D11733=3D=3D LEAK SUMMARY:
=3D=3D11733=3D=3D    definitely lost: 0 bytes in 0 blocks
=3D=3D11733=3D=3D    indirectly lost: 0 bytes in 0 blocks
=3D=3D11733=3D=3D      possibly lost: 0 bytes in 0 blocks
=3D=3D11733=3D=3D    still reachable: 1,048 bytes in 2 blocks
=3D=3D11733=3D=3D         suppressed: 0 bytes in 0 blocks


This leak happens in create_epoll(). The sequence of events is a bit =

bizarre:

1. We send an invalid signal
2. DBus detects that and kills our connection
3. l_main_quit is called, which frees all main event loop resources
4. We start tearing down the rest of the daemon
	a) At some point we unregister some interfaces
	b) ObjectManager schedules the transmission of a signal
	c) idle_create gets called, which calls create_epoll()
5. DBus is destroyed, which removes the idle source in 4c

Unfortunately at this point, nothing actually frees the resources =

created by create_epoll().

I'm thinking l_main_run needs to be split up into l_main_new, l_main_run =

and l_main_destroy.

Thoughts?

Regards,
-Denis

--===============3230250892616258029==--

