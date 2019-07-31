Content-Type: multipart/mixed; boundary="===============3669837319439394705=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] dhcp: Decrease re-try delay after initial discovery message
Date: Wed, 31 Jul 2019 16:38:00 -0700
Message-ID: <20190731233800.18467-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3669837319439394705==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Some of the routers require =E2=80=98setup=E2=80=99 time between the moment=
 when
connection is established and before they are ready to respond to
the DHCP discovery messages. This used to cause the DHCP clients
to wait a full delay of +-4 seconds for the next attempt to
rediscover DHCP servers. To address this issue, the time delay
between the initial discovery message and its retransmission is
shorten to milliseconds to give enough time to the routers to get
ready and minimize the delay for the clients.
---
 ell/dhcp.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 57d5ae2..ca81311 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -485,6 +485,23 @@ static uint64_t dhcp_fuzz_secs(uint32_t secs)
 	return ms;
 }
 =

+/*
+ * Takes a time in milliseconds and produces a fuzzed value that can be di=
rectly
+ * used by l_timeout_modify_ms. The fluctuation of the random noise added =
is
+ * from -63 to 63 milliseconds.
+ */
+static uint64_t dhcp_fuzz_msecs(uint64_t ms)
+{
+	uint32_t r =3D l_getrandom_uint32();
+
+	if (r & 0x80000000)
+		ms +=3D r & 0x3f;
+	else
+		ms -=3D r & 0x3f;
+
+	return ms;
+}
+
 static uint32_t dhcp_rebind_renew_retry_time(uint64_t start_t, uint32_t ex=
piry)
 {
 	uint64_t now =3D l_time_now();
@@ -1191,7 +1208,7 @@ LIB_EXPORT bool l_dhcp_client_start(struct l_dhcp_cli=
ent *client)
 	if (err < 0)
 		return false;
 =

-	client->timeout_resend =3D l_timeout_create_ms(dhcp_fuzz_secs(4),
+	client->timeout_resend =3D l_timeout_create_ms(dhcp_fuzz_msecs(600),
 						dhcp_client_timeout_resend,
 						client, NULL);
 	CLIENT_ENTER_STATE(DHCP_STATE_SELECTING);
-- =

2.13.6


--===============3669837319439394705==--

