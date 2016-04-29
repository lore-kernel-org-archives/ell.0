Content-Type: multipart/mixed; boundary="===============8828189685684359724=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/11] dbus: Handle received KDBUS_ITEM_FDS
Date: Fri, 29 Apr 2016 05:32:07 +0200
Message-ID: <1461900728-20662-15-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8828189685684359724==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-kernel.c | 28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 302e3b9..2cd1d94 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -489,6 +489,9 @@ static int _dbus_kernel_make_message(struct kdbus_msg *=
kmsg,
 	struct dbus_header *hdr;
 	const char *destination =3D 0;
 	char unique_bus_name[128];
+	uint32_t num_fds =3D 0;
+	int *fds =3D NULL;
+	unsigned int i;
 =

 	KDBUS_ITEM_FOREACH(item, kmsg, items) {
 		switch (item->type) {
@@ -509,7 +512,28 @@ static int _dbus_kernel_make_message(struct kdbus_msg =
*kmsg,
 =

 			return -ENOTSUP;
 		case KDBUS_ITEM_FDS:
-			return -ENOTSUP;
+			if (fds || item->size <=3D KDBUS_ITEM_HEADER_SIZE)
+				return -EBADMSG;
+
+			num_fds =3D (item->size - KDBUS_ITEM_HEADER_SIZE) /
+				sizeof(int);
+			fds =3D item->fds;
+
+			/* Set FD_CLOEXEC on all file descriptors */
+			for (i =3D 0; i < num_fds; i++) {
+				long flags;
+
+				if (fds[i] =3D=3D -1)
+					continue;
+
+				flags =3D fcntl(fds[i], F_GETFD, NULL);
+				if (flags < 0 || (flags & FD_CLOEXEC))
+					continue;
+
+				fcntl(fds[i], F_SETFD, flags | FD_CLOEXEC);
+			}
+
+			break;
 		case KDBUS_ITEM_DST_NAME:
 			if (!_dbus_valid_bus_name(item->str))
 				return -EBADMSG;
@@ -530,7 +554,7 @@ static int _dbus_kernel_make_message(struct kdbus_msg *=
kmsg,
 =

 	collect_body_parts(kmsg, size, &data);
 =

-	*out_message =3D dbus_message_from_blob(data, size, NULL, 0);
+	*out_message =3D dbus_message_from_blob(data, size, fds, num_fds);
 =

 	l_free(data);
 =

-- =

2.5.0


--===============8828189685684359724==--

