Content-Type: multipart/mixed; boundary="===============0046670093406665366=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Don't use KDBUS_ATTACH_NAMES for kdbus connection
Date: Fri, 29 Apr 2016 05:31:57 +0200
Message-ID: <1461900728-20662-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0046670093406665366==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On the receive side we're not using the list of names being attached to
messages because we keep a cache of the name owners we need.  On the
send side the KDBUS_ATTACH_NAMES is implicitly granted so there's no
need to specify it.
---
 ell/dbus-kernel.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 4fd2f29..50ee0ed 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -248,8 +248,6 @@ int _dbus_kernel_hello(int fd, const char *connection_n=
ame,
 =

 	hello->size =3D size;
 	hello->flags |=3D KDBUS_HELLO_ACCEPT_FD;
-	hello->attach_flags_send |=3D KDBUS_ATTACH_NAMES;
-	hello->attach_flags_recv |=3D KDBUS_ATTACH_NAMES;
 	hello->pool_size =3D KDBUS_POOL_SIZE;
 =

 	item =3D hello->items;
-- =

2.5.0


--===============0046670093406665366==--

