Content-Type: multipart/mixed; boundary="===============2686399549702879463=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] log: Fix systemd journal PRIORITY field logging
Date: Thu, 09 Mar 2017 14:48:02 -0800
Message-ID: <1489099682-8621-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2686399549702879463==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When logging messages to the systemd journal the trailing line feed
character was truncated since the message length was incorrectly
reduced by one.  That resulted in the next systemd journal field, in
this case PRIORITY, being written as part of the logged message string
(e.g. "fooPRIORITY=3D6") rather than as a separate journal field.
---
 ell/log.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/log.c b/ell/log.c
index e6682cf..6a2e86b 100644
--- a/ell/log.c
+++ b/ell/log.c
@@ -214,7 +214,7 @@ static void log_journal(int priority, const char *file,=
 const char *line,
 	iov[0].iov_base =3D "MESSAGE=3D";
 	iov[0].iov_len  =3D 8;
 	iov[1].iov_base =3D str;
-	iov[1].iov_len  =3D str_len - 1;
+	iov[1].iov_len  =3D str_len;
 	iov[2].iov_base =3D prio;
 	iov[2].iov_len  =3D prio_len;
 	iov[3].iov_base =3D "CODE_FILE=3D";
-- =

2.7.4


--===============2686399549702879463==--

