Content-Type: multipart/mixed; boundary="===============9121952829995902068=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 2/2] dhcp-server: Drop a redundant cast
Date: Wed, 03 Mar 2021 22:35:36 +0100
Message-ID: <20210303213536.808395-2-andrew.zaborowski@intel.com>
In-Reply-To: <20210303213536.808395-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9121952829995902068==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dhcp-server.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 68b6f13..67037cf 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -892,7 +892,7 @@ LIB_EXPORT bool l_dhcp_server_set_ip_range(struct l_dhc=
p_server *server,
 	if (unlikely(!server || !start_ip || !end_ip))
 		return false;
 =

-	if (inet_aton((const char *)start_ip, &_host_addr) =3D=3D 0)
+	if (inet_aton(start_ip, &_host_addr) =3D=3D 0)
 		return false;
 =

 	start =3D ntohl(_host_addr.s_addr);
-- =

2.27.0

--===============9121952829995902068==--

