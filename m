Content-Type: multipart/mixed; boundary="===============3677909393434499032=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Avoid EPOLL_CTL_ADD on kdbus fd before hello command
Date: Tue, 05 Apr 2016 04:04:40 +0200
Message-ID: <1459821880-7050-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3677909393434499032==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Reorder the kdbus initialisation to avoid epoll_ctl(fd, EPOLL_CTL_ADD,
...) being called (from watch_add in l_io_new in dbus_init) before
KDBUS_CMD_HELLO is sent.  On the kernel side the kdbus handle is in the
BUS_OWNER state until the hello command changes is to CONNECTED state,
and will exit from f_ops->poll and not do anything to make epoll work.
handle->conn is created only once in CONNECTED state but only the
first f_ops->poll call by a given eventpoll has a chance to add the
handle->conn->wait to its poll table.
---
 ell/dbus.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index dfeacbc..94d819a 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1216,8 +1216,6 @@ static struct l_dbus *setup_kdbus(int fd)
 	dbus =3D &kdbus->super;
 	dbus->driver =3D &kdbus_ops;
 =

-	dbus_init(dbus, fd);
-
 	if (_dbus_kernel_hello(fd, "ell-connection",
 				&kdbus->bloom_size, &kdbus->bloom_n_hash,
 				&kdbus->kdbus_id, &kdbus->kdbus_pool,
@@ -1227,6 +1225,8 @@ static struct l_dbus *setup_kdbus(int fd)
 		return NULL;
 	}
 =

+	dbus_init(dbus, fd);
+
 	dbus->unique_name =3D l_strdup_printf(":1.%llu", kdbus->kdbus_id);
 =

 	l_idle_oneshot(kdbus_ready, dbus, NULL);
-- =

2.5.0


--===============3677909393434499032==--

