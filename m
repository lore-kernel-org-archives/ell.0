Content-Type: multipart/mixed; boundary="===============0148334756640006989=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 13/13] icmp6, dhcp6,
 dhcp: Ensure buffer space for SCM_TIMESTAMP
Date: Fri, 22 Apr 2022 20:59:52 +0200
Message-ID: <20220422185952.105279-13-andrew.zaborowski@intel.com>
In-Reply-To: 20220422185952.105279-1-andrew.zaborowski@intel.com

--===============0148334756640006989==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Apparently the kernel will include message ancillary elements like
SCM_TIMESTAMP even if there isn't enough space for the entire element.
Reserve enough buffer space and check we received the whole
SCM_TIMESTAMP element.

Fixes: adf18f2bae67 ("icmp6: Use SO_TIMESTAMP")
Fixes: cd678415a75c ("dhcp6: Set lease expiry based on frame reception time=
s")
Fixes: c78ad1bb6d7e ("dhcp: Set lease expiry based on frame reception times=
")
---
 ell/dhcp-transport.c  | 6 ++++--
 ell/dhcp6-transport.c | 8 +++++---
 ell/icmp6.c           | 7 +++++--
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index d73930b..52da2db 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -117,7 +117,7 @@ static bool _dhcp_default_transport_read_handler(struct=
 l_io *io,
 	struct cmsghdr *cmsg;
 	struct iovec iov =3D { .iov_base =3D buf, .iov_len =3D sizeof(buf) };
 	struct msghdr msg =3D {};
-	unsigned char control[32];
+	unsigned char control[32 + CMSG_SPACE(sizeof(struct timeval))];
 =

 	msg.msg_name =3D &saddr;
 	msg.msg_namelen =3D sizeof(saddr);
@@ -165,7 +165,9 @@ static bool _dhcp_default_transport_read_handler(struct=
 l_io *io,
 	for (cmsg =3D CMSG_FIRSTHDR(&msg); cmsg !=3D NULL;
 					cmsg =3D CMSG_NXTHDR(&msg, cmsg)) {
 		if (cmsg->cmsg_level =3D=3D SOL_SOCKET &&
-				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP) {
+				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP &&
+				cmsg->cmsg_len =3D=3D
+				CMSG_LEN(sizeof(struct timeval))) {
 			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
 =

 			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
diff --git a/ell/dhcp6-transport.c b/ell/dhcp6-transport.c
index 04bf4fb..13545b8 100644
--- a/ell/dhcp6-transport.c
+++ b/ell/dhcp6-transport.c
@@ -61,7 +61,7 @@ static bool _dhcp6_default_transport_read_handler(struct =
l_io *io,
 	struct cmsghdr *cmsg;
 	struct iovec iov =3D { .iov_base =3D buf, .iov_len =3D sizeof(buf) };
 	struct msghdr msg =3D {};
-	unsigned char control[32];
+	unsigned char control[32 + CMSG_SPACE(sizeof(struct timeval))];
 =

 	msg.msg_iov =3D &iov;
 	msg.msg_iovlen =3D 1;
@@ -78,8 +78,10 @@ static bool _dhcp6_default_transport_read_handler(struct=
 l_io *io,
 	for (cmsg =3D CMSG_FIRSTHDR(&msg); cmsg !=3D NULL;
 					cmsg =3D CMSG_NXTHDR(&msg, cmsg)) {
 		if (cmsg->cmsg_level =3D=3D SOL_SOCKET &&
-				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP) {
-			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
+				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP &&
+				cmsg->cmsg_len =3D=3D
+				CMSG_LEN(sizeof(struct timeval))) {
+		const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
 =

 			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
 		}
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 158cfa8..ab2fe9c 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -203,7 +203,8 @@ static int icmp6_send_router_solicitation(int s, const =
uint8_t mac[static 6])
 static int icmp6_receive(int s, void *buf, size_t buf_len, struct in6_addr=
 *src,
 				uint64_t *out_timestamp)
 {
-	char c_msg_buf[CMSG_SPACE(sizeof(int))];
+	char c_msg_buf[CMSG_SPACE(sizeof(int)) +
+			CMSG_SPACE(sizeof(struct timeval))];
 	struct iovec iov =3D {
 		.iov_base =3D buf,
 		.iov_len =3D buf_len,
@@ -242,7 +243,9 @@ static int icmp6_receive(int s, void *buf, size_t buf_l=
en, struct in6_addr *src,
 			if (hops !=3D 255)
 				return -EMULTIHOP;
 		} else if (cmsg->cmsg_level =3D=3D SOL_SOCKET &&
-				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP) {
+				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP &&
+				cmsg->cmsg_len =3D=3D
+				CMSG_LEN(sizeof(struct timeval))) {
 			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
 =

 			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
-- =

2.32.0

--===============0148334756640006989==--

