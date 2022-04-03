Received: from devico.uberspace.de (devico.uberspace.de [185.26.156.185])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D16191FDA
	for <ell@lists.linux.dev>; Sun,  3 Apr 2022 17:34:33 +0000 (UTC)
Received: (qmail 1120 invoked by uid 990); 3 Apr 2022 17:27:50 -0000
Authentication-Results: devico.uberspace.de;
	auth=pass (plain)
From: Leonard Lausen <leonard@lausen.nl>
To: ell@lists.linux.dev
Cc: 
Subject: segfault in parse_neighbor_report at src/station.c:1747
Date: Sun, 03 Apr 2022 17:27:48 +0000
Message-ID: <87k0c63wmj.fsf@lausen.nl>
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Rspamd-Bar: /
X-Rspamd-Report: BAYES_HAM(-0.241446) MIME_GOOD(-0.1)
X-Rspamd-Score: -0.341446
Received: from unknown (HELO unkown) (::1)
	by devico.uberspace.de (Haraka/2.8.28) with ESMTPSA; Sun, 03 Apr 2022 19:27:50 +0200

Hi all,

connecting a laptop with Intel=C2=AE Wi-Fi 6E AX210 to a Vodafone Wi-Fi 6
Station sometimes triggers a segfault with ell 0.49 and iwd 1.26 in
parse_neighbor_report at src/station.c:1747. Earlier versions of ell and
iwd also segfault. Please see below excerpts from gdb. I can share the
full coredump if helpful. In case you require any further information or
would like me to test a fix, please note I will only have access to this
Station until Thursday April 7th.

Program terminated with signal SIGSEGV, Segmentation fault.
#0  0x000055f07250580e in parse_neighbor_report (station=3Dstation@entry=3D=
0x55f0725c8e50,
    reports=3Dreports@entry=3D0x55f0725cc35b "4\025\354\250\037\231\317", <=
incomplete sequence \350>, reports_len=3Dreports_len@entry=3D23,
    set=3Dset@entry=3D0x7ffca3384ee0) at src/station.c:1747
1747                            cc =3D station->connected_bss->cc;
(gdb) bt
#0  0x000055f07250580e in parse_neighbor_report (station=3Dstation@entry=3D=
0x55f0725c8e50,
    reports=3Dreports@entry=3D0x55f0725cc35b "4\025\354\250\037\231\317", <=
incomplete sequence \350>, reports_len=3Dreports_len@entry=3D23,
    set=3Dset@entry=3D0x7ffca3384ee0) at src/station.c:1747
#1  0x000055f07250928b in station_neighbor_report_cb (netdev=3D<optimized o=
ut>, err=3D0,
    reports=3D0x55f0725cc35b "4\025\354\250\037\231\317", <incomplete seque=
nce \350>, reports_len=3D23, user_data=3D0x55f0725c8e50) at src/station.c:2=
481
#2  0x000055f07254f282 in frame_watch_unicast_notify (msg=3D<optimized out>=
, user_data=3D0x55f0725c8580) at src/frame-xchg.c:234
#3  0x00007f8a4b3cca19 in dispatch_unicast_watches () from /usr/lib64/libel=
l.so.0
#4  0x00007f8a4b3ccad1 in process_unicast () from /usr/lib64/libell.so.0
#5  0x00007f8a4b3ccf0b in received_data () from /usr/lib64/libell.so.0
#6  0x00007f8a4b3c7692 in io_callback () from /usr/lib64/libell.so.0
#7  0x00007f8a4b3c5fe7 in l_main_iterate () from /usr/lib64/libell.so.0
#8  0x00007f8a4b3c612e in l_main_run () from /usr/lib64/libell.so.0
#9  0x00007f8a4b3c6461 in l_main_run_with_signal () from /usr/lib64/libell.=
so.0
#10 0x000055f0724f453b in main (argc=3D<optimized out>, argv=3D<optimized o=
ut>) at src/main.c:600
(gdb) l
1742                                    util_address_to_string(info.addr),
1743                                    (int) info.channel_num, (int) info.=
oper_class,
1744                                    info.md ? "MD set" : "MD not set");
1745
1746                    if (station->connected_bss->cc_present)
1747                            cc =3D station->connected_bss->cc;
1748
1749                    freq =3D station_freq_from_neighbor_report(cc, &inf=
o, &band);
1750                    if (!freq)
1751                            continue;
(gdb) info locals
info =3D {addr =3D "\354\250\037\231\317", <incomplete sequence \350>, reac=
hable =3D 0 '\000', spectrum_mgmt =3D false, qos =3D false, apsd =3D false,=
 rm =3D false,
  delayed_block_ack =3D false, immediate_block_ack =3D false, security =3D =
false, key_scope =3D false, md =3D false, ht =3D false, oper_class =3D 4 '\=
004',
  channel_num =3D 11 '\v', phy_type =3D 0 '\000', bss_transition_pref =3D 2=
55 '\377', bss_transition_pref_present =3D true}
freq =3D <optimized out>
band =3D <optimized out>
cc =3D 0x0
iter =3D {max =3D 23, pos =3D 23, tlv =3D 0x55f0725cc35b "4\025\354\250\037=
\231\317", <incomplete sequence \350>, tag =3D 52, len =3D 21,
  data =3D 0x55f0725cc35d "\354\250\037\231\317", <incomplete sequence \350=
>}
count_md =3D 0
count_no_md =3D 0
freq_set_md =3D 0x55f0725d33f0
freq_set_no_md =3D 0x55f0725d5420
current_freq =3D 0
hs =3D 0x0
supported =3D 0x55f0725c4cc0
__func__ =3D "parse_neighbor_report"
(gdb) info args
station =3D 0x55f0725c8e50
reports =3D 0x55f0725cc35b "4\025\354\250\037\231\317", <incomplete sequenc=
e \350>
reports_len =3D 23
set =3D 0x7ffca3384ee0

Thank you
Leonard
