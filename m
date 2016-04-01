Content-Type: multipart/mixed; boundary="===============1246141058936833899=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: [PATCH] dbus: Return the bloom parameters in _dbus_kernel_hello
Date: Fri, 01 Apr 2016 04:41:04 +0200
Message-ID: <1459478466-6299-2-git-send-email-andrew.zaborowski@intel.com>
In-Reply-To: <1459478466-6299-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1246141058936833899==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/dbus-kernel.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
index 1c0fbb6..b31cfcc 100644
--- a/ell/dbus-kernel.c
+++ b/ell/dbus-kernel.c
@@ -279,6 +279,15 @@ int _dbus_kernel_hello(int fd, const char *connection_=
name,
 	*bloom_size =3D DEFAULT_BLOOM_SIZE;
 	*bloom_n_hash =3D DEFAULT_BLOOM_N_HASH;
 =

+	KDBUS_ITEM_FOREACH(item, hello, items) {
+		switch (item->type) {
+		case KDBUS_ITEM_BLOOM_PARAMETER:
+			*bloom_size =3D item->bloom_parameter.size;
+			*bloom_n_hash =3D item->bloom_parameter.n_hash;
+			break;
+		}
+	}
+
 	*id =3D hello->id;
 	*guid =3D l_strdup_printf("%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx"
 				"%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx"
-- =

2.5.0


--===============1246141058936833899==--

