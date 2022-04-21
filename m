Content-Type: multipart/mixed; boundary="===============8862082140462607798=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 12/12] rtnl: Fix l_rtnl_route_get_protocol
Date: Thu, 21 Apr 2022 17:45:25 +0200
Message-ID: <20220421154525.1416984-12-andrew.zaborowski@intel.com>
In-Reply-To: 20220421154525.1416984-1-andrew.zaborowski@intel.com

--===============8862082140462607798==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/rtnl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index 126fb9d..5464872 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -648,7 +648,7 @@ LIB_EXPORT uint8_t l_rtnl_route_get_protocol(const stru=
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

--===============8862082140462607798==--

