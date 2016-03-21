Content-Type: multipart/mixed; boundary="===============0649939439796454079=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] gvariant: Exclude container's offsets from child iterator len
Date: Mon, 21 Mar 2016 23:18:50 +0100
Message-ID: <1458598730-1974-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0649939439796454079==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/gvariant-util.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
index 79ebf32..38efc0d 100644
--- a/ell/gvariant-util.c
+++ b/ell/gvariant-util.c
@@ -529,7 +529,15 @@ static const void *next_item(struct l_dbus_message_ite=
r *iter,
 	}
 =

 	if (iter->container_type !=3D DBUS_CONTAINER_TYPE_ARRAY && last_member) {
-		*out_item_size =3D iter->len - iter->pos;
+		unsigned int len =3D iter->len;
+
+		offset_len =3D offset_length(iter->len, 0);
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


--===============0649939439796454079==--

