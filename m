Content-Type: multipart/mixed; boundary="===============5194414097557937520=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH v3 4/5] main: Remove unnecessary error check
Date: Thu, 17 Mar 2016 11:15:41 -0700
Message-ID: <1458238542-11711-4-git-send-email-mathew.j.martineau@linux.intel.com>
In-Reply-To: <1458238542-11711-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5194414097557937520==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

l_queue_new() cannot fail, so there's no need to check for NULL or do
other cleanup.
---
 ell/main.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/ell/main.c b/ell/main.c
index 6143a42..46e929a 100644
--- a/ell/main.c
+++ b/ell/main.c
@@ -100,8 +100,6 @@ static inline bool __attribute__ ((always_inline)) crea=
te_epoll(void)
 		goto close_epoll;
 =

 	idle_list =3D l_queue_new();
-	if (!idle_list)
-		goto free_watch_list;
 =

 	idle_id =3D 0;
 =

@@ -112,10 +110,6 @@ static inline bool __attribute__ ((always_inline)) cre=
ate_epoll(void)
 =

 	return true;
 =

-free_watch_list:
-	free(watch_list);
-	watch_list =3D NULL;
-
 close_epoll:
 	close(epoll_fd);
 	epoll_fd =3D 0;
-- =

2.7.3


--===============5194414097557937520==--

