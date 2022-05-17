Content-Type: multipart/mixed; boundary="===============7345360280021020038=="
MIME-Version: 1.0
From: Michael Johnson <mjohnson459 at gmail.com>
To: ell at lists.01.org
Subject: [PATCH v2 2/3] examples: Pass in max logging level
Date: Tue, 17 May 2022 17:56:37 +0100
Message-ID: <20220517165638.139029-2-mjohnson459@gmail.com>
In-Reply-To: 20220517165638.139029-1-mjohnson459@gmail.com

--===============7345360280021020038==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 examples/dhcp-client.c    | 2 +-
 examples/netconfig-test.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/examples/dhcp-client.c b/examples/dhcp-client.c
index 0a16ce4..9dcea57 100644
--- a/examples/dhcp-client.c
+++ b/examples/dhcp-client.c
@@ -107,7 +107,7 @@ int main(int argc, char *argv[])
 	client =3D l_dhcp_client_new(ifindex);
 	l_dhcp_client_set_address(client, ARPHRD_ETHER, mac, 6);
 	l_dhcp_client_set_event_handler(client, event_handler, NULL, NULL);
-	l_dhcp_client_set_debug(client, do_debug, "[DHCP] ", NULL);
+	l_dhcp_client_set_debug(client, do_debug, "[DHCP] ", NULL, L_LOG_DEBUG);
 	l_dhcp_client_start(client);
 =

 	l_main_run_with_signal(signal_handler, NULL);
diff --git a/examples/netconfig-test.c b/examples/netconfig-test.c
index c9d02ab..d75e4ad 100644
--- a/examples/netconfig-test.c
+++ b/examples/netconfig-test.c
@@ -195,7 +195,7 @@ int main(int argc, char *argv[])
 	netconfig =3D l_netconfig_new(ifindex);
 	l_netconfig_set_event_handler(netconfig, event_handler, NULL, NULL);
 	l_dhcp_client_set_debug(l_netconfig_get_dhcp_client(netconfig),
-				do_debug, "[DHCPv4] ", NULL);
+				do_debug, "[DHCPv4] ", NULL, L_LOG_DEBUG);
 	l_netconfig_start(netconfig);
 =

 	l_main_run_with_signal(signal_handler, NULL);
-- =

2.25.1

--===============7345360280021020038==--

