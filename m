Content-Type: multipart/mixed; boundary="===============7637355392034771193=="
MIME-Version: 1.0
From: Peter Seiderer <ps.report@gmx.net>
Subject: [PATCH v1] ell/ell.sym: add missing l_genl_family_set_unicast_handler
Date: Sat, 10 Nov 2018 00:02:02 +0100
Message-ID: <20181109230202.954-1-ps.report@gmx.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7637355392034771193==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Fixes iwd compile failure:

  src/netdev.o: In function `netdev_set_nl80211':
  netdev.c:(.text+0x6f04): undefined reference to `l_genl_family_set_unicas=
t_handler'

Signed-off-by: Peter Seiderer <ps.report@gmx.net>
---
 ell/ell.sym | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/ell.sym b/ell/ell.sym
index 614bc93..cdd2c21 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -257,6 +257,7 @@ global:
 	l_genl_family_new;
 	l_genl_family_ref;
 	l_genl_family_unref;
+	l_genl_family_set_unicast_handler;
 	l_genl_family_set_watches;
 	l_genl_family_get_version;
 	l_genl_family_get_genl;
-- =

2.19.1


--===============7637355392034771193==--

