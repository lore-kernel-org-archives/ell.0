Content-Type: multipart/mixed; boundary="===============8569537245704168904=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 10/15] dhcp-server: Allow reactivating expired leases
Date: Mon, 02 Aug 2021 16:04:19 +0200
Message-ID: <20210802140424.170150-10-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8569537245704168904==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Allow clients to reactivate leases from server->expired_list by using a
DHCPREQUEST.  This will allow users of the API to mark addressses owned
by disconnecting clients as okay to be recycled by using
l_dhcp_server_expire_by_mac().  If the client that saves its leases
reconnects before we run out of address space, they will reactivate
their address be going through the standard "reusing a previously
allocated network address" procedure (DHCPREQUEST/DHCPACK).  This may
make sense for wireless access points where we know exactly when a
client disconnects, and where a combination of poor signal strength and
MAC randomization (and no Client ID support) could lead to a lot of
addresses being allocated quickly.  Combined with IP allocation during
the 802.11 4-Way Handshake, unused IPs could be handed out even faster.
---
 ell/dhcp-server.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
index 0183c20..506bb7d 100644
--- a/ell/dhcp-server.c
+++ b/ell/dhcp-server.c
@@ -797,6 +797,17 @@ static void listener_event(const void *data, size_t le=
n, void *user_data)
 			break;
 		}
 =

+		/*
+		 * As an extension, check if we have an expired lease matching
+		 * the requested IP and the client ID/mac and if so, allow the
+		 * lease to be re-activated.
+		 */
+		if (!lease && requested_ip_opt)
+			lease =3D find_lease_by_id_and_ip(server->expired_list,
+							client_id_opt,
+							message->chaddr,
+							requested_ip_opt);
+
 		/*
 		 * RFC2131 Section 3.5: "If the selected server is unable to
 		 * satisfy the DHCPREQUEST message (...), the server SHOULD
-- =

2.30.2

--===============8569537245704168904==--

