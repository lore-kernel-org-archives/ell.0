Content-Type: multipart/mixed; boundary="===============8650917098153573335=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 1/2] dbus: Fix disconnect watch with unique bus names
Date: Wed, 09 Nov 2016 03:51:33 +0100
Message-ID: <1478659894-7142-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8650917098153573335==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Make the dbus-name-cache, service watches and disconnect watches work
with unique bus names.  Problem spotted by Daniel Wagner and culprit
pointed out by Denis Kenzior.
---
 ell/dbus-name-cache.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/ell/dbus-name-cache.c b/ell/dbus-name-cache.c
index 0c2e08e..cb6a516 100644
--- a/ell/dbus-name-cache.c
+++ b/ell/dbus-name-cache.c
@@ -178,9 +178,6 @@ void _dbus_name_cache_notify(struct _dbus_name_cache *c=
ache,
 	if (!cache)
 		return;
 =

-	if (_dbus_parse_unique_name(name, NULL))
-		return;
-
 	entry =3D l_hashmap_lookup(cache->names, name);
 =

 	if (!entry)
-- =

2.7.4


--===============8650917098153573335==--

