Content-Type: multipart/mixed; boundary="===============9158570972756326605=="
MIME-Version: 1.0
From: Patrik Flykt <patrik.flykt@linux.intel.com>
Subject: [PATCH] netlink: Allow NLM_F_DUMP on netlink requests
Date: Wed, 24 Sep 2014 12:13:36 +0300
Message-ID: <1411550016-7245-1-git-send-email-patrik.flykt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9158570972756326605==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

NLM_F_DUMP needs to be specified in cases where all existing network
interfaces are requested. As NLM_F_DUMP happens to be covered by the
current check for valid flags, update the check to allow the flag
being set by the caller.
---
 ell/netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/netlink.c b/ell/netlink.c
index d247173..79a2a00 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -396,7 +396,7 @@ LIB_EXPORT unsigned int l_netlink_send(struct l_netlink=
 *netlink,
 						!netlink->command_lookup)
 		return 0;
 =

-	if (flags & 0xff)
+	if (flags & 0xff & ~NLM_F_DUMP)
 		return 0;
 =

 	if (function)
-- =

1.9.1


--===============9158570972756326605==--

