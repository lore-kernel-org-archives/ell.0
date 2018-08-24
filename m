Content-Type: multipart/mixed; boundary="===============8145885374233045554=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH] examples: dhcp_client: fix compile error
Date: Fri, 24 Aug 2018 09:37:08 -0700
Message-ID: <1535128628-18528-1-git-send-email-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8145885374233045554==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When building dhcp_client, it appears that including linux/if_arp.h
requires sys/socket.h for the sockaddr definition (at least on my
system). I fixed the same issue with ell/net.c but never build
dhcp_client. Below is one of the errors I saw when building:

In file included from /usr/include/linux/netdevice.h:28,
                 from /usr/include/linux/if_arp.h:26,
                 from examples/dhcp-client.c:31:
/usr/include/linux/if.h:234:19: error: field =E2=80=98ifru_addr=E2=80=99 ha=
s incomplete type
   struct sockaddr ifru_addr;
---
 examples/dhcp-client.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/examples/dhcp-client.c b/examples/dhcp-client.c
index 550b82b..084f6aa 100644
--- a/examples/dhcp-client.c
+++ b/examples/dhcp-client.c
@@ -28,6 +28,7 @@
 #include <unistd.h>
 #include <stdlib.h>
 #include <assert.h>
+#include <sys/socket.h>
 #include <linux/if_arp.h>
 =

 #include <ell/ell.h>
-- =

2.7.4


--===============8145885374233045554==--

