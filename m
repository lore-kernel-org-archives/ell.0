Content-Type: multipart/mixed; boundary="===============3433244671103364574=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH] dhcp,dhcp6,icmp6,time: Convert timestamps to CLOCK_BOOTTIME
Date: Wed, 18 May 2022 02:35:23 +0200
Message-ID: <20220518003523.1717565-1-andrew.zaborowski@intel.com>

--===============3433244671103364574==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The frame reception timestamps obtained for DHCPv4, DHCPv6 and ICMPv6
frames from the kernel are based on CLOCK_REALTIME, there's no option to
switch them to CLOCK_BOOTTIME, which we use across our retransmission and
renew logic.  Add a time-private.h utility to convert the timestamps
right where we read them from recvmsg() to produce CLOCK_BOOTTIME based
times.  This isn't 100% bulletproof because the offset between the two
clocks can vary between the time the frame was received by the kernel and
the time we read the offset.  The probability is very low though and we
have no better solution at this time other than fixing it in the kernel.
Using CLOCK_REALTIME for frame reception timestamps seems to mainly
create potential for problems in the common usages.

Fixes: c78ad1bb6d7e ("dhcp: Set lease expiry based on frame reception times=
")
---
 ell/dhcp-transport.c  |  3 ++-
 ell/dhcp6-transport.c |  5 +++--
 ell/icmp6.c           |  2 +-
 ell/time-private.h    |  1 +
 ell/time.c            | 34 ++++++++++++++++++++++++++++++++++
 6 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index 52da2db..42872bc 100644
--- a/ell/dhcp-transport.c
+++ b/ell/dhcp-transport.c
@@ -45,6 +45,7 @@
 #include "util.h"
 #include "private.h"
 #include "time.h"
+#include "time-private.h"
 #include "dhcp-private.h"
 =

 struct dhcp_default_transport {
@@ -170,7 +171,7 @@ static bool _dhcp_default_transport_read_handler(struct=
 l_io *io,
 				CMSG_LEN(sizeof(struct timeval))) {
 			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
 =

-			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
+			timestamp =3D _time_realtime_to_boottime(tv);
 		}
 	}
 =

diff --git a/ell/dhcp6-transport.c b/ell/dhcp6-transport.c
index 13545b8..24cc1ce 100644
--- a/ell/dhcp6-transport.c
+++ b/ell/dhcp6-transport.c
@@ -40,6 +40,7 @@
 #include "missing.h"
 #include "io.h"
 #include "time.h"
+#include "time-private.h"
 #include "dhcp6-private.h"
 =

 struct dhcp6_default_transport {
@@ -81,9 +82,9 @@ static bool _dhcp6_default_transport_read_handler(struct =
l_io *io,
 				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP &&
 				cmsg->cmsg_len =3D=3D
 				CMSG_LEN(sizeof(struct timeval))) {
-		const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
+			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
 =

-			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
+			timestamp =3D _time_realtime_to_boottime(tv);
 		}
 	}
 =

diff --git a/ell/icmp6.c b/ell/icmp6.c
index 96ba1ec..b790f19 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -249,7 +249,7 @@ static int icmp6_receive(int s, void *buf, size_t buf_l=
en, struct in6_addr *src,
 				CMSG_LEN(sizeof(struct timeval))) {
 			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
 =

-			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
+			timestamp =3D _time_realtime_to_boottime(tv);
 		}
 	}
 =

diff --git a/ell/time-private.h b/ell/time-private.h
index dc4d6c2..5295d94 100644
--- a/ell/time-private.h
+++ b/ell/time-private.h
@@ -23,3 +23,4 @@
 uint64_t _time_pick_interval_secs(uint32_t min_secs, uint32_t max_secs);
 uint64_t _time_fuzz_msecs(uint64_t ms);
 uint64_t _time_fuzz_secs(uint32_t secs, uint32_t max_offset);
+uint64_t _time_realtime_to_boottime(const struct timeval *ts);
diff --git a/ell/time.c b/ell/time.c
index d02dabe..5d5276a 100644
--- a/ell/time.c
+++ b/ell/time.c
@@ -105,3 +105,37 @@ uint64_t _time_fuzz_secs(uint32_t secs, uint32_t max_o=
ffset)
 =

 	return ms;
 }
+
+/*
+ * Convert a *recent* CLOCK_REALTIME-based timestamp to a
+ * CLOCK_BOOTTIME-based usec count consistent with l_time functions.
+ * The longer the time since the input timestamp the higher the
+ * probability of the two clocks having diverged and the higher the
+ * expected error magnitude.
+ */
+uint64_t _time_realtime_to_boottime(const struct timeval *ts)
+{
+	uint64_t now_realtime;
+	uint64_t now_boottime =3D l_time_now();
+	struct timespec timespec;
+	uint64_t ts_realtime;
+	uint64_t offset;
+
+	clock_gettime(CLOCK_REALTIME, &timespec);
+	now_realtime =3D (uint64_t) timespec.tv_sec * L_USEC_PER_SEC +
+		timespec.tv_nsec / L_NSEC_PER_USEC;
+
+	ts_realtime =3D ts->tv_sec * L_USEC_PER_SEC + ts->tv_usec;
+
+	offset =3D l_time_diff(ts_realtime, now_realtime);
+
+	/* Most likely case, timestamp in the past */
+	if (l_time_before(ts_realtime, now_realtime)) {
+		if (offset > now_boottime)
+			return 0;
+
+		return now_boottime - offset;
+	}
+
+	return l_time_offset(now_boottime, offset);
+}
-- =

2.32.0

--===============3433244671103364574==--

