Content-Type: multipart/mixed; boundary="===============3270426942022063387=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 3/3] netlink: Enable extended ACKs if debug handler set
Date: Sat, 11 Jun 2022 03:45:45 +0200
Message-ID: <20220611014545.1466270-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220611014545.1466270-1-andrew.zaborowski@intel.com

--===============3270426942022063387==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Enable the NETLINK_EXT_ACK socket option on netlink sockets if debug
logging is enabled so as to show the error message strings from the
kernel.
---
 ell/netlink.c | 36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/ell/netlink.c b/ell/netlink.c
index 32d021b..bab76f8 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -158,6 +158,31 @@ static void process_broadcast(struct l_netlink *netlin=
k, uint32_t group,
 	l_hashmap_foreach(notify_list, do_notify, nlmsg);
 }
 =

+static void process_ext_ack(struct l_netlink *netlink,
+				const struct nlmsghdr *nlmsg)
+{
+	const char *err_str =3D NULL;
+	uint32_t err_offset =3D -1U;
+	_auto_(l_free) char *dbg_str =3D NULL;
+
+	if (!netlink->debug_handler ||
+			!netlink_parse_ext_ack(nlmsg, &err_str, &err_offset) ||
+			(!err_str && err_offset =3D=3D -1U))
+		return;
+
+	if (err_str && err_offset !=3D -1U)
+		dbg_str =3D l_strdup_printf("Extended error: '%s', offset of "
+					" offending element within request: "
+					"%i bytes", err_str, (int) err_offset);
+	else if (err_str)
+		dbg_str =3D l_strdup_printf("Extended error: '%s'", err_str);
+	else
+		dbg_str =3D l_strdup_printf("Offset of offending element within "
+					"request: %i bytes", (int) err_offset);
+
+	netlink->debug_handler(dbg_str, netlink->debug_data);
+}
+
 static void process_message(struct l_netlink *netlink, struct nlmsghdr *nl=
msg)
 {
 	const void *data =3D nlmsg;
@@ -176,10 +201,12 @@ static void process_message(struct l_netlink *netlink=
, struct nlmsghdr *nlmsg)
 =

 		switch (nlmsg->nlmsg_type) {
 		case NLMSG_ERROR:
-			err =3D data + NLMSG_HDRLEN;
+			err =3D NLMSG_DATA(nlmsg);
 =

 			command->handler(err->error, 0, NULL, 0,
 							command->user_data);
+
+			process_ext_ack(netlink, nlmsg);
 			break;
 		}
 	} else {
@@ -597,6 +624,8 @@ LIB_EXPORT bool l_netlink_set_debug(struct l_netlink *n=
etlink,
 			l_netlink_debug_func_t function,
 			void *user_data, l_netlink_destroy_func_t destroy)
 {
+	int ext_ack;
+
 	if (unlikely(!netlink))
 		return false;
 =

@@ -609,6 +638,11 @@ LIB_EXPORT bool l_netlink_set_debug(struct l_netlink *=
netlink,
 =

 	/* l_io_set_debug(netlink->io, function, user_data, NULL); */
 =

+	ext_ack =3D function !=3D NULL;
+	if (setsockopt(l_io_get_fd(netlink->io), SOL_NETLINK, NETLINK_EXT_ACK,
+			&ext_ack, sizeof(ext_ack)) < 0 && function)
+		function("Failed to set NETLINK_EXT_ACK", user_data);
+
 	return true;
 }
 =

-- =

2.34.1

--===============3270426942022063387==--

