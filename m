Content-Type: multipart/mixed; boundary="===============8820905432985498259=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 3/4] settings: Clear values in unescape_value on error
Date: Tue, 19 Mar 2019 01:48:42 +0100
Message-ID: <20190319004843.13451-3-andrew.zaborowski@intel.com>
In-Reply-To: <20190319004843.13451-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8820905432985498259==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Clear the beginnings of strings loaded from file that later failed
parsing.
---
 ell/settings.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/settings.c b/ell/settings.c
index 98823a2..3b79431 100644
--- a/ell/settings.c
+++ b/ell/settings.c
@@ -139,6 +139,7 @@ static char *unescape_value(const char *value)
 			*n =3D '\\';
 			break;
 		default:
+			explicit_bzero(ret, n - ret);
 			l_free(ret);
 			return NULL;
 		}
-- =

2.19.1


--===============8820905432985498259==--

