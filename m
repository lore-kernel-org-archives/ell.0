Content-Type: multipart/mixed; boundary="===============3011648191526128681=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH 1/2] dbus: fix strict compiler warnings for strncpy
Date: Fri, 07 Dec 2018 10:37:09 -0800
Message-ID: <20181207183710.20822-2-brian.gix@intel.com>
In-Reply-To: <20181207183710.20822-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3011648191526128681==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 55aee0e..5664f85 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -1128,7 +1128,7 @@ static struct l_dbus *setup_unix(char *params)
 		}
 =

 		addr.sun_path[0] =3D '\0';
-		strncpy(addr.sun_path + 1, path, len);
+		strncpy(addr.sun_path + 1, path, sizeof(addr.sun_path) - 2);
 		len++;
 	} else {
 		if (len > sizeof(addr.sun_path)) {
@@ -1136,7 +1136,7 @@ static struct l_dbus *setup_unix(char *params)
 			return NULL;
 		}
 =

-		strncpy(addr.sun_path, path, len);
+		strncpy(addr.sun_path, path, sizeof(addr.sun_path) - 1);
 	}
 =

 	if (connect(fd, (struct sockaddr *) &addr,
-- =

2.17.2


--===============3011648191526128681==--

