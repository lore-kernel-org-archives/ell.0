Content-Type: multipart/mixed; boundary="===============2585355934227893069=="
MIME-Version: 1.0
From: Patrik Flykt <patrik.flykt@linux.intel.com>
Subject: [PATCH] genl: Call vanished function on error when fetching netlink
 family info
Date: Mon, 27 Oct 2014 14:48:04 +0200
Message-ID: <1414414084-11849-1-git-send-email-patrik.flykt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2585355934227893069==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

If initial information of the netlink family could not be received, call
the registered generic netlink vanished function immediately. The reason
for the error can for example be that the proper kernel module has not
been loaded or the proper functionality has not been compiled in.
---

There does not seem to be any way of communicating an error to the caller,
which now will hang indefinitely waiting for an answer that is not coming.
Thus improvising a bit with the currently unused 'vanished' callback.
Another option is to always require a timer in the calling application.

Cheers,

	Patrik


 ell/genl.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ell/genl.c b/ell/genl.c
index 67bde5b..4948d26 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -864,8 +864,11 @@ static void get_family_callback(struct l_genl_msg *msg=
, void *user_data)
 		return;
 =

 	error =3D l_genl_msg_get_error(msg);
-	if (error < 0)
+	if (error < 0) {
+		if (family->watch_vanished)
+			family->watch_vanished(family->watch_data);
 		return;
+	}
 =

 	if (!l_genl_attr_init(&attr, msg))
 		return;
-- =

2.1.1


--===============2585355934227893069==--

