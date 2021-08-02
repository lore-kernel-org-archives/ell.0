Content-Type: multipart/mixed; boundary="===============8206869983018284007=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 13/15] dhcp-server: Rapid commit enable/disable setter
Date: Mon, 02 Aug 2021 16:04:22 +0200
Message-ID: <20210802140424.170150-13-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8206869983018284007==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dhcp-server.c | 14 +++++++++++++-
 ell/dhcp.h        |  2 ++
 ell/ell.sym       |  1 +
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 971bc54..f92807a 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -89,6 +89,7 @@ struct l_dhcp_server {
 	struct l_acd *acd;
 =

 	bool authoritative : 1;
+	bool rapid_commit : 1;
 };
 =

 #define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
@@ -781,7 +782,7 @@ static void listener_event(const void *data, size_t len=
, void *user_data)
 		if (!server_id_match)
 			break;
 =

-		if (rapid_commit_opt) {
+		if (rapid_commit_opt && server->rapid_commit) {
 			lease =3D l_dhcp_server_discover(server, requested_ip_opt,
 							client_id_opt,
 							message->chaddr);
@@ -966,6 +967,7 @@ LIB_EXPORT struct l_dhcp_server *l_dhcp_server_new(int =
ifindex)
 =

 	server->started =3D false;
 	server->authoritative =3D true;
+	server->rapid_commit =3D true;
 =

 	server->lease_seconds =3D DEFAULT_DHCP_LEASE_SEC;
 	server->max_expired =3D MAX_EXPIRED_LEASES;
@@ -1308,6 +1310,16 @@ LIB_EXPORT void l_dhcp_server_set_authoritative(stru=
ct l_dhcp_server *server,
 	server->authoritative =3D authoritative;
 }
 =

+LIB_EXPORT void l_dhcp_server_set_enable_rapid_commit(
+						struct l_dhcp_server *server,
+						bool enable)
+{
+	if (unlikely(!server))
+		return;
+
+	server->rapid_commit =3D enable;
+}
+
 LIB_EXPORT struct l_dhcp_lease *l_dhcp_server_discover(
 						struct l_dhcp_server *server,
 						uint32_t requested_ip_opt,
diff --git a/ell/dhcp.h b/ell/dhcp.h
index 58deb7e..5873c90 100644
--- a/ell/dhcp.h
+++ b/ell/dhcp.h
@@ -143,6 +143,8 @@ bool l_dhcp_server_set_gateway(struct l_dhcp_server *se=
rver, const char *ip);
 bool l_dhcp_server_set_dns(struct l_dhcp_server *server, char **dns);
 void l_dhcp_server_set_authoritative(struct l_dhcp_server *server,
 					bool authoritative);
+void l_dhcp_server_set_enable_rapid_commit(struct l_dhcp_server *server,
+						bool enable);
 =

 struct l_dhcp_lease *l_dhcp_server_discover(struct l_dhcp_server *server,
 						uint32_t requested_ip_opt,
diff --git a/ell/ell.sym b/ell/ell.sym
index a781dea..b29d98d 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -260,6 +260,7 @@ global:
 	l_dhcp_server_set_gateway;
 	l_dhcp_server_set_dns;
 	l_dhcp_server_set_authoritative;
+	l_dhcp_server_set_enable_rapid_commit;
 	l_dhcp_server_discover;
 	l_dhcp_server_request;
 	l_dhcp_server_decline;
-- =

2.30.2

--===============8206869983018284007==--

