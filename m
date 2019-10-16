Content-Type: multipart/mixed; boundary="===============4096939391499012652=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH 2/2] dhcp: Move error handling
Date: Wed, 16 Oct 2019 15:14:58 -0700
Message-ID: <20191016221458.3175-2-tim.a.kourt@linux.intel.com>
In-Reply-To: <20191016221458.3175-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4096939391499012652==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

With a single use case of 'error' label, eliminate it and move the error ha=
ndling
into the block where it is used.
---
 ell/dhcp.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 132d973..2b7d472 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -941,8 +941,11 @@ static void dhcp_client_rx_message(const void *data, s=
ize_t len, void *userdata)
 		CLIENT_ENTER_STATE(DHCP_STATE_REQUESTING);
 		client->attempt =3D 1;
 =

-		if (dhcp_client_send_request(client) < 0)
-			goto error;
+		if (dhcp_client_send_request(client) < 0) {
+			l_dhcp_client_stop(client);
+
+			return;
+		}
 =

 		l_timeout_modify_ms(client->timeout_resend, dhcp_fuzz_secs(4));
 		break;
@@ -995,11 +998,6 @@ static void dhcp_client_rx_message(const void *data, s=
ize_t len, void *userdata)
 	case DHCP_STATE_BOUND:
 		break;
 	}
-
-	return;
-
-error:
-	l_dhcp_client_stop(client);
 }
 =

 LIB_EXPORT struct l_dhcp_client *l_dhcp_client_new(uint32_t ifindex)
-- =

2.13.6

--===============4096939391499012652==--

