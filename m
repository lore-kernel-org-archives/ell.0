Content-Type: multipart/mixed; boundary="===============7040912786059093298=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 4/5] acd: fix valgrind warning of uninitialized buffer
Date: Tue, 08 Dec 2020 10:42:27 -0800
Message-ID: <20201208184228.751111-4-prestwoj@gmail.com>
In-Reply-To: <20201208184228.751111-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7040912786059093298==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/acd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/ell/acd.c b/ell/acd.c
index a50b26e..e80e322 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -130,6 +130,7 @@ static int acd_send_packet(struct l_acd *acd, uint32_t =
source_ip)
 	int fd =3D l_io_get_fd(acd->io);
 =

 	memset(&dest, 0, sizeof(dest));
+	memset(&p, 0, sizeof(p));
 =

 	dest.sll_family =3D AF_PACKET;
 	dest.sll_protocol =3D htons(ETH_P_ARP);
-- =

2.26.2

--===============7040912786059093298==--

