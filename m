Content-Type: multipart/mixed; boundary="===============2893815754852837037=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 8/8] dhcp: Support RFC4039 Rapid Commit
Date: Fri, 23 Jul 2021 20:23:31 +0200
Message-ID: <20210723182331.135123-8-andrew.zaborowski@intel.com>
In-Reply-To: <20210723182331.135123-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2893815754852837037==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use the RFC4039 Rapid Commit option in the DHCPDISCOVERY to attempt to
get the server to directly reply with a DHCPACK, i.e. skipping the
DHCPOFFER and DHCPREQUEST roundtrip.

Currently enabled unconditionally, the support can be made optional if
needed in the future.
---
 ell/dhcp.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 115325e..2efbf39 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -361,6 +361,8 @@ static int dhcp_client_send_discover(struct l_dhcp_clie=
nt *client)
 						client->hostname))
 			return -EINVAL;
 =

+	_dhcp_message_builder_append(&builder, DHCP_OPTION_RAPID_COMMIT,
+					0, "");
 	_dhcp_message_builder_finalize(&builder, &len);
 =

 	return client->transport->l2_send(client->transport,
@@ -815,6 +817,17 @@ static void dhcp_client_rx_message(const void *data, s=
ize_t len, void *userdata)
 	case DHCP_STATE_INIT:
 		return;
 	case DHCP_STATE_SELECTING:
+		if (msg_type =3D=3D DHCP_MESSAGE_TYPE_ACK) {
+			_dhcp_message_iter_init(&iter, message, len);
+
+			while (_dhcp_message_iter_next(&iter, &t, &l, &v))
+				if (t =3D=3D DHCP_OPTION_RAPID_COMMIT) {
+					CLIENT_ENTER_STATE(
+							DHCP_STATE_REQUESTING);
+					goto receive_rapid_commit;
+				}
+		}
+
 		if (msg_type !=3D DHCP_MESSAGE_TYPE_OFFER)
 			return;
 =

@@ -835,6 +848,7 @@ static void dhcp_client_rx_message(const void *data, si=
ze_t len, void *userdata)
 	case DHCP_STATE_REQUESTING:
 	case DHCP_STATE_RENEWING:
 	case DHCP_STATE_REBINDING:
+	receive_rapid_commit:
 		if (msg_type =3D=3D DHCP_MESSAGE_TYPE_NAK) {
 			CLIENT_DEBUG("Received NAK, Stopping...");
 			l_dhcp_client_stop(client);
-- =

2.30.2

--===============2893815754852837037==--

