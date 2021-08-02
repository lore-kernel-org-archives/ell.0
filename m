Content-Type: multipart/mixed; boundary="===============2620269987812575342=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH 11/15] dhcp: Support RFC4039 Rapid Commit
Date: Mon, 02 Aug 2021 16:04:20 +0200
Message-ID: <20210802140424.170150-11-andrew.zaborowski@intel.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2620269987812575342==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use the RFC4039 Rapid Commit option in the DHCPDISCOVERY to attempt to
get the server to directly reply with a DHCPACK, i.e. skipping the
DHCPOFFER and DHCPREQUEST roundtrip.

Currently enabled unconditionally, the support can be made optional if
needed in the future.
---
 ell/dhcp-private.h |  1 +
 ell/dhcp-util.c    |  4 +++-
 ell/dhcp.c         | 14 ++++++++++++++
 3 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
index f9c0c6f..5a09f5e 100644
--- a/ell/dhcp-private.h
+++ b/ell/dhcp-private.h
@@ -65,6 +65,7 @@ enum dhcp_option_overload {
 #define DHCP_OPTION_PARAMETER_REQUEST_LIST 55 /* Section 9.8 */
 #define DHCP_OPTION_MAXIMUM_MESSAGE_SIZE 57 /* Section 9.10 */
 #define DHCP_OPTION_CLIENT_IDENTIFIER 61 /* Section 9.14 */
+#define DHCP_OPTION_RAPID_COMMIT 80 /* RFC 4039 Section 4 */
 =

 /* RFC 2131, Figure 2 */
 #define DHCP_FLAG_BROADCAST (1 << 15)
diff --git a/ell/dhcp-util.c b/ell/dhcp-util.c
index d4d715a..e5c88b2 100644
--- a/ell/dhcp-util.c
+++ b/ell/dhcp-util.c
@@ -73,7 +73,9 @@ bool _dhcp_message_builder_append(struct dhcp_message_bui=
lder *builder,
 =

 		builder->pos[0] =3D code;
 		builder->pos[1] =3D optlen;
-		memcpy(builder->pos + 2, optval, optlen);
+
+		if (optlen)
+			memcpy(builder->pos + 2, optval, optlen);
 =

 		builder->pos +=3D optlen + 2;
 		break;
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

--===============2620269987812575342==--

