Content-Type: multipart/mixed; boundary="===============4050937446570507471=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH ELL] dbus: Fix uninitialized build warning
Date: Thu, 06 Dec 2018 15:37:29 -0800
Message-ID: <20181206233729.20555-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4050937446570507471==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/dbus.c b/ell/dbus.c
index 2a27116..55aee0e 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -598,7 +598,7 @@ static bool classic_send_message(struct l_dbus *dbus,
 	struct msghdr msg;
 	struct iovec iov[2], *iovpos;
 	ssize_t r;
-	int *fds;
+	int *fds =3D NULL;
 	uint32_t num_fds =3D 0;
 	struct cmsghdr *cmsg;
 	int iovlen;
-- =

2.14.5


--===============4050937446570507471==--

