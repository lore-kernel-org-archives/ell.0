Content-Type: multipart/mixed; boundary="===============2490034465039754085=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCHv3] gpio: add simple get/set helpers for GPIO lines
Date: Mon, 17 Dec 2018 22:30:03 +0100
Message-ID: <20181217213003.29260-1-martin@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2490034465039754085==
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

This commit adds simple support for setting and getting the value for a
single gpio line. It does so by obtaining a line handle to get/set the
value, and then release the handle immediately again.

Both the l_gpio_chip and l_gpio_line structures reference an internal
gpio structure that holds the file descriptor to the open
/dev/gpiochipX character device. This file descriptor is used by
l_gpio_chip to lookup line info, and by l_gpio_line to request a virtual
file descriptor used to get and set line values.

Functionality that could be implemented, but is postponed until the need
arises includes:

 * setting/getting multiple gpio lines with a single function
 * waiting for events
 * holding on to handles

Some of the above probably require adding structures to represent
multiple gpio lines and events, while handles should be private to the
class.

---

Changes since v2:
 * added internal reference counted structure to hold primary fd
 * added l_gpio_line structure to represent a single line
 * added function to lookup gpio line by label

Changes since v1:
 * added gpiochip info and corresponding getters
 * changed "line" to "line_num" a few places

Changes since RFC:
 * added gpio.h to ell.h
 * changed copyright to Geanix
 * open gpiochip in l_gpio_chip_new()
 * open gpiochip read-only
 * added input checks
 * clear ioctl structs with memset instead of =3D {0} =

 * reorder error-paths

 Makefile.am |   6 +-
 ell/ell.h   |   1 +
 ell/ell.sym |  15 +++
 ell/gpio.c  | 360 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/gpio.h  |  59 +++++++++
 5 files changed, 439 insertions(+), 2 deletions(-)
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
index 841bc49..057626c 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -463,6 +463,21 @@ global:
 	/* ecdh */
 	l_ecdh_generate_key_pair;
 	l_ecdh_generate_shared_secret;
+	/* gpio */
+	l_gpio_chip_new;
+	l_gpio_chip_free;
+	l_gpio_chip_get_name;
+	l_gpio_chip_get_label;
+	l_gpio_chip_get_num_lines;
+	l_gpio_chip_get_line;
+	l_gpio_chip_find_line;
+	l_gpio_line_free;
+	l_gpio_line_get_label;
+	l_gpio_line_get_num;
+	l_gpio_line_get_chip;
+	l_gpio_line_set_value;
+	l_gpio_line_get_value;
+	l_gpio_find_line;
 local:
 	*;
 };
diff --git a/ell/gpio.c b/ell/gpio.c
new file mode 100644
index 0000000..b1a6548
--- /dev/null
+++ b/ell/gpio.c
@@ -0,0 +1,360 @@
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
+#include <string.h>
+#include <unistd.h>
+#include <sys/ioctl.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <dirent.h>
+#include <linux/gpio.h>
+
+#include "util.h"
+#include "gpio.h"
+#include "private.h"
+
+struct gpio_priv {
+	int fd;
+	size_t refcount;
+};
+
+struct l_gpio_chip {
+	struct gpio_priv *priv;
+	char *name;
+	char *label;
+	uint32_t num_lines;
+};
+
+struct l_gpio_line {
+	struct gpio_priv *priv;
+	char *label;
+	uint32_t num;
+};
+
+static struct gpio_priv *gpio_get(struct gpio_priv *priv)
+{
+	priv->refcount++;
+
+	return priv;
+}
+
+static void gpio_put(struct gpio_priv *priv)
+{
+	if (!priv)
+		return;
+
+	if (--priv->refcount > 0)
+		return;
+
+	if (priv->fd >=3D 0)
+		close(priv->fd);
+
+	l_free(priv);
+}
+
+static struct l_gpio_chip *gpio_get_chip(struct gpio_priv *priv)
+{
+	struct l_gpio_chip *chip;
+	struct gpiochip_info info;
+
+	if (!priv)
+		return NULL;
+
+	memset(&info, 0, sizeof(info));
+
+	if(ioctl(priv->fd, GPIO_GET_CHIPINFO_IOCTL, &info) < 0)
+		return NULL;
+
+	chip =3D l_new(struct l_gpio_chip, 1);
+	chip->priv =3D gpio_get(priv);
+	chip->num_lines =3D info.lines;
+
+	if (info.label)
+		chip->label =3D l_strndup(info.label, sizeof(info.label));
+
+	if (info.name)
+		chip->name =3D l_strndup(info.name, sizeof(info.name));
+
+	return chip;
+}
+
+LIB_EXPORT struct l_gpio_chip *l_gpio_chip_new(const char *chip_name)
+{
+	struct gpio_priv *priv;
+	char *path;
+	int fd;
+
+	if (!chip_name)
+		return NULL;
+
+	path =3D l_strdup_printf("/dev/%s", chip_name);
+	fd =3D open(path, O_RDONLY | O_CLOEXEC);
+	l_free(path);
+
+	if (fd < 0)
+		return NULL;
+
+	priv =3D l_new(struct gpio_priv, 1);
+	priv->fd =3D fd;
+
+	return gpio_get_chip(priv);
+}
+
+LIB_EXPORT void l_gpio_chip_free(struct l_gpio_chip *chip)
+{
+	if (!chip)
+		return;
+
+	gpio_put(chip->priv);
+	l_free(chip->name);
+	l_free(chip->label);
+	l_free(chip);
+}
+
+LIB_EXPORT const char *l_gpio_chip_get_name(struct l_gpio_chip *chip)
+{
+	if (!chip)
+		return NULL;
+
+	return chip->name;
+}
+
+LIB_EXPORT const char *l_gpio_chip_get_label(struct l_gpio_chip *chip)
+{
+	if (!chip)
+		return NULL;
+
+	return chip->label;
+}
+
+LIB_EXPORT uint32_t l_gpio_chip_get_num_lines(struct l_gpio_chip *chip)
+{
+	if (!chip)
+		return 0;
+
+	return chip->num_lines;
+}
+
+LIB_EXPORT struct l_gpio_line *l_gpio_chip_get_line(struct l_gpio_chip *ch=
ip,
+							uint32_t line_num)
+{
+	struct l_gpio_line *line;
+	struct gpioline_info info;
+
+	if (!chip)
+		return NULL;
+
+	if (line_num >=3D chip->num_lines)
+		return NULL;
+
+	memset(&info, 0, sizeof(info));
+	info.line_offset =3D line_num;
+
+	if (ioctl(chip->priv->fd, GPIO_GET_LINEINFO_IOCTL, &info) < 0)
+		return NULL;
+
+	line =3D l_new(struct l_gpio_line, 1);
+	line->num =3D line_num;
+	line->priv =3D gpio_get(chip->priv);
+
+	if (info.name)
+		line->label =3D l_strndup(info.name, sizeof(info.name));
+
+	return line;
+}
+
+LIB_EXPORT struct l_gpio_line *l_gpio_chip_find_line(struct l_gpio_chip *c=
hip,
+							const char *line_label)
+{
+	struct l_gpio_line *line;
+	uint32_t i;
+
+	if (!chip)
+		return NULL;
+
+	if (!line_label)
+		return NULL;
+
+	for (i =3D 0; i < chip->num_lines; i++) {
+		line =3D l_gpio_chip_get_line(chip, i);
+		if (!line)
+			return NULL;
+
+		if (!line->label && strcmp(line->label, line_label) =3D=3D 0)
+			return line;
+
+		l_gpio_line_free(line);
+	}
+
+	return NULL;
+}
+
+LIB_EXPORT void l_gpio_line_free(struct l_gpio_line *line)
+{
+	if (!line)
+		return;
+
+	gpio_put(line->priv);
+	l_free(line->label);
+	l_free(line);
+}
+
+LIB_EXPORT const char *l_gpio_line_get_label(struct l_gpio_line *line)
+{
+	if (!line)
+		return NULL;
+
+	return line->label;
+}
+
+LIB_EXPORT uint32_t l_gpio_line_get_num(struct l_gpio_line *line)
+{
+	if (!line)
+		return -1;
+
+	return line->num;
+}
+
+LIB_EXPORT struct l_gpio_chip *l_gpio_line_get_chip(struct l_gpio_line *li=
ne)
+{
+	if (!line)
+		return NULL;
+
+	return gpio_get_chip(line->priv);
+}
+
+LIB_EXPORT bool l_gpio_line_set_value(struct l_gpio_line *line, bool value)
+{
+	struct gpiohandle_request handle_req;
+
+	if (!line)
+		return false;
+
+	memset(&handle_req, 0, sizeof(handle_req));
+
+	handle_req.lineoffsets[0] =3D line->num;
+	handle_req.lines =3D 1;
+	handle_req.flags =3D GPIOHANDLE_REQUEST_OUTPUT;
+	handle_req.default_values[0] =3D value;
+
+	if (ioctl(line->priv->fd, GPIO_GET_LINEHANDLE_IOCTL, &handle_req) < 0)
+		return false;
+
+	if (handle_req.fd <=3D 0)
+		return false;
+
+	close(handle_req.fd);
+
+	return true;
+}
+
+LIB_EXPORT bool l_gpio_line_get_value(struct l_gpio_line *line, bool *valu=
e)
+{
+	struct gpiohandle_request handle_req;
+	struct gpiohandle_data handle_data;
+
+	if (!line)
+		return false;
+
+	memset(&handle_req, 9, sizeof(handle_req));
+
+	handle_req.lineoffsets[0] =3D line->num;
+	handle_req.lines =3D 1;
+	handle_req.flags =3D GPIOHANDLE_REQUEST_INPUT;
+
+	if (ioctl(line->priv->fd, GPIO_GET_LINEHANDLE_IOCTL, &handle_req) < 0)
+		return false;
+
+	if (handle_req.fd <=3D 0)
+		return false;
+
+	memset(&handle_data, 0, sizeof(handle_data));
+
+	if (ioctl(handle_req.fd, GPIOHANDLE_GET_LINE_VALUES_IOCTL,
+			&handle_data) < 0) {
+		close(handle_req.fd);
+		return false;
+	}
+
+	close(handle_req.fd);
+
+	if (value)
+		*value =3D !!handle_data.values[0];
+
+	return true;
+}
+
+static int dir_filter(const struct dirent *dir)
+{
+	return !strncmp(dir->d_name, "gpiochip", 8);
+}
+
+static void free_dirs(struct dirent ***dirs, unsigned int num_dirs)
+{
+	unsigned int i;
+
+	for (i =3D 0; i < num_dirs; i++)
+		l_free((*dirs)[i]);
+	l_free(*dirs);
+}
+
+LIB_EXPORT struct l_gpio_line *l_gpio_find_line(const char *line_label)
+{
+	struct l_gpio_chip *chip;
+	struct l_gpio_line *line;
+	struct dirent **dirs;
+	int i, num_chips;
+
+	if (!line_label)
+		return NULL;
+
+	num_chips =3D scandir("/dev", &dirs, dir_filter, alphasort);
+	if (num_chips < 0)
+		return NULL;
+
+	for (i =3D 0; i < num_chips; i++) {
+		chip =3D l_gpio_chip_new(dirs[i]->d_name);
+		if (!chip) {
+			free_dirs(&dirs, num_chips);
+			return NULL;
+		}
+
+		line =3D l_gpio_chip_find_line(chip, line_label);
+		if (line) {
+			l_gpio_chip_free(chip);
+			free_dirs(&dirs, num_chips);
+
+			return line;
+		}
+
+		l_gpio_chip_free(chip);
+	}
+
+	free_dirs(&dirs, num_chips);
+
+	return NULL;
+}
diff --git a/ell/gpio.h b/ell/gpio.h
new file mode 100644
index 0000000..ddbd109
--- /dev/null
+++ b/ell/gpio.h
@@ -0,0 +1,59 @@
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
+struct l_gpio_line;
+
+struct l_gpio_chip *l_gpio_chip_new(const char *chip_name);
+void l_gpio_chip_free(struct l_gpio_chip *chip);
+
+const char *l_gpio_chip_get_name(struct l_gpio_chip *name);
+const char *l_gpio_chip_get_label(struct l_gpio_chip *chip);
+uint32_t l_gpio_chip_get_num_lines(struct l_gpio_chip *chip);
+struct l_gpio_line *l_gpio_chip_get_line(struct l_gpio_chip *chip,
+						uint32_t line_num);
+struct l_gpio_line *l_gpio_chip_find_line(struct l_gpio_chip *chip,
+						const char *line_label);
+
+void l_gpio_line_free(struct l_gpio_line *line);
+const char *l_gpio_line_get_label(struct l_gpio_line *line);
+uint32_t l_gpio_line_get_num(struct l_gpio_line *line);
+struct l_gpio_chip *l_gpio_line_get_chip(struct l_gpio_line *line);
+bool l_gpio_line_set_value(struct l_gpio_line *line, bool value);
+bool l_gpio_line_get_value(struct l_gpio_line *line, bool *value);
+struct l_gpio_line *l_gpio_find_line(const char *line_label);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_GPIO_H */
-- =

2.20.1


--===============2490034465039754085==--

