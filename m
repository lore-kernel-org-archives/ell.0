Content-Type: multipart/mixed; boundary="===============0812257188133725525=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCH] gpio: add simple get/set helpers for GPIO lines
Date: Thu, 13 Dec 2018 15:08:02 +0100
Message-ID: <20181213140802.116299-1-martin@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0812257188133725525==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The Linux kernel GPIO api operates with chips, lines, handles, and
events.

The chip and line structures represent info about gpio chips, and
gpio lines, respectively. They are used to e.g. lookup a line with a
certain name, and/or line flags.

The handle structure is used to "obtain" a handle to one or more gpio
lines on a chip. Until the file descriptor in this handle is closed, the
gpio lines cannot be used by others. The same file descriptor is used
when setting or getting the line values (one can also set the initial
value when obtaining handles for output lines).

The event structure is used to get a file descriptor that can be used
with select/poll to wait for changes in line levels.

This commit add simple support for setting and getting the value for a
single gpio line. It does so by obtaining a line handle to get/set the
value, and then release the handle immediately again.

Functionality that could be implemented, but is postponed until the need
arises includes:

 * looking up a gpio line by its name
 * setting/getting multiple gpio lines with a single function
 * waiting for events
 * holding on to handles

Some of the above probably require adding structures to represent gpio
lines and events, while handles should be private to the class.
---

Changes since RFC:
 * added gpio.h to ell.h
 * changed copyright to Geanix
 * open gpiochip in l_gpio_chip_new()
 * open gpiochip read-only
 * added input checks
 * clear ioctl structs with memset instead of =3D {0}
 * reorder error-paths

 Makefile.am |   6 ++-
 ell/ell.h   |   1 +
 ell/ell.sym |   5 ++
 ell/gpio.c  | 135 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/gpio.h  |  47 ++++++++++++++++++
 5 files changed, 192 insertions(+), 2 deletions(-)
 create mode 100644 ell/gpio.c
 create mode 100644 ell/gpio.h

diff --git a/Makefile.am b/Makefile.am
index 8401972..0ecb9a1 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -51,7 +51,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/dhcp.h \
 			ell/cert.h \
 			ell/ecc.h \
-			ell/ecdh.h
+			ell/ecdh.h \
+			ell/gpio.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -119,7 +120,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/ecc.h \
 			ell/ecc-external.c \
 			ell/ecc.c \
-			ell/ecdh.c
+			ell/ecdh.c \
+			ell/gpio.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ell.h b/ell/ell.h
index aab6417..fb1dd79 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -59,3 +59,4 @@
 #include <ell/cert.h>
 #include <ell/ecc.h>
 #include <ell/ecdh.h>
+#include <ell/gpio.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index 841bc49..c8fe5b5 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -463,6 +463,11 @@ global:
 	/* ecdh */
 	l_ecdh_generate_key_pair;
 	l_ecdh_generate_shared_secret;
+	/* gpio */
+	l_gpio_chip_new;
+	l_gpio_chip_free;
+	l_gpio_chip_get_line_value;
+	l_gpio_chip_set_line_value;
 local:
 	*;
 };
diff --git a/ell/gpio.c b/ell/gpio.c
new file mode 100644
index 0000000..5dc3440
--- /dev/null
+++ b/ell/gpio.c
@@ -0,0 +1,135 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2018 Geanix. All rights reserved.
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
+#include <sys/ioctl.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <linux/gpio.h>
+
+#include "util.h"
+#include "gpio.h"
+#include "private.h"
+
+struct l_gpio_chip {
+	int fd;
+};
+
+LIB_EXPORT struct l_gpio_chip *l_gpio_chip_new(const char *name)
+{
+	struct l_gpio_chip *chip;
+	char *path;
+
+	if (!name)
+		return NULL;
+
+	chip =3D l_new(struct l_gpio_chip, 1);
+
+	path =3D l_strdup_printf("/dev/%s", name);
+	chip->fd =3D open(path, O_RDONLY | O_CLOEXEC);
+	l_free(path);
+
+	if (chip->fd < 0) {
+		l_free(chip);
+		return NULL;
+	}
+
+	return chip;
+}
+
+LIB_EXPORT void l_gpio_chip_free(struct l_gpio_chip *chip)
+{
+	if (!chip)
+		return;
+
+	if (chip->fd >=3D 0)
+		close(chip->fd);
+
+	l_free(chip);
+}
+
+LIB_EXPORT bool l_gpio_chip_get_line_value(struct l_gpio_chip *chip,
+						uint32_t line, bool *value)
+{
+	struct gpiohandle_request req;
+	struct gpiohandle_data data;
+	int ret;
+
+	if (!chip)
+		return false;
+
+	if (chip->fd < 0)
+		return false;
+
+	memset(&req, 0, sizeof(req));
+	req.lineoffsets[0] =3D line;
+	req.lines =3D 1;
+	req.flags =3D GPIOHANDLE_REQUEST_INPUT;
+
+	ret =3D ioctl(chip->fd, GPIO_GET_LINEHANDLE_IOCTL, &req);
+	if (ret < 0 || req.fd <=3D 0)
+		return false;
+
+	memset(&data, 0, sizeof(data));
+
+	ret =3D ioctl(req.fd, GPIOHANDLE_GET_LINE_VALUES_IOCTL, &data);
+
+	close(req.fd);
+
+	if (ret < 0)
+		return false;
+
+	if (value)
+		*value =3D !!data.values[0];
+
+	return true;
+}
+
+LIB_EXPORT bool l_gpio_chip_set_line_value(struct l_gpio_chip *chip,
+						uint32_t line, bool value)
+{
+	struct gpiohandle_request req;
+	int ret;
+
+	if (!chip)
+		return false;
+
+	if (chip->fd < 0)
+		return false;
+
+	memset(&req, 0, sizeof(req));
+	req.lineoffsets[0] =3D line;
+	req.lines =3D 1;
+	req.flags =3D GPIOHANDLE_REQUEST_OUTPUT;
+	req.default_values[0] =3D value;
+
+	ret =3D ioctl(chip->fd, GPIO_GET_LINEHANDLE_IOCTL, &req);
+	if (ret < 0 || req.fd <=3D 0)
+		return false;
+
+	close(req.fd);
+
+	return true;
+}
diff --git a/ell/gpio.h b/ell/gpio.h
new file mode 100644
index 0000000..06abc77
--- /dev/null
+++ b/ell/gpio.h
@@ -0,0 +1,47 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2011-2018  Intel Corporation. All rights reserved.
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
+#ifndef __ELL_GPIO_H
+#define __ELL_GPIO_H
+
+#include <stdint.h>
+#include <stdbool.h>
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
+struct l_gpio_chip;
+
+struct l_gpio_chip *l_gpio_chip_new(const char *name);
+void l_gpio_chip_free(struct l_gpio_chip *chip);
+
+bool l_gpio_chip_get_line_value(struct l_gpio_chip *chip, uint32_t line,
+				bool *value);
+bool l_gpio_chip_set_line_value(struct l_gpio_chip *chip, uint32_t line,
+				bool value);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_GPIO_H */
-- =

2.20.0


--===============0812257188133725525==--

