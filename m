Content-Type: multipart/mixed; boundary="===============2271841606312143393=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH] dbus: Message header was not initialized
Date: Thu, 19 Feb 2015 11:00:44 +0200
Message-ID: <1424336444-32199-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2271841606312143393==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Saw this valgrind report about the issue

 =3D=3D30891=3D=3D Syscall param sendmsg(msg.msg_iov[0]) points to uninitia=
lised byte(s)
 =3D=3D30891=3D=3D    at 0x3B8FF01850: __sendmsg_nocancel (syscall-template=
.S:81)
 =3D=3D30891=3D=3D    by 0x410602: classic_send_message (dbus.c:561)
 =3D=3D30891=3D=3D    by 0x40F4A1: message_write_handler (dbus.c:173)
 =3D=3D30891=3D=3D    by 0x419D56: io_callback (io.c:138)
 =3D=3D30891=3D=3D    by 0x40BBC2: l_main_run (main.c:346)
 =3D=3D30891=3D=3D    by 0x401ECF: main (main.c:160)
 =3D=3D30891=3D=3D  Address 0x4c59304 is 4 bytes inside a block of size 12 =
alloc'd
 =3D=3D30891=3D=3D    at 0x4A06BCF: malloc (in /usr/lib64/valgrind/vgpreloa=
d_memcheck-amd64-linux.so)
 =3D=3D30891=3D=3D    by 0x4A08A9D: realloc (in /usr/lib64/valgrind/vgprelo=
ad_memcheck-amd64-linux.so)
 =3D=3D30891=3D=3D    by 0x409A7D: l_realloc (util.c:92)
 =3D=3D30891=3D=3D    by 0x413A3E: message_new_common (dbus-message.c:201)
 =3D=3D30891=3D=3D    by 0x414B73: _dbus_message_new_method_call (dbus-mess=
age.c:221)
 =3D=3D30891=3D=3D    by 0x408A8B: send_request (agent.c:102)
 =3D=3D30891=3D=3D    by 0x408D28: agent_finalize_pending (agent.c:157)
 =3D=3D30891=3D=3D    by 0x408F9D: request_timeout (agent.c:241)
 =3D=3D30891=3D=3D    by 0x40C349: timeout_callback (timeout.c:78)
 =3D=3D30891=3D=3D    by 0x40BBC2: l_main_run (main.c:346)
 =3D=3D30891=3D=3D    by 0x401ECF: main (main.c:160)
 =3D=3D30891=3D=3D
---
 ell/dbus-message.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index 159df82..8743d66 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -200,6 +200,7 @@ static struct l_dbus_message *message_new_common(uint8_=
t type, uint8_t flags,
 	 */
 	message->header =3D l_realloc(NULL, 12);
 	message->header_size =3D 12;
+	memset(message->header, 0, 12);
 =

 	hdr =3D message->header;
 	hdr->endian =3D DBUS_NATIVE_ENDIAN;
-- =

2.1.0


--===============2271841606312143393==--

