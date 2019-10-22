Content-Type: multipart/mixed; boundary="===============8205900230310318086=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] genl: Fix size calculation in msg_grow
Date: Tue, 22 Oct 2019 16:34:09 +0200
Message-ID: <20191022143409.21089-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8205900230310318086==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

"msg->size - needed" was the opposite of the value we actually need and
could end up being negative if we were appending an attribute larger
than the current message size.
---
 ell/genl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index 1260020..6177fd5 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -755,7 +755,7 @@ static bool msg_grow(struct l_genl_msg *msg, uint32_t n=
eeded)
 	if (msg->size >=3D msg->len + needed)
 		return true;
 =

-	grow_by =3D msg->size - needed;
+	grow_by =3D msg->len + needed - msg->size;
 =

 	if (grow_by < 32)
 		grow_by =3D 128;
-- =

2.20.1

--===============8205900230310318086==--

