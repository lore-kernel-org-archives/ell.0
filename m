Content-Type: multipart/mixed; boundary="===============4940101990259847759=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] netlink: Don't change error code signs
Date: Fri, 05 Oct 2018 03:48:15 +0200
Message-ID: <20181005014815.16483-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4940101990259847759==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Netlink errors returned by the kernel are already negative so don't
change the sign, this was confusing some iwd code that depends on
negative error numbers from l_netlink.
---
 ell/netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/netlink.c b/ell/netlink.c
index d247173..d1871ba 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -178,7 +178,7 @@ static void process_message(struct l_netlink *netlink, =
struct nlmsghdr *nlmsg)
 		case NLMSG_ERROR:
 			err =3D data + NLMSG_HDRLEN;
 =

-			command->handler(-err->error, 0, NULL, 0,
+			command->handler(err->error, 0, NULL, 0,
 							command->user_data);
 			break;
 		}
-- =

2.17.1


--===============4940101990259847759==--

