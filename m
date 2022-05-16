Content-Type: multipart/mixed; boundary="===============9087121863617484325=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH] dhcp,dhcp6,icmp6,time: Convert timestamps to CLOCK_BOOTTIME
Date: Mon, 16 May 2022 23:31:53 +0200
Message-ID: <20220516213153.1612039-1-andrew.zaborowski@intel.com>

--===============9087121863617484325==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The frame reception timestamps obtained for DHCPv4, DHCPv6 and ICMPv6
frames from the kernel are based on CLOCK_REALTIME, there's no option to
switch them to CLOCK_BOOTTIME, which we use across our retransmission and
renew logic.  Add a time-private.h utility to get the offset between the
two clocks and offset the timestamps right where read them from recvmsg()
to produce CLOCK_BOOTTIME based times.  This isn't 100% bulletproof
because the offset between the two clocks can vary between the moment the
frame was received by the kernel and the time we read the offset.  The
probability is very low though and we have no better solution at this
time other than fixing it in the kernel.  Using CLOCK_REALTIME for frame
reception timestamps seems to only create potential for problems in the
common usages.

Fixes: c78ad1bb6d7e ("dhcp: Set lease expiry based on frame reception times=
")
---
 ell/dhcp-transport.c  |  8 +++++++-
 ell/dhcp6-transport.c | 12 +++++++++---
 ell/icmp6.c           |  7 ++++++-
 ell/time-private.h    |  1 +
 ell/time.c            | 17 +++++++++++++++++
 5 files changed, 40 insertions(+), 5 deletions(-)

diff --git a/ell/dhcp-transport.c b/ell/dhcp-transport.c
index 52da2db..ba1423f 100644
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
@@ -170,7 +171,12 @@ static bool _dhcp_default_transport_read_handler(struc=
t l_io *io,
 				CMSG_LEN(sizeof(struct timeval))) {
 			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
 =

-			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
+			/*
+			 * Not ideal but this is our best approximation of the
+			 * CLOCK_BOOTTIME-based Rx time.
+			 */
+			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec -
+				_time_get_realtime_boottime_offset();
 		}
 	}
 =

diff --git a/ell/dhcp6-transport.c b/ell/dhcp6-transport.c
index 13545b8..2bbdf8e 100644
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
@@ -81,9 +82,14 @@ static bool _dhcp6_default_transport_read_handler(struct=
 l_io *io,
 				cmsg->cmsg_type =3D=3D SCM_TIMESTAMP &&
 				cmsg->cmsg_len =3D=3D
 				CMSG_LEN(sizeof(struct timeval))) {
-		const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
-
-			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
+			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
+
+			/*
+			 * Not ideal but this is our best approximation of the
+			 * CLOCK_BOOTTIME-based Rx time.
+			 */
+			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec -
+				_time_get_realtime_boottime_offset();
 		}
 	}
 =

diff --git a/ell/icmp6.c b/ell/icmp6.c
index 96ba1ec..56019fc 100644
--- a/ell/icmp6.c
+++ b/ell/icmp6.c
@@ -249,7 +249,12 @@ static int icmp6_receive(int s, void *buf, size_t buf_=
len, struct in6_addr *src,
 				CMSG_LEN(sizeof(struct timeval))) {
 			const struct timeval *tv =3D (void *) CMSG_DATA(cmsg);
 =

-			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec;
+			/*
+			 * Not ideal but this is our best approximation of the
+			 * CLOCK_BOOTTIME-based Rx time.
+			 */
+			timestamp =3D tv->tv_sec * L_USEC_PER_SEC + tv->tv_usec -
+				_time_get_realtime_boottime_offset();
 		}
 	}
 =

diff --git a/ell/time-private.h b/ell/time-private.h
index dc4d6c2..8ff581b 100644
--- a/ell/time-private.h
+++ b/ell/time-private.h
@@ -23,3 +23,4 @@
 uint64_t _time_pick_interval_secs(uint32_t min_secs, uint32_t max_secs);
 uint64_t _time_fuzz_msecs(uint64_t ms);
 uint64_t _time_fuzz_secs(uint32_t secs, uint32_t max_offset);
+int64_t _time_get_realtime_boottime_offset(void);
diff --git a/ell/time.c b/ell/time.c
index d02dabe..cda09be 100644
--- a/ell/time.c
+++ b/ell/time.c
@@ -105,3 +105,20 @@ uint64_t _time_fuzz_secs(uint32_t secs, uint32_t max_o=
ffset)
 =

 	return ms;
 }
+
+/*
+ * Get approximate difference between CLOCK_REALTIME and CLOCK_BOOTTIME,
+ * for converting recent timestamps from one to the other.  The value can
+ * change at any time.
+ */
+int64_t _time_get_realtime_boottime_offset(void)
+{
+	struct timespec boottime;
+	struct timespec realtime;
+
+	clock_gettime(CLOCK_BOOTTIME, &boottime);
+	clock_gettime(CLOCK_REALTIME, &realtime);
+
+	return ((int64_t) realtime.tv_sec - boottime.tv_sec) * 1000000 +
+		((int64_t) realtime.tv_nsec - boottime.tv_nsec) / 1000;
+}
-- =

2.32.0

--===============9087121863617484325==--

