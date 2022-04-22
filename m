Content-Type: multipart/mixed; boundary="===============8604863383832846679=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 12/13] rtnl: Fix l_rtnl_route_get_protocol
Date: Fri, 22 Apr 2022 20:59:51 +0200
Message-ID: <20220422185952.105279-12-andrew.zaborowski@intel.com>
In-Reply-To: 20220422185952.105279-1-andrew.zaborowski@intel.com

--===============8604863383832846679==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/rtnl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index 41b34d7..690fe7c 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -651,7 +651,7 @@ LIB_EXPORT uint8_t l_rtnl_route_get_protocol(const stru=
ct l_rtnl_route *rt)
 	if (unlikely(!rt))
 		return RTPROT_UNSPEC;
 =

-	return rt->scope;
+	return rt->protocol;
 }
 =

 LIB_EXPORT bool l_rtnl_route_set_protocol(struct l_rtnl_route *rt,
-- =

2.32.0

--===============8604863383832846679==--

