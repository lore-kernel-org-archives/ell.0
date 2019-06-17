Content-Type: multipart/mixed; boundary="===============7051023205095167609=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: [PATCHv5] gpio: add get/set helpers for GPIO lines
Date: Mon, 17 Jun 2019 12:08:37 +0200
Message-ID: <20190617100837.66501-1-martin@geanix.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7051023205095167609==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

The Linux kernel GPIO api operates with chips, lines, handles, and events.

The chip and line structures represent info about gpio chips, and gpio
lines, respectively. They are used to e.g. lookup a line with a certain
name, and/or line flags.

The handle structure is used to "obtain" a handle to one or more gpio
lines on a chip. Until the file descriptor in this handle is closed, the
gpio lines cannot be used by others. The same file descriptor is used
when setting or getting the line values (one can also set the initial
value when obtaining handles for output lines).

The event structure is used to get a file descriptor that can be used
with select/poll to wait for changes in line levels.

This commit adds support for setting and getting values for one or more
gpio lines. So far three structures are implemented:

 l_gpio_chip
 l_gpio_writer
 l_gpio_reader

The chip structure is used to look up line info, and to find line
offsets for a certain label. The chip and offset is then used to
instantiate writers and readers.

The writer and reader are created with one of more offsets on a certain
chip. For the writer case, the offsets are accompanied with the default
output values to set when requesting the gpio lines.

Functionality that could be implemented, but is postponed until the need
arises includes:

 * waiting for events
 * one-shot wrappers that don't hold on to gpio lines

---

Changes since v4:
 * use unlikely() when verifying parameters
 * verify *values parameter in _get() and _set()
 * no helpers for single line uses
 * check for file type and prefix when scanning devices
 * update copyright years

Changes since v3:
 * let lookup-by-label return multiple gpio chips
 * implemented lookup of line offsets
 * use separate reader/writer objects
 * make the multi-line case the common use

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
 * clear ioctl structs with memset instead of =3D {0}
 * reorder error-paths

 Makefile.am |   6 +-
 ell/ell.h   |   1 +
 ell/ell.sym |  18 +++
 ell/gpio.c  | 401 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 ell/gpio.h  |  72 ++++++++++
 5 files changed, 496 insertions(+), 2 deletions(-)
 create mode 100644 ell/gpio.c
 create mode 100644 ell/gpio.h

diff --git a/Makefile.am b/Makefile.am
index 91299d4..072867f 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -52,7 +52,8 @@ pkginclude_HEADERS =3D ell/ell.h \
 			ell/cert.h \
 			ell/ecc.h \
 			ell/ecdh.h \
-			ell/time.h
+			ell/time.h \
+			ell/gpio.h
 =

 lib_LTLIBRARIES =3D ell/libell.la
 =

@@ -123,7 +124,8 @@ ell_libell_la_SOURCES =3D $(linux_headers) \
 			ell/ecc-external.c \
 			ell/ecc.c \
 			ell/ecdh.c \
-			ell/time.c
+			ell/time.c \
+			ell/gpio.c
 =

 ell_libell_la_LDFLAGS =3D -no-undefined \
 			-Wl,--version-script=3D$(top_srcdir)/ell/ell.sym \
diff --git a/ell/ell.h b/ell/ell.h
index 691bdb2..c5cb1f2 100644
--- a/ell/ell.h
+++ b/ell/ell.h
@@ -60,3 +60,4 @@
 #include <ell/ecc.h>
 #include <ell/ecdh.h>
 #include <ell/time.h>
+#include <ell/gpio.h>
diff --git a/ell/ell.sym b/ell/ell.sym
index e720322..ffa11d6 100644
--- a/ell/ell.sym
+++ b/ell/ell.sym
@@ -503,6 +503,24 @@ global:
 	l_ecdh_generate_shared_secret;
 	/* time */
 	l_time_now;
+	/* gpio */
+	l_gpio_chips_with_line_label;
+	l_gpio_chip_new;
+	l_gpio_chip_free;
+	l_gpio_chip_find_line_offset;
+	l_gpio_chip_get_label;
+	l_gpio_chip_get_name;
+	l_gpio_chip_get_num_lines;
+	l_gpio_chip_get_line_label;
+	l_gpio_chip_get_line_consumer;
+	l_gpio_writer_new;
+	l_gpio_writer_free;
+	l_gpio_writer_set;
+	l_gpio_writer_get_label;
+	l_gpio_reader_new;
+	l_gpio_reader_free;
+	l_gpio_reader_get;
+	l_gpio_reader_get_label;
 local:
 	*;
 };
diff --git a/ell/gpio.c b/ell/gpio.c
new file mode 100644
index 0000000..88bf7a4
--- /dev/null
+++ b/ell/gpio.c
@@ -0,0 +1,401 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2019 Geanix. All rights reserved.
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
+#include <unistd.h>
+#include <string.h>
+#include <sys/ioctl.h>
+#include <fcntl.h>
+#include <dirent.h>
+#include <linux/gpio.h>
+
+#include "private.h"
+#include "strv.h"
+#include "util.h"
+#include "gpio.h"
+
+struct l_gpio_chip {
+	int fd;
+	char *name;
+	char *label;
+	uint32_t n_lines;
+};
+
+struct l_gpio_writer {
+	int fd;
+	uint32_t n_offsets;
+};
+
+struct l_gpio_reader {
+	int fd;
+	uint32_t n_offsets;
+};
+
+static bool chip_has_line_label(const char *chip_name, const char *line_la=
bel)
+{
+	struct l_gpio_chip *chip;
+	bool has_label;
+
+	chip =3D l_gpio_chip_new(chip_name);
+	if (!chip)
+		return false;
+
+	has_label =3D l_gpio_chip_find_line_offset(chip, line_label, NULL);
+
+	l_gpio_chip_free(chip);
+
+	return has_label;
+}
+
+LIB_EXPORT char **l_gpio_chips_with_line_label(const char *line_label)
+{
+	struct dirent *entry;
+	DIR *dp;
+	char **chips =3D NULL;
+
+	dp =3D opendir("/sys/bus/gpio/devices");
+	if (dp =3D=3D NULL)
+		return NULL;
+
+	while ((entry =3D readdir(dp))) {
+		if (entry->d_type !=3D DT_LNK)
+			continue;
+
+		if (!l_str_has_prefix(entry->d_name, "gpiochip"))
+			continue;
+
+		if (chip_has_line_label(entry->d_name, line_label))
+			chips =3D l_strv_append(chips, entry->d_name);
+	}
+
+	closedir(dp);
+
+	return chips;
+}
+
+LIB_EXPORT struct l_gpio_chip *l_gpio_chip_new(const char *chip_name)
+{
+	struct l_gpio_chip *chip;
+	struct gpiochip_info info;
+	char *path;
+	int fd;
+	int ret;
+
+	if (unlikely(!chip_name))
+		return NULL;
+
+	path =3D l_strdup_printf("/dev/%s", chip_name);
+	fd =3D open(path, O_RDONLY | O_CLOEXEC);
+	l_free(path);
+
+	if (fd < 0)
+		return NULL;
+
+	memset(&info, 0, sizeof(info));
+
+	ret =3D ioctl(fd, GPIO_GET_CHIPINFO_IOCTL, &info);
+	if (ret < 0) {
+		close(fd);
+		return NULL;
+	}
+
+	chip =3D l_new(struct l_gpio_chip, 1);
+	chip->fd =3D fd;
+	chip->n_lines =3D info.lines;
+	chip->label =3D l_strndup(info.label, sizeof(info.label));
+	chip->name =3D l_strdup(chip_name);
+
+	return chip;
+}
+
+LIB_EXPORT const char *l_gpio_chip_get_label(struct l_gpio_chip *chip)
+{
+	if (unlikely(!chip))
+		return NULL;
+
+	return chip->label;
+}
+
+LIB_EXPORT const char *l_gpio_chip_get_name(struct l_gpio_chip *chip)
+{
+	if (unlikely(!chip))
+		return NULL;
+
+	return chip->name;
+}
+
+LIB_EXPORT uint32_t l_gpio_chip_get_num_lines(struct l_gpio_chip *chip)
+{
+	if (unlikely(!chip))
+		return 0;
+
+	return chip->n_lines;
+}
+
+LIB_EXPORT void l_gpio_chip_free(struct l_gpio_chip *chip)
+{
+	if (unlikely(!chip))
+		return;
+
+	if (chip->fd >=3D 0)
+		close(chip->fd);
+
+	l_free(chip->name);
+	l_free(chip->label);
+	l_free(chip);
+}
+
+LIB_EXPORT bool l_gpio_chip_find_line_offset(struct l_gpio_chip *chip,
+						const char *line_label,
+						uint32_t *line_offset)
+{
+	struct gpioline_info info;
+	uint32_t i;
+
+	if (unlikely(!chip))
+		return false;
+
+	if (unlikely(!line_label))
+		return false;
+
+	for (i =3D 0; i < chip->n_lines; i++) {
+		memset(&info, 0, sizeof(info));
+		info.line_offset =3D i;
+
+		if (ioctl(chip->fd, GPIO_GET_LINEINFO_IOCTL, &info) < 0)
+			return false;
+
+		if (!info.name)
+			continue;
+
+		if (strcmp(info.name, line_label) !=3D 0)
+			continue;
+
+		if (line_offset)
+			*line_offset =3D i;
+
+		return true;
+	}
+
+	return false;
+}
+
+LIB_EXPORT char *l_gpio_chip_get_line_label(struct l_gpio_chip *chip,
+						uint32_t offset)
+{
+	struct gpioline_info info;
+
+	if (unlikely(!chip))
+		return NULL;
+
+	if (unlikely(offset >=3D chip->n_lines))
+		return NULL;
+
+	memset(&info, 0, sizeof(info));
+	info.line_offset =3D offset;
+
+	if (ioctl(chip->fd, GPIO_GET_LINEINFO_IOCTL, &info) < 0)
+		return NULL;
+
+	return l_strdup(info.name);
+}
+
+LIB_EXPORT char *l_gpio_chip_get_line_consumer(struct l_gpio_chip *chip,
+						uint32_t offset)
+{
+	struct gpioline_info info;
+
+	if (unlikely(!chip))
+		return NULL;
+
+	if (unlikely(offset >=3D chip->n_lines))
+		return NULL;
+
+	memset(&info, 0, sizeof(info));
+	info.line_offset =3D offset;
+
+	if (ioctl(chip->fd, GPIO_GET_LINEINFO_IOCTL, &info) < 0)
+		return NULL;
+
+	return l_strdup(info.consumer);
+}
+
+LIB_EXPORT struct l_gpio_writer *l_gpio_writer_new(struct l_gpio_chip *chi=
p,
+						const char *consumer,
+						uint32_t n_offsets,
+						const uint32_t offsets[],
+						const uint32_t values[])
+{
+	struct l_gpio_writer *writer;
+	struct gpiohandle_request request;
+	uint32_t i;
+
+	if (unlikely(!chip))
+		return NULL;
+
+	if (unlikely(n_offsets =3D=3D 0 || n_offsets > GPIOHANDLES_MAX))
+		return NULL;
+
+	if (unlikely(!offsets))
+		return NULL;
+
+	memset(&request, 0, sizeof(request));
+	l_strlcpy(request.consumer_label, consumer, 32);
+	request.lines =3D n_offsets;
+	request.flags =3D GPIOHANDLE_REQUEST_OUTPUT;
+
+	for (i =3D 0; i < n_offsets; i++) {
+		if (offsets[i] >=3D chip->n_lines)
+			return NULL;
+
+		request.lineoffsets[i] =3D offsets[i];
+		request.default_values[i] =3D values[i];
+	}
+
+	if (ioctl(chip->fd, GPIO_GET_LINEHANDLE_IOCTL, &request) < 0)
+		return NULL;
+
+	if (request.fd <=3D 0)
+		return NULL;
+
+	writer =3D l_new(struct l_gpio_writer, 1);
+	writer->fd =3D request.fd;
+	writer->n_offsets =3D n_offsets;
+
+	return writer;
+}
+
+LIB_EXPORT void l_gpio_writer_free(struct l_gpio_writer *writer)
+{
+	if (unlikely(!writer))
+		return;
+
+	if (writer->fd >=3D 0)
+		close(writer->fd);
+
+	l_free(writer);
+}
+
+LIB_EXPORT bool l_gpio_writer_set(struct l_gpio_writer *writer, uint32_t n=
_values,
+					const uint32_t values[])
+{
+	struct gpiohandle_data data;
+	uint32_t i;
+
+	if (unlikely(!writer))
+		return false;
+
+	if (unlikely(!values))
+		return false;
+
+	if (unlikely(n_values !=3D writer->n_offsets))
+		return false;
+
+	for (i =3D 0; i < n_values; i++)
+		data.values[i] =3D values[i];
+
+	if (ioctl(writer->fd, GPIOHANDLE_SET_LINE_VALUES_IOCTL, &data) < 0)
+		return false;
+
+	return true;
+}
+
+LIB_EXPORT struct l_gpio_reader *l_gpio_reader_new(struct l_gpio_chip *chi=
p,
+							const char *consumer,
+							uint32_t n_offsets,
+							const uint32_t offsets[])
+{
+	struct l_gpio_reader *reader;
+	struct gpiohandle_request request;
+	uint32_t i;
+
+	if (unlikely(!chip))
+		return NULL;
+
+	if (unlikely(n_offsets =3D=3D 0 || n_offsets > GPIOHANDLES_MAX))
+		return NULL;
+
+	if (unlikely(!offsets))
+		return NULL;
+
+	memset(&request, 0, sizeof(request));
+	l_strlcpy(request.consumer_label, consumer, 32);
+	request.lines =3D n_offsets;
+	request.flags =3D GPIOHANDLE_REQUEST_INPUT;
+
+	for (i =3D 0; i < n_offsets; i++) {
+		if (offsets[i] >=3D chip->n_lines)
+			return NULL;
+
+		request.lineoffsets[i] =3D offsets[i];
+	}
+
+	if (ioctl(chip->fd, GPIO_GET_LINEHANDLE_IOCTL, &request) < 0)
+		return NULL;
+
+	if (request.fd <=3D 0)
+		return NULL;
+
+	reader =3D l_new(struct l_gpio_reader, 1);
+	reader->fd =3D request.fd;
+	reader->n_offsets =3D n_offsets;
+
+	return reader;
+}
+
+LIB_EXPORT void l_gpio_reader_free(struct l_gpio_reader *reader)
+{
+	if (unlikely(!reader))
+		return;
+
+	if (reader->fd >=3D 0)
+		close(reader->fd);
+
+	l_free(reader);
+}
+
+LIB_EXPORT bool l_gpio_reader_get(struct l_gpio_reader *reader,
+					uint32_t n_values, uint32_t values[])
+{
+	struct gpiohandle_data data;
+	uint32_t i;
+
+	if (unlikely(!reader))
+		return false;
+
+	if (unlikely(n_values !=3D reader->n_offsets))
+		return false;
+
+	if (unlikely(!values))
+		return false;
+
+	if (ioctl(reader->fd, GPIOHANDLE_GET_LINE_VALUES_IOCTL, &data) < 0)
+		return false;
+
+	for (i =3D 0; i < n_values; i++)
+		values[i] =3D data.values[i];
+
+	return true;
+}
diff --git a/ell/gpio.h b/ell/gpio.h
new file mode 100644
index 0000000..0523cb0
--- /dev/null
+++ b/ell/gpio.h
@@ -0,0 +1,72 @@
+/*
+ *
+ *  Embedded Linux library
+ *
+ *  Copyright (C) 2019 Geanix. All rights reserved.
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
+struct l_gpio_writer;
+struct l_gpio_reader;
+
+char **l_gpio_chips_with_line_label(const char *line_label);
+struct l_gpio_chip *l_gpio_chip_new(const char *chip_name);
+void l_gpio_chip_free(struct l_gpio_chip *chip);
+const char *l_gpio_chip_get_label(struct l_gpio_chip *chip);
+const char *l_gpio_chip_get_name(struct l_gpio_chip *chip);
+uint32_t l_gpio_chip_get_num_lines(struct l_gpio_chip *chip);
+bool l_gpio_chip_find_line_offset(struct l_gpio_chip *chip,
+					const char *line_label,
+					uint32_t *line_offset);
+char *l_gpio_chip_get_line_label(struct l_gpio_chip *chip, uint32_t offset=
);
+char *l_gpio_chip_get_line_consumer(struct l_gpio_chip *chip, uint32_t off=
set);
+
+struct l_gpio_writer *l_gpio_writer_new(struct l_gpio_chip *chip,
+					const char *consumer,
+					uint32_t n_offsets,
+					const uint32_t offsets[],
+					const uint32_t values[]);
+void l_gpio_writer_free(struct l_gpio_writer *writer);
+bool l_gpio_writer_set(struct l_gpio_writer *writer, uint32_t n_values,
+			const uint32_t values[]);
+const char *l_gpio_writer_get_label(struct l_gpio_writer *writer);
+
+struct l_gpio_reader *l_gpio_reader_new(struct l_gpio_chip *chip,
+					const char *consumer,
+					uint32_t n_offsets,
+					const uint32_t offsets[]);
+void l_gpio_reader_free(struct l_gpio_reader *reader);
+bool l_gpio_reader_get(struct l_gpio_reader *reader, uint32_t n_values,
+			uint32_t values[]);
+const char *l_gpio_reader_get_label(struct l_gpio_reader *reader);
+
+#ifdef __cplusplus
+}
+#endif
+
+#endif /* __ELL_GPIO_H */
-- =

2.22.0


--===============7051023205095167609==--

