Content-Type: multipart/mixed; boundary="===============6094440736163335681=="
MIME-Version: 1.0
From: Patrik Flykt <patrik.flykt@linux.intel.com>
Subject: [PATCH] genl: Do not call the callback for NLMSG_DONE messages
Date: Wed, 12 Nov 2014 16:47:07 +0200
Message-ID: <1415803627-4390-1-git-send-email-patrik.flykt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6094440736163335681==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The message indicates end of a multipart netlink message and does not
carry any data.
---
 ell/genl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index 67bde5b..b180712 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -373,7 +373,7 @@ static void process_request(struct l_genl *genl, const =
struct nlmsghdr *nlmsg)
 		return;
 	}
 =

-	if (request->callback)
+	if (request->callback && nlmsg->nlmsg_type !=3D NLMSG_DONE)
 		request->callback(msg, request->user_data);
 =

 	if (nlmsg->nlmsg_flags & NLM_F_MULTI) {
-- =

2.1.1


--===============6094440736163335681==--

