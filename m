Content-Type: multipart/mixed; boundary="===============6900817121730894993=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@gmail.com>
Subject: [PATCH 1/2] genl: Add missing NLA_F_NESTED bit
Date: Mon, 30 Nov 2020 10:57:35 -0800
Message-ID: <20201130185736.30474-2-ossama.othman@intel.com>
In-Reply-To: <20201130185736.30474-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6900817121730894993==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Set the NLA_F_NESTED bit when entering a nested netlink attribute to
correct a "NLA_F_NESTED is missing" error exhibited by the kernel
under strict netlink attribute validation.
---
 ell/genl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index c17d337..a4f7252 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1714,7 +1714,7 @@ LIB_EXPORT bool l_genl_msg_enter_nested(struct l_genl=
_msg *msg, uint16_t type)
 	if (!msg_grow(msg, NLA_HDRLEN))
 		return false;
 =

-	msg->nests[msg->nesting_level].type =3D type;
+	msg->nests[msg->nesting_level].type =3D type | NLA_F_NESTED;
 	msg->nests[msg->nesting_level].offset =3D msg->len;
 	msg->nesting_level +=3D 1;
 =

-- =

2.25.1

--===============6900817121730894993==--

