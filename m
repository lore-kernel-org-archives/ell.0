Content-Type: multipart/mixed; boundary="===============0541597190380988563=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 1/2] cipher: Add a basic infrastructure for kernel based
 cipher operations
Date: Fri, 06 Feb 2015 14:39:22 +0200
Message-ID: <1423226363-5025-2-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1423226363-5025-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0541597190380988563==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This will let the possibility to use the crypto API provided by the
kernel in a simple manner. However, it's worth noticing such API might
not be relevant if a lot of big frames need to processed, where it will
be better to get non blocking sockets as well as lowering the memory
copies via vmsplice/splice.
---
 Makefile.am  |   6 +-
 ell/cipher.c | 221 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/cipher.h |  52 ++++++++++++++
 ell/ell.h    |   1 +
 4 files changed, 278 insertions(+), 2 deletions(-)
 create mode 100644 ell/cipher.c
 create mode 100644 ell/cipher.h

diff --git a/Makefile.am b/Makefile.am
index 50f81eb..910d5e0 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -33,7 +33,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/genl.h \
 			ell/dbus.h \
 			ell/dbus-service.h \
-			ell/hwdb.h
+			ell/hwdb.h \
+			ell/cipher.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -67,7 +68,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/gvariant-util.c \
 			ell/siphash-private.h \
 			ell/siphash.c \
-			ell/hwdb.c
+			ell/hwdb.c \
+			ell/cipher.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/cipher.c b/ell/cipher.c
new file mode 100644
index 0000000..3d4070d
--- /dev/null
+++ b/ell/cipher.c
@@ -0,0 +1,221 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2015  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#define _GNU_SOURCE
+#include <unistd.h>
+#include <sys/socket.h>
+
+#include "util.h"
+#include "cipher.h"
+#include "private.h"
+
+#ifndef SOL_ALG
+#define SOL_ALG 279
+#endif
+
+#ifndef AF_ALG
+#define AF_ALG	38
+#define PF_ALG	AF_ALG
+
+#include <linux/types.h>
+
+struct sockaddr_alg {
+	__u16	salg_family;
+	__u8	salg_type[14];
+	__u32	salg_feat;
+	__u32	salg_mask;
+	__u8	salg_name[64];
+};
+
+struct af_alg_iv {
+	__u32   ivlen;
+	__u8    iv[0];
+};
+
+/* Socket options */
+#define ALG_SET_KEY	1
+#define ALG_SET_IV	2
+#define ALG_SET_OP	3
+
+/* Operations */
+#define ALG_OP_DECRYPT	0
+#define ALG_OP_ENCRYPT	1
+
+#else
+#include <linux/if_alg.h>
+#endif
+
+#define is_valid_type(type)  ((type) <=3D L_CIPHER_ARC4)
+
+struct l_cipher {
+	enum l_cipher_type type;
+	int b_sk;
+	int sk;
+	void *key;
+	size_t key_length;
+	bool enc;
+	bool dec;
+};
+
+LIB_EXPORT struct l_cipher *l_cipher_new(enum l_cipher_type type,
+						const void *key,
+						size_t key_length)
+{
+	struct sockaddr_alg salg;
+	struct l_cipher *cipher;
+
+	if (unlikely(!key))
+		return NULL;
+
+	if (!is_valid_type(type))
+		return NULL;
+
+	cipher =3D l_new(struct l_cipher, 1);
+
+	cipher->type =3D type;
+
+	cipher->b_sk =3D socket(PF_ALG, SOCK_SEQPACKET | SOCK_CLOEXEC, 0);
+	if (cipher->b_sk < 0)
+		goto error;
+
+	memset(&salg, 0, sizeof(salg));
+	salg.salg_family =3D AF_ALG;
+	strcpy((char *) salg.salg_type, "skcipher");
+
+	switch (type) {
+	case L_CIPHER_AES:
+		strcpy((char *) salg.salg_name, "ecb(aes)");
+		break;
+	case L_CIPHER_ARC4:
+		strcpy((char *) salg.salg_name, "ecb(arc4)");
+		break;
+	}
+
+	if (bind(cipher->b_sk, (struct sockaddr *) &salg, sizeof(salg)) < 0)
+		goto error;
+
+	cipher->key =3D l_memdup(key, key_length);
+	cipher->key_length =3D key_length;
+
+	cipher->sk =3D accept4(cipher->b_sk, NULL, 0, SOCK_CLOEXEC);
+	if (cipher->sk < 0)
+		goto error;
+
+	return cipher;
+error:
+	if (cipher->b_sk > 0)
+		close(cipher->b_sk);
+
+	if (cipher->key)
+		l_free(cipher->key);
+
+	l_free(cipher);
+
+	return NULL;
+}
+
+LIB_EXPORT void l_cipher_free(struct l_cipher *cipher)
+{
+	if (unlikely(!cipher))
+		return;
+
+	close(cipher->sk);
+	close(cipher->b_sk);
+
+	if (cipher->key)
+		l_free(cipher->key);
+
+	l_free(cipher);
+}
+
+static void operate_cipher(struct l_cipher *cipher, __u32 operation,
+				const void *in, void *out, size_t len)
+{
+	char c_msg_buf[CMSG_SPACE(sizeof(operation))] =3D {};
+	struct msghdr msg =3D {};
+	bool setkey =3D false;
+	struct cmsghdr *c_msg;
+	struct iovec iov;
+
+	if (operation =3D=3D ALG_OP_ENCRYPT && !cipher->enc) {
+		setkey =3D cipher->enc =3D true;
+		cipher->dec =3D false;
+	} else if (operation =3D=3D ALG_OP_DECRYPT && !cipher->dec) {
+		setkey =3D cipher->dec =3D true;
+		cipher->enc =3D false;
+	}
+
+	if (setkey) {
+		if (setsockopt(cipher->b_sk, SOL_ALG, ALG_SET_KEY,
+					cipher->key, cipher->key_length) < 0)
+			return;
+	}
+
+	msg.msg_control =3D c_msg_buf;
+	msg.msg_controllen =3D sizeof(c_msg_buf);
+
+	c_msg =3D CMSG_FIRSTHDR(&msg);
+	c_msg->cmsg_level =3D SOL_ALG;
+	c_msg->cmsg_type =3D ALG_SET_OP;
+	c_msg->cmsg_len =3D CMSG_LEN(sizeof(operation));
+	memcpy(CMSG_DATA(c_msg), &operation, sizeof(operation));
+
+	iov.iov_base =3D (void *) in;
+	iov.iov_len =3D len;
+
+	msg.msg_iov =3D &iov;
+	msg.msg_iovlen =3D 1;
+
+	if (sendmsg(cipher->sk, &msg, 0) < 0)
+		return;
+
+	if (read(cipher->sk, out, len) < 0)
+		return;
+}
+
+LIB_EXPORT void l_cipher_encrypt(struct l_cipher *cipher,
+					const void *in, void *out, size_t len)
+{
+	if (unlikely(!cipher))
+		return;
+
+	if (unlikely(!in) || unlikely(!out))
+		return;
+
+	operate_cipher(cipher, ALG_OP_ENCRYPT, in, out, len);
+}
+
+LIB_EXPORT void l_cipher_decrypt(struct l_cipher *cipher,
+					const void *in, void *out, size_t len)
+{
+	if (unlikely(!cipher))
+		return;
+
+	if (unlikely(!in) || unlikely(!out))
+		return;
+
+	operate_cipher(cipher, ALG_OP_DECRYPT, in, out, len);
+}
diff --git a/ell/cipher.h b/ell/cipher.h
new file mode 100644
index 0000000..b273102
--- /dev/null
+++ b/ell/cipher.h
@@ -0,0 +1,52 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2015  Intel Corporation. All rights reserved.
+ *
+ *  This library is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU Lesser General Public
+ *  License as published by the Free Software Foundation; either
+ *  version 2.1 of the License, or (at your option) any later version.
+ *
+ *  This library is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ *  Lesser General Public License for more details.
+ *
+ *  You should have received a copy of the GNU Lesser General Public
+ *  License along with this library; if not, write to the Free Software
+ *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
+ *
+ */
+
+#ifndef __ELL_CIPHER_H
+#define __ELL_CIPHER_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+struct l_cipher;
+
+enum l_cipher_type {
+	L_CIPHER_AES,
+	L_CIPHER_ARC4,
+};
+
+struct l_cipher *l_cipher_new(enum l_cipher_type type,
+				const void *key, size_t key_length);
+
+void l_cipher_free(struct l_cipher *cipher);
+
+void l_cipher_encrypt(struct l_cipher *cipher,
+			const void *in, void *out, size_t len);
+
+void l_cipher_decrypt(struct l_cipher *cipher,
+			const void *in, void *out, size_t len);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_CIPHER_H */
diff --git a/ell/ell.h b/ell/ell.h
index c4dc1f2..4d9afa3 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -35,6 +35,7 @@
 #include <ell/checksum.h>
 #include <ell/settings.h>
 #include <ell/hwdb.h>
+#include <ell/cipher.h>
 =

 #include <ell/netlink.h>
 #include <ell/genl.h>
-- =

2.0.5


--===============0541597190380988563==--

