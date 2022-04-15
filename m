Content-Type: multipart/mixed; boundary="===============1844133353794564702=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 1/8] dhcp6-lease: Make getters argument const, cleanup
Date: Fri, 15 Apr 2022 20:32:04 +0200
Message-ID: <20220415183211.987345-1-andrew.zaborowski@intel.com>

--===============1844133353794564702==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add "const" to the lifetime getters argument, drop dhcp6-private.h
declarations I probably added/renamed by mistake.
---
 ell/dhcp6-lease.c   | 13 +++++++------
 ell/dhcp6-private.h |  7 ++-----
 ell/dhcp6.h         |  7 ++++---
 3 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/ell/dhcp6-lease.c b/ell/dhcp6-lease.c
index 6109af1..978176a 100644
--- a/ell/dhcp6-lease.c
+++ b/ell/dhcp6-lease.c
@@ -373,7 +373,7 @@ LIB_EXPORT uint8_t l_dhcp6_lease_get_prefix_length(
 }
 =

 #define PICK_IA() \
-	struct dhcp6_ia *ia;		\
+	const struct dhcp6_ia *ia;	\
 					\
 	if (lease->have_na)		\
 		ia =3D &lease->ia_na;	\
@@ -382,7 +382,7 @@ LIB_EXPORT uint8_t l_dhcp6_lease_get_prefix_length(
 	else				\
 		return 0		\
 =

-uint32_t _dhcp6_lease_get_t1(struct l_dhcp6_lease *lease)
+uint32_t _dhcp6_lease_get_t1(const struct l_dhcp6_lease *lease)
 {
 	PICK_IA();
 =

@@ -395,7 +395,7 @@ uint32_t _dhcp6_lease_get_t1(struct l_dhcp6_lease *leas=
e)
 	return ia->info.valid_lifetime / 2;
 }
 =

-uint32_t _dhcp6_lease_get_t2(struct l_dhcp6_lease *lease)
+uint32_t _dhcp6_lease_get_t2(const struct l_dhcp6_lease *lease)
 {
 	PICK_IA();
 =

@@ -409,7 +409,7 @@ uint32_t _dhcp6_lease_get_t2(struct l_dhcp6_lease *leas=
e)
 }
 =

 LIB_EXPORT uint32_t l_dhcp6_lease_get_valid_lifetime(
-						struct l_dhcp6_lease *lease)
+					const struct l_dhcp6_lease *lease)
 {
 	if (unlikely(!lease))
 		return 0;
@@ -421,7 +421,7 @@ LIB_EXPORT uint32_t l_dhcp6_lease_get_valid_lifetime(
 }
 =

 LIB_EXPORT uint32_t l_dhcp6_lease_get_preferred_lifetime(
-						struct l_dhcp6_lease *lease)
+					const struct l_dhcp6_lease *lease)
 {
 	if (unlikely(!lease))
 		return 0;
@@ -433,7 +433,8 @@ LIB_EXPORT uint32_t l_dhcp6_lease_get_preferred_lifetim=
e(
 }
 =

 /* Get the reception timestamp, i.e. when lifetimes are counted from */
-LIB_EXPORT uint64_t l_dhcp6_lease_get_start_time(struct l_dhcp6_lease *lea=
se)
+LIB_EXPORT uint64_t l_dhcp6_lease_get_start_time(
+					const struct l_dhcp6_lease *lease)
 {
 	if (unlikely(!lease))
 		return 0;
diff --git a/ell/dhcp6-private.h b/ell/dhcp6-private.h
index 52f4002..6b33e34 100644
--- a/ell/dhcp6-private.h
+++ b/ell/dhcp6-private.h
@@ -148,8 +148,5 @@ void _dhcp6_lease_free(struct l_dhcp6_lease *lease);
 struct l_dhcp6_lease *_dhcp6_lease_parse_options(
 					struct dhcp6_option_iter *iter,
 					const uint8_t expected_iaid[static 4]);
-uint32_t _dhcp6_lease_get_t1(struct l_dhcp6_lease *lease);
-uint32_t _dhcp6_lease_get_t2(struct l_dhcp6_lease *lease);
-uint32_t dhcp6_lease_get_valid_lifetime(struct l_dhcp6_lease *lease);
-uint32_t dhcp6_lease_get_preferred_lifetime(struct l_dhcp6_lease *lease);
-uint32_t dhcp6_lease_get_start_time(struct l_dhcp6_lease *lease);
+uint32_t _dhcp6_lease_get_t1(const struct l_dhcp6_lease *lease);
+uint32_t _dhcp6_lease_get_t2(const struct l_dhcp6_lease *lease);
diff --git a/ell/dhcp6.h b/ell/dhcp6.h
index 9819fad..5086a74 100644
--- a/ell/dhcp6.h
+++ b/ell/dhcp6.h
@@ -94,9 +94,10 @@ char *l_dhcp6_lease_get_address(const struct l_dhcp6_lea=
se *lease);
 char **l_dhcp6_lease_get_dns(const struct l_dhcp6_lease *lease);
 char **l_dhcp6_lease_get_domains(const struct l_dhcp6_lease *lease);
 uint8_t l_dhcp6_lease_get_prefix_length(const struct l_dhcp6_lease *lease);
-uint32_t l_dhcp6_lease_get_valid_lifetime(struct l_dhcp6_lease *lease);
-uint32_t l_dhcp6_lease_get_preferred_lifetime(struct l_dhcp6_lease *lease);
-uint64_t l_dhcp6_lease_get_start_time(struct l_dhcp6_lease *lease);
+uint32_t l_dhcp6_lease_get_valid_lifetime(const struct l_dhcp6_lease *leas=
e);
+uint32_t l_dhcp6_lease_get_preferred_lifetime(
+					const struct l_dhcp6_lease *lease);
+uint64_t l_dhcp6_lease_get_start_time(const struct l_dhcp6_lease *lease);
 =

 #ifdef __cplusplus
 }
-- =

2.32.0

--===============1844133353794564702==--

