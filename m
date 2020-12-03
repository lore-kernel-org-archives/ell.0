Content-Type: multipart/mixed; boundary="===============4290673983173395993=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 5/7] acd: add l_acd_set_skip_probes
Date: Thu, 03 Dec 2020 12:41:42 -0800
Message-ID: <20201203204144.480090-5-prestwoj@gmail.com>
In-Reply-To: <20201203204144.480090-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4290673983173395993==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow skipping the probe stage. Probes take a significant
amount of time, and in cases where the network is properly
configured (e.g. a DHCP server) there really isn't a need
for the probe stage.
---
 ell/acd.c   | 35 ++++++++++++++++++++++++++++++++++-
 ell/acd.h   |  1 +
 ell/ell.sym |  1 +
 3 files changed, 36 insertions(+), 1 deletion(-)

diff --git a/ell/acd.c b/ell/acd.c
index 8fa8d95..2c8d788 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -90,6 +90,8 @@ struct l_acd {
 	l_acd_debug_cb_t debug_handler;
 	l_acd_destroy_func_t debug_destroy;
 	void *debug_data;
+
+	bool skip_probes : 1;
 };
 =

 static int acd_open_socket(int ifindex)
@@ -409,7 +411,24 @@ LIB_EXPORT bool l_acd_start(struct l_acd *acd, const c=
har *ip)
 	l_io_set_read_handler(acd->io, acd_read_handler, acd, NULL);
 =

 	acd->ip =3D ntohl(ia.s_addr);
-	acd->state =3D ACD_STATE_PROBE;
+
+	/*
+	 * Optimization to allows skipping the probe stage. The RFC does not
+	 * mention allowing this, but probes take an eternity and would
+	 * drastically increase connection times for wifi/eth. It is still
+	 * recommended that probes be used for statically configured IP's where
+	 * no DHCP server is involved.
+	 */
+	if (acd->skip_probes) {
+		ACD_DEBUG("Skipping probes and sending announcements");
+
+		acd->retries =3D 1;
+
+		announce_wait_timeout(NULL, acd);
+
+		return true;
+	} else
+		acd->state =3D ACD_STATE_PROBE;
 =

 	delay =3D acd_random_delay_ms(PROBE_WAIT);
 =

@@ -484,3 +503,17 @@ LIB_EXPORT bool l_acd_set_debug(struct l_acd *acd,
 =

 	return true;
 }
+
+LIB_EXPORT bool l_acd_set_skip_probes(struct l_acd *acd, bool skip)
+{
+	if (unlikely(!acd))
+		return false;
+
+	/* ACD has already been started */
+	if (acd->io)
+		return false;
+
+	acd->skip_probes =3D skip;
+
+	return true;
+}
diff --git a/ell/acd.h b/ell/acd.h
index 21a6958..eba504d 100644
--- a/ell/acd.h
+++ b/ell/acd.h
@@ -50,6 +50,7 @@ bool l_acd_stop(struct l_acd *acd);
 void l_acd_destroy(struct l_acd *acd);
 bool l_acd_set_debug(struct l_acd *acd, l_acd_debug_cb_t function,
 			void *user_data, l_acd_destroy_func_t destory);
+bool l_acd_set_skip_probes(struct l_acd *acd, bool skip);
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.sym b/ell/ell.sym
index b029b8c..a566a83 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -661,6 +661,7 @@ global:
 	l_acd_stop;
 	l_acd_destroy;
 	l_acd_set_debug;
+	l_acd_set_skip_probes;
 local:
 	*;
 };
-- =

2.26.2

--===============4290673983173395993==--

