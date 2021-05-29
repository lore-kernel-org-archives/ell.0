Content-Type: multipart/mixed; boundary="===============0870142512921851919=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] rtnl: Add l_rtnl_address_dup
Date: Sat, 29 May 2021 02:03:19 +0200
Message-ID: <20210529000319.2897056-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0870142512921851919==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Returns a new l_rtnl_address that is a copy of the one passed in
parameter.
---
 ell/rtnl.c | 6 ++++++
 ell/rtnl.h | 1 +
 2 files changed, 7 insertions(+)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index e2996a6..2f26f6f 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -146,6 +146,12 @@ LIB_EXPORT struct l_rtnl_address *l_rtnl_address_new(c=
onst char *ip,
 	return addr;
 }
 =

+LIB_EXPORT struct l_rtnl_address *l_rtnl_address_dup(
+					const struct l_rtnl_address *orig)
+{
+	return l_memdup(orig, sizeof(struct l_rtnl_address));
+}
+
 LIB_EXPORT void l_rtnl_address_free(struct l_rtnl_address *addr)
 {
 	l_free(addr);
diff --git a/ell/rtnl.h b/ell/rtnl.h
index 2735dd2..036db0a 100644
--- a/ell/rtnl.h
+++ b/ell/rtnl.h
@@ -34,6 +34,7 @@ struct l_rtnl_address;
 struct l_rtnl_route;
 =

 struct l_rtnl_address *l_rtnl_address_new(const char *ip, uint8_t prefix_l=
en);
+struct l_rtnl_address *l_rtnl_address_dup(const struct l_rtnl_address *ori=
g);
 void l_rtnl_address_free(struct l_rtnl_address *addr);
 bool l_rtnl_address_get_address(const struct l_rtnl_address *addr,
 				char *out_buf);
-- =

2.27.0

--===============0870142512921851919==--

