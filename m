Content-Type: multipart/mixed; boundary="===============3533064747954578159=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH] dhcp-lease: allow shorter lease times
Date: Thu, 05 Nov 2020 09:21:02 -0800
Message-ID: <20201105172102.2932758-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3533064747954578159==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

In practice a DHCP server shouldn't be handing out such
short leases, but for testing purposes its convenient having
short leases for testing renews.

The existing math for t1/t2 had integer rounding limitations
which prevented any leases under 8 seconds. Intead we can
use floating point math then case back to a uint32_t to
allow leases of 2 seconds or more.
---
 ell/dhcp-lease.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
index 59de3e3..8f73b0b 100644
--- a/ell/dhcp-lease.c
+++ b/ell/dhcp-lease.c
@@ -142,7 +142,7 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct d=
hcp_message_iter *iter)
 	if (!lease->server_address || !lease->lifetime)
 		goto error;
 =

-	if (lease->lifetime < 10)
+	if (lease->lifetime < 2)
 		goto error;
 =

 	/*
@@ -157,10 +157,10 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct=
 dhcp_message_iter *iter)
 		return lease;
 =

 	if (!lease->t1)
-		lease->t1 =3D lease->lifetime / 2;
+		lease->t1 =3D (uint32_t)((float)lease->lifetime * 0.5);
 =

 	if (!lease->t2)
-		lease->t2 =3D lease->lifetime / 8 * 7;
+		lease->t2 =3D (uint32_t)((float)lease->lifetime * 0.875);
 =

 	if (lease->t1 > lease->t2)
 		goto error;
-- =

2.26.2

--===============3533064747954578159==--

