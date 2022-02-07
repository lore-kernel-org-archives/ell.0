Content-Type: multipart/mixed; boundary="===============8193061951689634352=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: [PATCH 3/6] rtnl: Fix a return line in address_to_string
Date: Mon, 07 Feb 2022 16:07:14 +0100
Message-ID: <20220207150717.60511-3-andrew.zaborowski@intel.com>
In-Reply-To: 20220207150717.60511-1-andrew.zaborowski@intel.com

--===============8193061951689634352==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/rtnl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/rtnl.c b/ell/rtnl.c
index 5f0940b..293b797 100644
--- a/ell/rtnl.c
+++ b/ell/rtnl.c
@@ -71,7 +71,7 @@ static inline int address_to_string(int family, const str=
uct in_addr *v4,
 			return -errno;
 		break;
 	default:
-		return  false;
+		return -EAFNOSUPPORT;
 	}
 =

 	return 0;
-- =

2.32.0

--===============8193061951689634352==--

