Content-Type: multipart/mixed; boundary="===============0599322951571841750=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 6/7] acd: add defend policy concept
Date: Thu, 03 Dec 2020 12:41:43 -0800
Message-ID: <20201203204144.480090-6-prestwoj@gmail.com>
In-Reply-To: <20201203204144.480090-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0599322951571841750==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The ACD RFC defines 3 possible policies for defending an address:

a) Give up address immediately (L_ACD_DEFEND_POLICY_NONE)
b) Send single annoucement (L_ACD_DEFEND_POLICY_DEFEND)
c) Defend infinitely (L_ACD_DEFEND_POLICY_INFINITE)

The policy can be set to a stopped/not started ACD object by
calling l_acd_set_defend_policy.

In the event of a lost address (a or b) ACD will be stopped and
the LOST event will be generated. If an infinite policy (c) is
used, the ACD client will not be stopped and no events will fire.
ACD will continue defending the address by sending sending a
single annoucement every 10 seconds while conflicting packets are
still being received.
---
 ell/acd.c   | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/acd.h   |  8 ++++++++
 ell/ell.sym |  1 +
 3 files changed, 68 insertions(+)

diff --git a/ell/acd.c b/ell/acd.c
index 2c8d788..ef72fef 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -78,6 +78,7 @@ struct l_acd {
 	uint8_t mac[ETH_ALEN];
 =

 	enum acd_state state;
+	enum l_acd_defend_policy policy;
 =

 	struct l_io *io;
 	struct l_timeout *timeout;
@@ -321,6 +322,25 @@ static bool acd_read_handler(struct l_io *io, void *us=
er_data)
 		if (!source_conflict)
 			return true;
 =

+		/*
+		 * RFC 5227 - Section 2.4 (a)
+		 *
+		 * "Upon receiving a conflicting ARP packet, a host MAY elect to
+		 * immediately cease using the address, and signal an error to
+		 * the configuring agent as described above."
+		 */
+		if (acd->policy =3D=3D L_ACD_DEFEND_POLICY_NONE) {
+			ACD_DEBUG("Conflict detected, giving up address");
+
+			if (acd->event_func)
+				acd->event_func(L_ACD_EVENT_LOST,
+							acd->user_data);
+
+			l_acd_stop(acd);
+
+			break;
+		}
+
 		/*
 		 * RFC 5227 - Section 2.4 (b)
 		 * [If the host] "has not seen any other conflicting ARP packets
@@ -352,6 +372,29 @@ static bool acd_read_handler(struct l_io *io, void *us=
er_data)
 		if (!source_conflict)
 			return true;
 =

+		/*
+		 * RFC 5227 Section 2.4 (c)
+		 * "If a host has been configured such that it should not give
+		 * up its address under any circumstances ... then it MAY elect
+		 * to defend its address indefinitely."
+		 */
+		if (acd->policy =3D=3D L_ACD_DEFEND_POLICY_INFINITE) {
+			ACD_DEBUG("Conflict "MAC" found with infinite policy",
+					MAC_STR(arp.arp_sha));
+
+			/*
+			 * Nothing to do at this point. We are in the DEFEND
+			 * state meaning there is a defend wait timeout pending.
+			 * Once that fires it will transition back into
+			 * ANNOUNCED. Once in ANNOUNCED and another conflict is
+			 * received, a single announcement will be sent. This
+			 * ensures a maximum of only 1 announcement every
+			 * DEFEND_INTERVAL seconds as long as conflicting
+			 * packets are being received.
+			 */
+			break;
+		}
+
 		l_timeout_remove(acd->timeout);
 		acd->timeout =3D NULL;
 =

@@ -380,6 +423,7 @@ LIB_EXPORT struct l_acd *l_acd_new(int ifindex)
 	struct l_acd *acd =3D l_new(struct l_acd, 1);
 =

 	acd->ifindex =3D ifindex;
+	acd->policy =3D L_ACD_DEFEND_POLICY_DEFEND;
 =

 	return acd;
 }
@@ -517,3 +561,18 @@ LIB_EXPORT bool l_acd_set_skip_probes(struct l_acd *ac=
d, bool skip)
 =

 	return true;
 }
+
+LIB_EXPORT bool l_acd_set_defend_policy(struct l_acd *acd,
+				enum l_acd_defend_policy policy)
+{
+	if (unlikely(!acd))
+		return false;
+
+	/* ACD has already been started */
+	if (acd->io)
+		return false;
+
+	acd->policy =3D policy;
+
+	return true;
+}
diff --git a/ell/acd.h b/ell/acd.h
index eba504d..f537536 100644
--- a/ell/acd.h
+++ b/ell/acd.h
@@ -37,6 +37,12 @@ enum l_acd_event {
 	L_ACD_EVENT_LOST,
 };
 =

+enum l_acd_defend_policy {
+	L_ACD_DEFEND_POLICY_NONE,	/* Never defend */
+	L_ACD_DEFEND_POLICY_DEFEND,	/* Default, defend once */
+	L_ACD_DEFEND_POLICY_INFINITE,	/* Defend indefinitely */
+};
+
 typedef void (*l_acd_event_func_t)(enum l_acd_event event, void *user_data=
);
 typedef void (*l_acd_destroy_func_t)(void *user_data);
 =

@@ -51,6 +57,8 @@ void l_acd_destroy(struct l_acd *acd);
 bool l_acd_set_debug(struct l_acd *acd, l_acd_debug_cb_t function,
 			void *user_data, l_acd_destroy_func_t destory);
 bool l_acd_set_skip_probes(struct l_acd *acd, bool skip);
+bool l_acd_set_defend_policy(struct l_acd *acd,
+				enum l_acd_defend_policy policy);
 #ifdef __cplusplus
 }
 #endif
diff --git a/ell/ell.sym b/ell/ell.sym
index a566a83..d94b585 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -662,6 +662,7 @@ global:
 	l_acd_destroy;
 	l_acd_set_debug;
 	l_acd_set_skip_probes;
+	l_acd_set_defend_policy;
 local:
 	*;
 };
-- =

2.26.2

--===============0599322951571841750==--

