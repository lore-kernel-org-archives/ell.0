Content-Type: multipart/mixed; boundary="===============6519326013956754797=="
MIME-Version: 1.0
From: Tim Kourt <tim.a.kourt@linux.intel.com>
Subject: [PATCH] genl: Fix casting error
Date: Fri, 14 Jul 2017 10:14:28 -0700
Message-ID: <20170714171428.1714-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6519326013956754797==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Fix for the cros-compilation with Chromium OS=E2=80=99s toolchain that
uses GCC 4.9
---
 ell/genl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index cff3a9a..d9cfddb 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -498,7 +498,7 @@ static bool received_data(struct l_io *io, void *user_d=
ata)
 		group =3D pktinfo.group;
 	}
 =

-	for (nlmsg =3D iov.iov_base; NLMSG_OK(nlmsg, bytes_read);
+	for (nlmsg =3D iov.iov_base; NLMSG_OK(nlmsg, (uint32_t) bytes_read);
 				nlmsg =3D NLMSG_NEXT(nlmsg, bytes_read)) {
 		if (group > 0)
 			process_multicast(genl, group, nlmsg);
-- =

2.9.4


--===============6519326013956754797==--

