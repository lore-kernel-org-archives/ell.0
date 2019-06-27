Content-Type: multipart/mixed; boundary="===============4413626272797272638=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] genl: Deallocate genl family name
Date: Thu, 27 Jun 2019 12:03:02 -0700
Message-ID: <20190627190302.29035-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4413626272797272638==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/genl.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/genl.c b/ell/genl.c
index ea9d182..0f65db2 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -496,6 +496,7 @@ static void family_watch_free(void *data)
 	if (watch->destroy)
 		watch->destroy(watch->user_data);
 =

+	l_free(watch->name);
 	l_free(watch);
 }
 =

-- =

2.20.1


--===============4413626272797272638==--

