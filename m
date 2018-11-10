Content-Type: multipart/mixed; boundary="===============3684228295475797758=="
MIME-Version: 1.0
From: Peter Seiderer <ps.report@gmx.net>
Subject: [PATCH v2] ell/ell.sym: add missing l_genl_family_set_unicast_handler
Date: Sat, 10 Nov 2018 18:44:47 +0100
Message-ID: <20181110174447.4226-1-ps.report@gmx.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3684228295475797758==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Add l_genl_family_set_unicast_handler (and remove legacy
l_genl_set_unicast_handler).

Fixes iwd compile failure:

  src/netdev.o: In function `netdev_set_nl80211':
  netdev.c:(.text+0x6f04): undefined reference to `l_genl_family_set_unicas=
t_handler'
---
Changes v1 -> v2:
  - remove legacy l_genl_set_unicast_handler (suggested by Marcel Holtmann)
  - remove Signed-off-by line (suggested by Marcel Holtmann )
---
 ell/ell.sym | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/ell.sym b/ell/ell.sym
index 614bc93..c21fb21 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -239,7 +239,6 @@ global:
 	l_genl_unref;
 	l_genl_set_debug;
 	l_genl_set_close_on_unref;
-	l_genl_set_unicast_handler;
 	l_genl_msg_new;
 	l_genl_msg_new_sized;
 	l_genl_msg_ref;
@@ -257,6 +256,7 @@ global:
 	l_genl_family_new;
 	l_genl_family_ref;
 	l_genl_family_unref;
+	l_genl_family_set_unicast_handler;
 	l_genl_family_set_watches;
 	l_genl_family_get_version;
 	l_genl_family_get_genl;
-- =

2.19.1


--===============3684228295475797758==--

