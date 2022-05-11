Content-Type: multipart/mixed; boundary="===============1156743296253460702=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] dhcp: Use bound_time for retransmission timers
Date: Wed, 11 May 2022 12:28:55 -0500
Message-ID: <20220511172855.25992-1-denkenz@gmail.com>

--===============1156743296253460702==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

start_t is used to try and calculate the retransmission timeout value
when the client enters RENEWING or REBINDING state.  This works fine on
the first renewal since the client start timestamp and the lease bound
timestamp are very close.  Also, the RENEW request is sent immediately
whenever the T1 timer expires and most of the time it succeeds.

However, if this isn't a first renewal attempt and the RENEW request
sent when the T1 timer expires is not successful, then the renewal
timeout value could become too large.  Fix that by using the lease
bound_time for the retransmission timer calculation (as intended) intead
of the client start time (start_t).
---
 ell/dhcp.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/ell/dhcp.c b/ell/dhcp.c
index 2d049005a135..01900f3b1d38 100644
--- a/ell/dhcp.c
+++ b/ell/dhcp.c
@@ -520,6 +520,7 @@ static void dhcp_client_timeout_resend(struct l_timeout=
 *timeout,
 								void *user_data)
 {
 	struct l_dhcp_client *client =3D user_data;
+	struct l_dhcp_lease *lease =3D client->lease;
 	unsigned int next_timeout =3D 0;
 	int r;
 =

@@ -555,12 +556,12 @@ static void dhcp_client_timeout_resend(struct l_timeo=
ut *timeout,
 =

 	switch (client->state) {
 	case DHCP_STATE_RENEWING:
-		next_timeout =3D dhcp_rebind_renew_retry_time(client->start_t,
-							client->lease->t2);
+		next_timeout =3D dhcp_rebind_renew_retry_time(lease->bound_time,
+								lease->t2);
 		break;
 	case DHCP_STATE_REBINDING:
-		next_timeout =3D dhcp_rebind_renew_retry_time(client->start_t,
-						client->lease->lifetime);
+		next_timeout =3D dhcp_rebind_renew_retry_time(lease->bound_time,
+							lease->lifetime);
 		break;
 	case DHCP_STATE_REQUESTING:
 	case DHCP_STATE_SELECTING:
@@ -642,7 +643,7 @@ static void dhcp_client_t1_expired(struct l_timeout *ti=
meout, void *user_data)
 	l_timeout_set_callback(client->timeout_lease, dhcp_client_t2_expired,
 				client, NULL);
 =

-	next_timeout =3D dhcp_rebind_renew_retry_time(client->start_t,
+	next_timeout =3D dhcp_rebind_renew_retry_time(client->lease->bound_time,
 							client->lease->t2);
 	client->timeout_resend =3D
 		l_timeout_create_ms(dhcp_fuzz_secs(next_timeout),
-- =

2.32.0

--===============1156743296253460702==--

