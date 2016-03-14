Content-Type: multipart/mixed; boundary="===============7796312726191080314=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] dbus: Change type for pointer / integer cast to fix 32-bit
 break
Date: Mon, 14 Mar 2016 08:15:51 -0700
Message-ID: <1457968551-14118-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7796312726191080314==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Casting void* to uint64_t on 32-bit x86 causes a build error with gcc
5.9.1, so cast to uintptr_t instead.
---
 ell/dbus-kernel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 6ce3e6f..8e4e552 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -385,7 +385,7 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8_=
t bloom_n_hash,
 	header =3D _dbus_message_get_header(message, &header_size);
 	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct kdbus_vec);
 	item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
-	item->vec.address =3D (uint64_t) header;
+	item->vec.address =3D (uintptr_t) header;
 	item->vec.size =3D header_size;
 	item =3D KDBUS_ITEM_NEXT(item);
 =

@@ -393,7 +393,7 @@ int _dbus_kernel_send(int fd, size_t bloom_size, uint8_=
t bloom_n_hash,
 	if (body_size > 0) {
 		item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct kdbus_vec);
 		item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
-		item->vec.address =3D (uint64_t) body;
+		item->vec.address =3D (uintptr_t) body;
 		item->vec.size =3D body_size;
 		item =3D KDBUS_ITEM_NEXT(item);
 	}
-- =

2.7.3


--===============7796312726191080314==--

