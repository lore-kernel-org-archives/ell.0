Content-Type: multipart/mixed; boundary="===============3503802919829049143=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH 2/2] log: Fix strict compiler warning for strncpy
Date: Fri, 07 Dec 2018 10:37:10 -0800
Message-ID: <20181207183710.20822-3-brian.gix@intel.com>
In-Reply-To: <20181207183710.20822-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3503802919829049143==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/log.c b/ell/log.c
index bc1be9f..f3f4b0c 100644
--- a/ell/log.c
+++ b/ell/log.c
@@ -86,7 +86,7 @@ static int open_log(const char *path)
 =

 	memset(&addr, 0, sizeof(addr));
 	addr.sun_family =3D AF_UNIX;
-	strncpy(addr.sun_path, path, sizeof(addr.sun_path));
+	strncpy(addr.sun_path, path, sizeof(addr.sun_path) - 1);
 =

 	if (connect(log_fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
 		close_log();
-- =

2.17.2


--===============3503802919829049143==--

