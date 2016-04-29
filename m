Content-Type: multipart/mixed; boundary="===============0272840485506827334=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 09/11] dbus: Attach FDs to kdbus messages being sent
Date: Fri, 29 Apr 2016 05:32:06 +0200
Message-ID: <1461900728-20662-14-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1461900728-20662-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0272840485506827334==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-kernel.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 7446ece..302e3b9 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -325,6 +325,8 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8_=
t bloom_n_hash,
 	size_t footer_size;
 	int ret;
 	struct kdbus_cmd_send cmd;
+	uint32_t num_fds;
+	int *fds;
 	L_AUTO_FREE_VAR(struct kdbus_msg *, kmsg);
 =

 	dest =3D l_dbus_message_get_destination(message);
@@ -350,6 +352,11 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8=
_t bloom_n_hash,
 	if (dest && !unique)
 		kmsg_size +=3D KDBUS_ITEM_SIZE(dest_len + 1);
 =

+	/* Reserve space for fds */
+	fds =3D _dbus_message_get_fds(message, &num_fds);
+	if (num_fds)
+		kmsg_size +=3D KDBUS_ITEM_SIZE(num_fds * sizeof(int));
+
 	kmsg =3D aligned_alloc(8, kmsg_size);
 	if (!kmsg)
 		return -ENOMEM;
@@ -433,6 +440,13 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8=
_t bloom_n_hash,
 	item->vec.size =3D footer_size;
 	item =3D KDBUS_ITEM_NEXT(item);
 =

+	if (num_fds) {
+		item->size =3D KDBUS_ITEM_HEADER_SIZE + num_fds * sizeof(int);
+		item->type =3D KDBUS_ITEM_FDS;
+		memcpy(item->fds, fds, num_fds * sizeof(int));
+		item =3D KDBUS_ITEM_NEXT(item);
+	}
+
 	kmsg->size =3D (void *)item - (void *)kmsg;
 =

 	memset(&cmd, 0, sizeof(cmd));
-- =

2.5.0


--===============0272840485506827334==--

