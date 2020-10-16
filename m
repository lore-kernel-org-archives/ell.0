Content-Type: multipart/mixed; boundary="===============8466578323011795956=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 01/20] net: add l_net_get_address()
Date: Fri, 16 Oct 2020 08:36:16 -0700
Message-ID: <20201016153635.660391-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8466578323011795956==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/ell.sym |  1 +
 ell/net.c   | 34 ++++++++++++++++++++++++++++++++++
 ell/net.h   |  3 +++
 3 files changed, 38 insertions(+)

v2:
 * Renamed to l_net_get_address and changed to take in_addr out
   parameter rather than return the IP as a uint32_t.

diff --git a/ell/ell.sym b/ell/ell.sym
index 7108ce3..b3d5c71 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -368,6 +368,7 @@ global:
 	l_debug_enable_full;
 	l_debug_disable;
 	/* net */
+	l_net_get_address;
 	l_net_get_mac_address;
 	l_net_get_name;
 	l_net_hostname_is_root;
diff --git a/ell/net.c b/ell/net.c
index 0bff535..12e88d8 100644
--- a/ell/net.c
+++ b/ell/net.c
@@ -29,6 +29,7 @@
 #include <unistd.h>
 #include <errno.h>
 #include <sys/ioctl.h>
+#include <netinet/ip.h>
 =

 #include "net.h"
 #include "net-private.h"
@@ -336,3 +337,36 @@ char **net_domain_list_parse(const uint8_t *raw, size_=
t raw_len)
 =

 	return ret;
 }
+
+LIB_EXPORT bool l_net_get_address(int ifindex, struct in_addr *out)
+{
+	struct ifreq ifr;
+	int sk, err;
+	struct sockaddr_in *server_ip;
+	bool ret =3D false;
+
+	sk =3D socket(PF_INET, SOCK_DGRAM | SOCK_CLOEXEC, 0);
+	if (sk < 0)
+		return false;
+
+	memset(&ifr, 0, sizeof(ifr));
+	ifr.ifr_ifindex =3D ifindex;
+
+	err =3D ioctl(sk, SIOCGIFNAME, &ifr);
+	if (err < 0)
+		goto done;
+
+	err =3D ioctl(sk, SIOCGIFADDR, &ifr);
+	if (err < 0)
+		goto done;
+
+	server_ip =3D (struct sockaddr_in *) &ifr.ifr_addr;
+	out->s_addr =3D server_ip->sin_addr.s_addr;
+
+	ret =3D true;
+
+done:
+	close(sk);
+
+	return ret;
+}
diff --git a/ell/net.h b/ell/net.h
index 6808e07..178f13b 100644
--- a/ell/net.h
+++ b/ell/net.h
@@ -26,6 +26,8 @@
 #include <stdbool.h>
 #include <stdint.h>
 =

+struct in_addr;
+
 #ifdef __cplusplus
 extern "C" {
 #endif
@@ -34,6 +36,7 @@ bool l_net_get_mac_address(uint32_t ifindex, uint8_t *out=
_addr);
 char *l_net_get_name(uint32_t ifindex);
 bool l_net_hostname_is_root(const char *hostname);
 bool l_net_hostname_is_localhost(const char *hostname);
+bool l_net_get_address(int ifindex, struct in_addr *out);
 =

 #ifdef __cplusplus
 }
-- =

2.26.2

--===============8466578323011795956==--

