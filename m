Content-Type: multipart/mixed; boundary="===============4266932758025677712=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 2/2] genl: Convert l_malloc + memcpy to use l_memdup
Date: Fri, 16 Jan 2015 11:13:52 +0200
Message-ID: <1421399632-19544-3-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1421399632-19544-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4266932758025677712==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Use new l_memdup() function instead of l_malloc() followed by
memcpy().
---
 ell/genl.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/ell/genl.c b/ell/genl.c
index dca8e1b..d2c1784 100644
--- a/ell/genl.c
+++ b/ell/genl.c
@@ -257,13 +257,11 @@ static struct l_genl_msg *msg_create(const struct nlm=
sghdr *nlmsg)
 		goto done;
 	}
 =

-	msg->data =3D l_malloc(nlmsg->nlmsg_len);
+	msg->data =3D l_memdup(nlmsg, nlmsg->nlmsg_len);
 =

 	msg->len =3D nlmsg->nlmsg_len;
 	msg->size =3D nlmsg->nlmsg_len;
 =

-	memcpy(msg->data, nlmsg, nlmsg->nlmsg_len);
-
 	if (msg->len >=3D GENL_HDRLEN) {
 		struct genlmsghdr *genlmsg =3D msg->data + NLMSG_HDRLEN;
 =

-- =

1.8.3.1


--===============4266932758025677712==--

