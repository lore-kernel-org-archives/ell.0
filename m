Content-Type: multipart/mixed; boundary="===============4265151578672708833=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 1/3] acd: check fd return to satisfy static analysis
Date: Mon, 08 Feb 2021 11:27:54 -0800
Message-ID: <20210208192756.580521-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4265151578672708833==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/acd.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/ell/acd.c b/ell/acd.c
index 6381747..d5c5024 100644
--- a/ell/acd.c
+++ b/ell/acd.c
@@ -129,6 +129,9 @@ static int acd_send_packet(struct l_acd *acd, uint32_t =
source_ip)
 	int n;
 	int fd =3D l_io_get_fd(acd->io);
 =

+	if (fd < 0)
+		return fd;
+
 	memset(&dest, 0, sizeof(dest));
 	memset(&p, 0, sizeof(p));
 =

@@ -260,9 +263,13 @@ static bool acd_read_handler(struct l_io *io, void *us=
er_data)
 	int source_conflict;
 	int target_conflict;
 	bool probe;
+	int fd =3D l_io_get_fd(acd->io);
+
+	if (fd < 0)
+		return true;
 =

 	memset(&arp, 0, sizeof(arp));
-	len =3D read(l_io_get_fd(acd->io), &arp, sizeof(arp));
+	len =3D read(fd, &arp, sizeof(arp));
 	if (len < 0)
 		return false;
 =

-- =

2.26.2

--===============4265151578672708833==--

