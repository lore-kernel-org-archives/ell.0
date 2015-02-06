Content-Type: multipart/mixed; boundary="===============7374544556637699289=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [RFC 1/2] random: Add a basic infrastructure for kernel based rng
Date: Fri, 06 Feb 2015 13:37:14 +0200
Message-ID: <1423222635-6053-2-git-send-email-tomasz.bursztyka@linux.intel.com>
In-Reply-To: <1423222635-6053-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7374544556637699289==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This lets the possibility to generate randomly the content of a buffer
by the kernel.
---
 Makefile.am  |   6 +-
 ell/ell.h    |   1 +
 ell/random.c | 222 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/random.h |  50 ++++++++++++++
 4 files changed, 277 insertions(+), 2 deletions(-)
 create mode 100644 ell/random.c
 create mode 100644 ell/random.h

diff --git a/Makefile.am b/Makefile.am
index 50f81eb..206fc10 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -33,7 +33,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/genl.h \
 			ell/dbus.h \
 			ell/dbus-service.h \
-			ell/hwdb.h
+			ell/hwdb.h \
+			ell/random.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -67,7 +68,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/gvariant-util.c \
 			ell/siphash-private.h \
 			ell/siphash.c \
-			ell/hwdb.c
+			ell/hwdb.c \
+			ell/random.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-version-info $(ELL_CURRENT):$(ELL_REVISION):$(ELL_AGE)
diff --git a/ell/ell.h b/ell/ell.h
index c4dc1f2..43c6547 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -35,6 +35,7 @@
 #include <ell/checksum.h>
 #include <ell/settings.h>
 #include <ell/hwdb.h>
+#include <ell/random.h>
 =

 #include <ell/netlink.h>
 #include <ell/genl.h>
diff --git a/ell/random.c b/ell/random.c
new file mode 100644
index 0000000..446f071
--- /dev/null
+++ b/ell/random.c
@@ -0,0 +1,222 @@
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
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+#include "util.h"
+#include "random.h"
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
+#define is_valid_type(type)  ((type) <=3D L_RANDOM_URANDOM)
+
+struct l_random {
+	enum l_random_type type;
+	int fd;
+	int sk;
+};
+
+static inline bool create_stdrng(struct l_random *random)
+{
+	struct sockaddr_alg salg =3D {};
+
+	random->fd =3D socket(PF_ALG, SOCK_SEQPACKET | SOCK_CLOEXEC, 0);
+	if (random->fd < 0)
+		return false;
+
+	salg.salg_family =3D AF_ALG;
+	strcpy((char *) salg.salg_type, "rng");
+	strcpy((char *) salg.salg_name, "stdrng");
+
+	if (bind(random->fd, (struct sockaddr *) &salg, sizeof(salg)) < 0)
+		goto error;
+
+	random->sk =3D accept4(random->fd, NULL, 0, SOCK_CLOEXEC);
+	if (random->sk < 0)
+		goto error;
+
+	return true;
+error:
+	close(random->fd);
+	return false;
+}
+
+LIB_EXPORT struct l_random *l_random_new(enum l_random_type type)
+{
+	struct l_random *random;
+
+	if (!is_valid_type(type))
+		return NULL;
+
+	random =3D l_new(struct l_random, 1);
+
+	random->type =3D type;
+
+	switch (type) {
+	case L_RANDOM_STDRNG:
+		if (!create_stdrng(random))
+			goto error;
+		break;
+	case L_RANDOM_URANDOM:
+		random->fd =3D open("/dev/random", O_RDONLY);
+		if (random->fd < 0)
+			goto error;
+	}
+
+	return random;
+error:
+	l_free(random);
+
+	return NULL;
+}
+
+LIB_EXPORT void l_random_free(struct l_random *random)
+{
+	if (unlikely(!random))
+		return;
+
+	if (random->sk > 0)
+		close(random->sk);
+
+	close(random->fd);
+
+	l_free(random);
+}
+
+LIB_EXPORT void l_random_seed(struct l_random *random,
+					const void *seed, size_t seed_length)
+{
+	if (unlikely(!random))
+		return;
+
+	switch (random->type) {
+	case L_RANDOM_STDRNG:
+		setsockopt(random->fd, SOL_ALG,
+					ALG_SET_KEY, seed, seed_length);
+		break;
+	case L_RANDOM_URANDOM:
+		break;
+	}
+}
+
+static inline void generate_from_stdrng(int sk,
+					void *rand_buffer, size_t length)
+{
+	struct msghdr msg =3D {};
+	struct iovec iov;
+
+	msg.msg_iov =3D &iov;
+	msg.msg_iovlen =3D 0;
+
+	while (length) {
+		ssize_t r =3D 0;
+
+		iov.iov_base =3D rand_buffer;
+		iov.iov_len =3D length;
+
+		r =3D recvmsg(sk, &msg, 0);
+		if (r <=3D 0)
+			return;
+
+		length -=3D r;
+		rand_buffer +=3D r;
+	}
+}
+
+static inline void generate_from_urandom(int fd,
+						void *rand_buffer,
+						size_t length)
+{
+	while (length) {
+		ssize_t r =3D 0;
+
+		r =3D read(fd, rand_buffer, length);
+		if (r <=3D 0)
+			return;
+
+		length -=3D r;
+		rand_buffer +=3D r;
+	}
+}
+
+LIB_EXPORT void l_random_generate(struct l_random *random,
+					void *rand_buffer, size_t length)
+{
+	if (unlikely(!random))
+		return;
+
+	if (unlikely(!rand_buffer))
+		return;
+
+	switch (random->type) {
+	case L_RANDOM_STDRNG:
+		generate_from_stdrng(random->sk, rand_buffer, length);
+		break;
+	case L_RANDOM_URANDOM:
+		generate_from_urandom(random->fd, rand_buffer, length);
+		break;
+	}
+}
diff --git a/ell/random.h b/ell/random.h
new file mode 100644
index 0000000..20a6132
--- /dev/null
+++ b/ell/random.h
@@ -0,0 +1,50 @@
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
+#ifndef __ELL_RANDOM_H
+#define __ELL_RANDOM_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+struct l_random;
+
+enum l_random_type {
+	L_RANDOM_STDRNG,
+	L_RANDOM_URANDOM,
+};
+
+struct l_random *l_random_new(enum l_random_type type);
+void l_random_free(struct l_random *random);
+
+void l_random_seed(struct l_random *random,
+					const void *seed, size_t seed_length);
+
+void l_random_generate(struct l_random *random,
+					void *rand_buffer, size_t length);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_RANDOM_H */
-- =

2.0.5


--===============7374544556637699289==--

