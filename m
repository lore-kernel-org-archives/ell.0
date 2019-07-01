Content-Type: multipart/mixed; boundary="===============2229044407209758983=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] genl: Correct bad l_genl_family_info free.
Date: Mon, 01 Jul 2019 13:14:45 -0700
Message-ID: <20190701201445.26343-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2229044407209758983==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/genl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index ea9d182..01e58dd 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -1181,7 +1181,7 @@ static void dump_family_callback(struct l_genl_msg *m=
sg, void *user_data)
 	discovery->cmd_id =3D 0;
 =

 	if (parse_cmd_newfamily(info, msg) < 0) {
-		family_info_free(&info);
+		family_info_free(info);
 		return;
 	}
 =

-- =

2.20.1


--===============2229044407209758983==--

