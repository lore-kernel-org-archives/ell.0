Content-Type: multipart/mixed; boundary="===============3119480316209972606=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 5/5] acd: stop ACD if l_acd_destroy is called
Date: Tue, 08 Dec 2020 10:42:28 -0800
Message-ID: <20201208184228.751111-5-prestwoj@gmail.com>
In-Reply-To: <20201208184228.751111-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3119480316209972606==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/acd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/acd.c b/ell/acd.c
index e80e322..6381747 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -511,6 +511,8 @@ LIB_EXPORT void l_acd_destroy(struct l_acd *acd)
 	if (unlikely(!acd))
 		return;
 =

+	l_acd_stop(acd);
+
 	if (acd->destroy)
 		acd->destroy(acd->user_data);
 =

-- =

2.26.2

--===============3119480316209972606==--

