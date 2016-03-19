Content-Type: multipart/mixed; boundary="===============3898750499430922741=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] gvariant: Exclude container's offsets from child iterator len.
Date: Sat, 19 Mar 2016 07:00:43 +0100
Message-ID: <1458367247-14607-5-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1458367247-14607-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3898750499430922741==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/gvariant-util.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 1aaddc3..61e5b52 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -497,6 +497,7 @@ static const void *next_item(struct l_dbus_message_iter=
 *iter,
 	bool last_member;
 	unsigned int sig_len;
 	unsigned int offset_len;
+	unsigned int len =3D iter->len;
 =

 	memcpy(sig, iter->sig_start + iter->sig_pos,
 			iter->sig_len - iter->sig_pos);
@@ -529,7 +530,14 @@ static const void *next_item(struct l_dbus_message_ite=
r *iter,
 	}
 =

 	if (iter->container_type !=3D DBUS_CONTAINER_TYPE_ARRAY && last_member) {
-		*out_item_size =3D iter->len - iter->pos;
+		offset_len =3D offset_length(iter->len, 0);
+		len =3D iter->len;
+
+		if (iter->offsets && iter->offsets + offset_len <
+				iter->data + len)
+			len =3D iter->offsets + offset_len - iter->data;
+
+		*out_item_size =3D len - iter->pos;
 		goto done;
 	}
 =

-- =

2.5.0


--===============3898750499430922741==--

