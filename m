Content-Type: multipart/mixed; boundary="===============8460768018366971140=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 01/14] net: add l_net_get_ip_address()
Date: Thu, 15 Oct 2020 10:17:18 -0700
Message-ID: <20201015171731.396538-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8460768018366971140==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/net.c | 32 ++++++++++++++++++++++++++++++++
 ell/net.h |  1 +
 2 files changed, 33 insertions(+)

diff --git a/ell/net.c b/ell/net.c
index 0bff535..5551779 100644
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
@@ -336,3 +337,34 @@ char **net_domain_list_parse(const uint8_t *raw, size_=
t raw_len)
 =

 	return ret;
 }
+
+LIB_EXPORT uint32_t l_net_get_ip_address(int ifindex)
+{
+	struct ifreq ifr;
+	int sk, err;
+	struct sockaddr_in *server_ip;
+	uint32_t ret =3D 0;
+
+	sk =3D socket(PF_INET, SOCK_DGRAM | SOCK_CLOEXEC, 0);
+	if (sk < 0)
+		return 0;
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
+	ret =3D server_ip->sin_addr.s_addr;
+
+done:
+	close(sk);
+
+	return ret;
+}
diff --git a/ell/net.h b/ell/net.h
index 6808e07..abaf785 100644
--- a/ell/net.h
+++ b/ell/net.h
@@ -34,6 +34,7 @@ bool l_net_get_mac_address(uint32_t ifindex, uint8_t *out=
_addr);
 char *l_net_get_name(uint32_t ifindex);
 bool l_net_hostname_is_root(const char *hostname);
 bool l_net_hostname_is_localhost(const char *hostname);
+uint32_t l_net_get_ip_address(int ifindex);
 =

 #ifdef __cplusplus
 }
-- =

2.26.2

--===============8460768018366971140==--

