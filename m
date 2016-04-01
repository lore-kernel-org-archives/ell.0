Content-Type: multipart/mixed; boundary="===============8883700058468841372=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Use KDBUS_CMD_FREE after kdbus hello
Date: Fri, 01 Apr 2016 04:41:03 +0200
Message-ID: <1459478466-6299-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8883700058468841372==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-kernel.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 9bc99d7..1c0fbb6 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -237,6 +237,7 @@ int _dbus_kernel_hello(int fd, const char *connection_n=
ame,
 	struct kdbus_cmd_hello *hello;
 	struct kdbus_item *item;
 	int ret;
+	struct kdbus_cmd_free cmd_free;
 =

 	size =3D align_len(sizeof(struct kdbus_cmd_hello), 8);
 	size +=3D KDBUS_ITEM_SIZE(len + 1);
@@ -256,18 +257,23 @@ int _dbus_kernel_hello(int fd, const char *connection=
_name,
 	strcpy(item->str, connection_name);
 =

 	ret =3D ioctl(fd, KDBUS_CMD_HELLO, hello);
-	if (ret < 0)
-		return -errno;
+	if (ret < 0) {
+		ret =3D -errno;
+		goto done;
+	}
 =

         /* Check for incompatible flags (upper 32 bits) */
         if (hello->bus_flags > 0xFFFFFFFFULL ||
-			hello->flags > 0xFFFFFFFFULL)
-                return -ENOTSUP;
+			hello->flags > 0xFFFFFFFFULL) {
+		ret =3D -ENOTSUP;
+		goto done;
+	}
 =

 	*pool =3D mmap(NULL, KDBUS_POOL_SIZE, PROT_READ, MAP_SHARED, fd, 0);
 	if (*pool =3D=3D MAP_FAILED) {
 		*pool =3D NULL;
-		return -errno;
+		ret =3D -errno;
+		goto done;
 	}
 =

 	*bloom_size =3D DEFAULT_BLOOM_SIZE;
@@ -286,7 +292,14 @@ int _dbus_kernel_hello(int fd, const char *connection_=
name,
 				hello->id128[12], hello->id128[13],
 				hello->id128[14], hello->id128[15]);
 =

-	return 0;
+done:
+	memset(&cmd_free, 0, sizeof(cmd_free));
+	cmd_free.size =3D sizeof(cmd_free);
+	cmd_free.offset =3D hello->offset;
+
+	ioctl(fd, KDBUS_CMD_FREE, &cmd_free);
+
+	return ret;
 }
 =

 int _dbus_kernel_send(int fd, size_t bloom_size, uint8_t bloom_n_hash,
-- =

2.5.0


--===============8883700058468841372==--

