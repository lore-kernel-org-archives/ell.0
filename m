Content-Type: multipart/mixed; boundary="===============8497788146577861236=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] netlink: Allow command handler to use l_netlink_cancel
Date: Tue, 02 Mar 2021 12:14:31 +0100
Message-ID: <20210302111431.755441-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8497788146577861236==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/netlink.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/ell/netlink.c b/ell/netlink.c
index 33d0e5b..4664762 100644
--- a/ell/netlink.c
+++ b/ell/netlink.c
@@ -162,12 +162,15 @@ static void process_message(struct l_netlink *netlink=
, struct nlmsghdr *nlmsg)
 {
 	const void *data =3D nlmsg;
 	struct command *command;
+	uint32_t id;
 =

 	command =3D l_hashmap_remove(netlink->command_pending,
 					L_UINT_TO_PTR(nlmsg->nlmsg_seq));
 	if (!command)
 		return;
 =

+	id =3D command->id;
+
 	if (!command->handler)
 		goto done;
 =

@@ -189,9 +192,8 @@ static void process_message(struct l_netlink *netlink, =
struct nlmsghdr *nlmsg)
 	}
 =

 done:
-	l_hashmap_remove(netlink->command_lookup, L_UINT_TO_PTR(command->id));
-
-	destroy_command(command);
+	if (l_hashmap_remove(netlink->command_lookup, L_UINT_TO_PTR(id)))
+		destroy_command(command);
 }
 =

 static void process_multi(struct l_netlink *netlink, struct nlmsghdr *nlms=
g)
-- =

2.27.0

--===============8497788146577861236==--

