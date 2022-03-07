Content-Type: multipart/mixed; boundary="===============3185769916023081274=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 06/12] icmp6: Use SO_TIMESTAMP
Date: Mon, 07 Mar 2022 15:55:37 +0100
Message-ID: <20220307145543.1558788-6-andrew.zaborowski@intel.com>
In-Reply-To: 20220307145543.1558788-1-andrew.zaborowski@intel.com

--===============3185769916023081274==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Like in dhcp and dhcp6 set the SO_TIMESTAMP socket option to get kernel
packet reception times for router advertisements and save it.
---
 ell/icmp6-private.h |  4 +++-
 ell/icmp6.c         | 29 +++++++++++++++++++++++------
 2 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/ell/icmp6-private.h b/ell/icmp6-private.h
index 3846bad..2433087 100644
--- a/ell/icmp6-private.h
+++ b/ell/icmp6-private.h
@@ -33,6 +33,7 @@ struct l_icmp6_router {
 	bool managed : 1;
 	bool other : 1;
 	uint8_t pref;
+	uint64_t start_time;
 	uint16_t lifetime;
 	uint32_t mtu;
 	uint32_t n_prefixes;
@@ -43,4 +44,5 @@ struct l_icmp6_router *_icmp6_router_new();
 void _icmp6_router_free(struct l_icmp6_router *r);
 struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *=
ra,
 						size_t len,
-						const uint8_t src[static 16]);
+						const uint8_t src[static 16],
+						uint64_t timestamp);
diff --git a/ell/icmp6.c b/ell/icmp6.c
index 3658408..b0f8727 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -126,6 +126,10 @@ static int icmp6_open_router_common(const struct icmp6=
_filter *filter,
 				ifr.ifr_name, strlen(ifr.ifr_name) + 1);
 	}
 =

+	if (r < 0)
+		goto fail;
+
+	r =3D setsockopt(s, SOL_SOCKET, SO_TIMESTAMP, &yes, sizeof(yes));
 	if (r < 0)
 		goto fail;
 =

@@ -191,7 +195,8 @@ static int icmp6_send_router_solicitation(int s, const =
uint8_t mac[static 6])
 	return 0;
 }
 =

-static int icmp6_receive(int s, void *buf, size_t buf_len, struct in6_addr=
 *src)
+static int icmp6_receive(int s, void *buf, size_t buf_len, struct in6_addr=
 *src,
+				uint64_t *out_timestamp)
 {
 	char c_msg_buf[CMSG_SPACE(sizeof(int))];
 	struct iovec iov =3D {
@@ -210,6 +215,7 @@ static int icmp6_receive(int s, void *buf, size_t buf_l=
en, struct in6_addr *src)
 	};
 	struct cmsghdr *cmsg;
 	ssize_t l;
+	uint64_t timestamp =3D 0;
 =

 	l =3D recvmsg(s, &msg, MSG_DONTWAIT);
 	if (l < 0)
@@ -230,10 +236,16 @@ static int icmp6_receive(int s, void *buf, size_t buf=
_len, struct in6_addr *src)
 =

 			if (hops !=3D 255)
 				return -EMULTIHOP;
+		} else if (cmsg->cmsg_level =3D=3D SOL_SOCKET &&
+				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP) {
+			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
+
+			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
 		}
 	}
 =

 	memcpy(src, &saddr.sin6_addr, sizeof(saddr.sin6_addr));
+	*out_timestamp =3D timestamp ?: l_time_now();
 	return 0;
 }
 =

@@ -344,9 +356,11 @@ static void icmp6_client_setup_routes(struct l_icmp6_c=
lient *client)
 static int icmp6_client_handle_message(struct l_icmp6_client *client,
 						struct nd_router_advert *ra,
 						size_t len,
-						const struct in6_addr *src)
+						const struct in6_addr *src,
+						uint64_t timestamp)
 {
-	struct l_icmp6_router *r =3D _icmp6_router_parse(ra, len, src->s6_addr);
+	struct l_icmp6_router *r =3D
+		_icmp6_router_parse(ra, len, src->s6_addr, timestamp);
 =

 	if (!r)
 		return -EBADMSG;
@@ -382,6 +396,7 @@ static bool icmp6_client_read_handler(struct l_io *io, =
void *userdata)
 	ssize_t l;
 	struct in6_addr src;
 	int r;
+	uint64_t timestamp =3D 0;
 =

 	/* Poke to see how many bytes we need to read / alloc */
 	l =3D recv(s, NULL, 0, MSG_PEEK|MSG_TRUNC);
@@ -392,7 +407,7 @@ static bool icmp6_client_read_handler(struct l_io *io, =
void *userdata)
 	}
 =

 	ra =3D l_malloc(l);
-	if (icmp6_receive(s, ra, l, &src) < 0)
+	if (icmp6_receive(s, ra, l, &src, &timestamp) < 0)
 		goto done;
 =

 	if ((size_t) l < sizeof(struct nd_router_advert)) {
@@ -400,7 +415,7 @@ static bool icmp6_client_read_handler(struct l_io *io, =
void *userdata)
 		goto done;
 	}
 =

-	r =3D icmp6_client_handle_message(client, ra, l, &src);
+	r =3D icmp6_client_handle_message(client, ra, l, &src, timestamp);
 	if (r < 0)
 		goto done;
 =

@@ -661,7 +676,8 @@ void _icmp6_router_free(struct l_icmp6_router *r)
 =

 struct l_icmp6_router *_icmp6_router_parse(const struct nd_router_advert *=
ra,
 						size_t len,
-						const uint8_t src[static 16])
+						const uint8_t src[static 16],
+						uint64_t timestamp)
 {
 	struct l_icmp6_router *r;
 	const uint8_t *opts;
@@ -726,6 +742,7 @@ struct l_icmp6_router *_icmp6_router_parse(const struct=
 nd_router_advert *ra,
 	if (r->pref =3D=3D 0x2) /* If invalid, reset to medium */
 		r->pref =3D 0;
 =

+	r->start_time =3D timestamp;
 	r->lifetime =3D L_BE16_TO_CPU(ra->nd_ra_router_lifetime);
 =

 	opts =3D (uint8_t *) (ra + 1);
-- =

2.32.0

--===============3185769916023081274==--

