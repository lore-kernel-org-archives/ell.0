Content-Type: multipart/mixed; boundary="===============0176004148471033248=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH] cipher: RFC on an API for a cipher utility infrastructure
Date: Wed, 28 Jan 2015 10:37:03 +0200
Message-ID: <1422434223-3305-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0176004148471033248==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---

Hi guys,

Here is a quick proposal on the cipher infra for ell. I followed what has
been done with checksums in ell, with obvious differences due to the ciphers
themselves. (2 different actions: encrypt/decrypt and the presence of a key)

I have open issues here:

l_cipher_reset() on its own might not be useful, should I add the possibilty
to change the key as well? Unless there is no cipher state to reset, and th=
en
it's better not having such function. (I am not aware of the kernel cipher =

internals, related to some state there so if one can enlight the issue here)

Alos, about encrypt/decrypt. Currently I am proposing to have those as they
will send the data, and we get it back via get_data() (function name it not
that great btw).
So:

- is having only encrypt/decrypt an option? (so send/recv would be done in
each functions). Though 2 blocking functions at a time... not great.

- or, what about enabling async access? Unless I miss something about the
crypto layer in the kernel, here the socket is blocking. So we could be
stalled at some point. checksum does the same, is there any plan to make it
async actually? like a function l_cipher_enable_async(), which would call t=
he
right fcntl() and return the socket which we could use in the event loop.

 ell/cipher.h | 52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)
 create mode 100644 ell/cipher.h

diff --git a/ell/cipher.h b/ell/cipher.h
new file mode 100644
index 0000000..2a0ca2f
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
+	L_CIPHER_ARC4,
+	L_CIPHER_AES,
+};
+
+struct l_cipher *l_cipher_new(enum l_cipher_type type,
+				const void *key, size_t key_length);
+void l_cipher_free(struct l_cipher *cipher);
+
+void l_cipher_reset(struct l_cipher *cipher);
+
+void l_cipher_encrypt(struct l_cipher *cipher,
+				const void *data, size_t len);
+
+void l_cipher_decrypt(struct l_cipher *cipher,
+				const void *data, size_t len);
+
+void l_cipher_get_data(struct l_cipher *cipher,
+				void *data, size_t len);
+
+#endif /* __ELL_CIPHER_H */
-- =

2.0.5


--===============0176004148471033248==--

