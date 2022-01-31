Content-Type: multipart/mixed; boundary="===============4347244624183250148=="
MIME-Version: 1.0
From: James Prestwood <prestwoj at gmail.com>
To: ell at lists.01.org
Subject: [PATCH] acd: remove 'No target or source conflict' print
Date: Mon, 31 Jan 2022 09:49:44 -0800
Message-ID: <20220131174944.3855357-1-prestwoj@gmail.com>

--===============4347244624183250148==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This is quite common and expected with ACD, and printing it serves
no useful purpose. The kind of debugging that is important is when
a conflict is detected.
---
 ell/acd.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/ell/acd.c b/ell/acd.c
index 4216898..3c8e7fe 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -281,11 +281,8 @@ static bool acd_read_handler(struct l_io *io, void *us=
er_data)
 	target_conflict =3D probe &&
 		!memcmp(arp.arp_tpa, &acd->ip, sizeof(uint32_t));
 =

-	if (!source_conflict && !target_conflict) {
-		ACD_DEBUG("No target or source conflict detected for "NIPQUAD_FMT,
-				NIPQUAD(acd->ip));
+	if (!source_conflict && !target_conflict)
 		return true;
-	}
 =

 	switch (acd->state) {
 	case ACD_STATE_PROBE:
-- =

2.31.1

--===============4347244624183250148==--

