Content-Type: multipart/mixed; boundary="===============0693534791277834975=="
MIME-Version: 1.0
From: Lukas Rusak <lrusak@libreelec.tv>
Subject: [PATCH 1/5] ell: remove kdbus
Date: Fri, 17 Mar 2017 13:10:27 -0700
Message-ID: <20170317201031.4927-1-lrusak@libreelec.tv>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0693534791277834975==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Lukas Rusak <lorusak@gmail.com>

---
 ell/dbus-kernel.c  | 971 -------------------------------------------------=
----
 ell/dbus-message.c | 129 +------
 ell/dbus-private.h |  40 ---
 ell/dbus.c         | 265 +--------------
 4 files changed, 3 insertions(+), 1402 deletions(-)
 delete mode 100644 ell/dbus-kernel.c

diff --git a/ell/dbus-kernel.c b/ell/dbus-kernel.c
deleted file mode 100644
index 4d7cae3..0000000
--- a/ell/dbus-kernel.c
+++ /dev/null
@@ -1,971 +0,0 @@
-/*
- *
- *  Embedded Linux library
- *
- *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.
- *
- *  This library is free software; you can redistribute it and/or
- *  modify it under the terms of the GNU Lesser General Public
- *  License as published by the Free Software Foundation; either
- *  version 2.1 of the License, or (at your option) any later version.
- *
- *  This library is distributed in the hope that it will be useful,
- *  but WITHOUT ANY WARRANTY; without even the implied warranty of
- *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- *  Lesser General Public License for more details.
- *
- *  You should have received a copy of the GNU Lesser General Public
- *  License along with this library; if not, write to the Free Software
- *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 =
 USA
- *
- */
-
-#ifdef HAVE_CONFIG_H
-#include <config.h>
-#endif
-
-#define _GNU_SOURCE
-#include <stdio.h>
-#include <stdlib.h>
-#include <fcntl.h>
-#include <unistd.h>
-#include <string.h>
-#include <alloca.h>
-#include <errno.h>
-#include <sys/mman.h>
-#include <sys/ioctl.h>
-#include <time.h>
-
-#include "linux/kdbus.h"
-
-#include "private.h"
-#include "dbus.h"
-#include "dbus-private.h"
-#include "siphash-private.h"
-
-#define KDBUS_ITEM_HEADER_SIZE offsetof(struct kdbus_item, data)
-#define KDBUS_POOL_SIZE (16*1024*1024)
-
-#define KDBUS_ITEM_FOREACH(item, head, first)				\
-	for (item =3D head->first;					\
-		(void *)(item) < (void *)(head) + (head)->size;		\
-		item =3D KDBUS_ITEM_NEXT(item))				\
-
-#define DEFAULT_BLOOM_SIZE (512 / 8)
-#define DEFAULT_BLOOM_N_HASH (8)
-
-#define HASH_KEY(v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15) \
-        { 0x##v0, 0x##v1, 0x##v2, 0x##v3, 0x##v4, 0x##v5, 0x##v6, 0x##v7, \
-	0x##v8, 0x##v9, 0x##v10, 0x##v11, 0x##v12, 0x##v13, 0x##v14, 0x##v15 }
-
-#define KDBUS_ITEM_SIZE(actual) \
-	align_len(actual + offsetof(struct kdbus_item, data), 8)
-
-static inline struct kdbus_item *KDBUS_ITEM_NEXT(struct kdbus_item *item)
-{
-	size_t aligned =3D align_len(item->size, 8);
-	void *start =3D item;
-
-	return start + aligned;
-}
-
-static inline unsigned int __u64_log2(uint64_t n)
-{
-	if (n =3D=3D 0)
-		return 0;
-
-	return __builtin_clzll(n) ^ 63U;
-}
-
-static inline void set_bit(uint64_t filter[], size_t b)
-{
-	filter[b >> 6] |=3D 1ULL << (b & 63);
-}
-
-static const uint8_t hash_keys[][16] =3D {
-	HASH_KEY(b9,66,0b,f0,46,70,47,c1,88,75,c4,9c,54,b9,bd,15),
-	HASH_KEY(aa,a1,54,a2,e0,71,4b,39,bf,e1,dd,2e,9f,c5,4a,3b),
-	HASH_KEY(63,fd,ae,be,cd,82,48,12,a1,6e,41,26,cb,fa,a0,c8),
-	HASH_KEY(23,be,45,29,32,d2,46,2d,82,03,52,28,fe,37,17,f5),
-	HASH_KEY(56,3b,bf,ee,5a,4f,43,39,af,aa,94,08,df,f0,fc,10),
-	HASH_KEY(31,80,c8,73,c7,ea,46,d3,aa,25,75,0f,9e,4c,09,29),
-	HASH_KEY(7d,f7,18,4b,7b,a4,44,d5,85,3c,06,e0,65,53,96,6d),
-	HASH_KEY(f2,77,e9,6f,93,b5,4e,71,9a,0c,34,88,39,25,bf,35),
-};
-
-static void bloom_update(uint64_t filter[], size_t size, uint8_t num_hash,
-				const void *data, size_t data_size)
-{
-	uint8_t hashed[8];
-	uint64_t n_bits;
-	unsigned int index_size;
-	unsigned int i;
-	unsigned int hash_index;
-	unsigned int unused_bytes =3D 0;
-
-	if (unlikely(num_hash =3D=3D 0))
-		return;
-
-	if (unlikely(size =3D=3D 0))
-		return;
-
-	n_bits =3D size * 8;
-	index_size =3D (__u64_log2(n_bits) + 7) / 8;
-
-	if (unlikely(index_size > sizeof(uint32_t)))
-		return;
-
-	for (i =3D 0, hash_index =3D 0; i < num_hash; i++) {
-		uint32_t index =3D 0;
-		unsigned int j;
-
-		for (j =3D 0; j < index_size; j++) {
-			if (unused_bytes =3D=3D 0) {
-				_siphash24(hashed, data, data_size,
-						hash_keys[hash_index++]);
-				unused_bytes =3D 8;
-			}
-
-			index =3D index << 8;
-			index |=3D hashed[8 - unused_bytes];
-			unused_bytes -=3D 1;
-		}
-
-		index &=3D n_bits - 1;
-		set_bit(filter, index);
-	}
-}
-
-void _dbus_kernel_bloom_add(uint64_t filter[], size_t size, uint8_t num_ha=
sh,
-				const char *prefix, const char *str)
-{
-	char *buf;
-	size_t len;
-
-	len =3D strlen(prefix) + 1 + strlen(str) + 1;
-	buf =3D alloca(len);
-
-	sprintf(buf, "%s:%s", prefix, str);
-
-	bloom_update(filter, size, num_hash, buf, len - 1);
-}
-
-void _dbus_kernel_bloom_add_parents(uint64_t filter[], size_t size,
-					uint8_t num_hash, const char *prefix,
-					const char *str, const char sep)
-{
-	char *buf;
-	size_t len;
-	int start;
-
-	len =3D strlen(prefix) + 1 + strlen(str) + 1;
-	buf =3D alloca(len);
-
-	sprintf(buf, "%s:%n%s", prefix, &start, str);
-
-	while (true) {
-		char *s =3D strrchr(buf + start, sep);
-
-		if (!s)
-			break;
-
-		if (s =3D=3D buf + start)
-			break;
-
-		*s =3D '\0';
-		bloom_update(filter, size, num_hash, buf, s - buf);
-	}
-}
-
-int _dbus_kernel_create_bus(const char *name)
-{
-	struct {
-		struct kdbus_cmd head;
-		/* bloom size item */
-		uint64_t bloom_size;
-		uint64_t bloom_type;
-		struct kdbus_bloom_parameter bloom_param;
-		/* name item */
-		uint64_t name_size;
-		uint64_t name_type;
-		char name_param[64];
-	} bus_make;
-	int fd;
-
-	fd =3D open("/dev/kdbus/control", O_RDWR | O_CLOEXEC);
-	if (fd < 0)
-		return -1;
-
-	memset(&bus_make, 0, sizeof(bus_make));
-	/* bloom size item */
-	bus_make.bloom_size =3D KDBUS_ITEM_HEADER_SIZE +
-					sizeof(bus_make.bloom_param);
-	bus_make.bloom_type =3D KDBUS_ITEM_BLOOM_PARAMETER;
-	bus_make.bloom_param.size =3D DEFAULT_BLOOM_SIZE;
-	bus_make.bloom_param.n_hash =3D DEFAULT_BLOOM_N_HASH;
-	/* name item */
-	snprintf(bus_make.name_param, sizeof(bus_make.name_param), "%s", name);
-	bus_make.name_size =3D KDBUS_ITEM_HEADER_SIZE +
-				strlen(bus_make.name_param) + 1;
-	bus_make.name_type =3D KDBUS_ITEM_MAKE_NAME;
-	/* bus make head */
-	bus_make.head.size =3D align_len(sizeof(bus_make.head) +
-					bus_make.bloom_size +
-					bus_make.name_size, 8);
-	bus_make.head.flags =3D KDBUS_MAKE_ACCESS_WORLD;
-
-	if (ioctl(fd, KDBUS_CMD_BUS_MAKE, &bus_make) < 0) {
-		close(fd);
-		return -1;
-        }
-
-	return fd;
-}
-
-void _dbus_kernel_unmap_pool(void *pool)
-{
-	munmap(pool, KDBUS_POOL_SIZE);
-}
-
-int _dbus_kernel_hello(int fd, const char *connection_name,
-			size_t *bloom_size, uint8_t *bloom_n_hash,
-			uint64_t *id, void **pool, char **guid)
-{
-	size_t len =3D strlen(connection_name);
-	size_t size;
-	struct kdbus_cmd_hello *hello;
-	struct kdbus_item *item;
-	int ret;
-	struct kdbus_cmd_free cmd_free;
-
-	size =3D align_len(sizeof(struct kdbus_cmd_hello), 8);
-	size +=3D KDBUS_ITEM_SIZE(len + 1);
-
-	hello =3D alloca(size);
-	memset(hello, 0, size);
-
-	hello->size =3D size;
-	hello->flags |=3D KDBUS_HELLO_ACCEPT_FD;
-	hello->pool_size =3D KDBUS_POOL_SIZE;
-
-	item =3D hello->items;
-	item->size =3D KDBUS_ITEM_HEADER_SIZE + len + 1;
-	item->type =3D KDBUS_ITEM_CONN_DESCRIPTION;
-	strcpy(item->str, connection_name);
-
-	ret =3D ioctl(fd, KDBUS_CMD_HELLO, hello);
-	if (ret < 0) {
-		ret =3D -errno;
-		goto done;
-	}
-
-        /* Check for incompatible flags (upper 32 bits) */
-        if (hello->bus_flags > 0xFFFFFFFFULL ||
-			hello->flags > 0xFFFFFFFFULL) {
-		ret =3D -ENOTSUP;
-		goto done;
-	}
-
-	*pool =3D mmap(NULL, KDBUS_POOL_SIZE, PROT_READ, MAP_SHARED, fd, 0);
-	if (*pool =3D=3D MAP_FAILED) {
-		*pool =3D NULL;
-		ret =3D -errno;
-		goto done;
-	}
-
-	*bloom_size =3D DEFAULT_BLOOM_SIZE;
-	*bloom_n_hash =3D DEFAULT_BLOOM_N_HASH;
-
-	KDBUS_ITEM_FOREACH(item, hello, items) {
-		switch (item->type) {
-		case KDBUS_ITEM_BLOOM_PARAMETER:
-			*bloom_size =3D item->bloom_parameter.size;
-			*bloom_n_hash =3D item->bloom_parameter.n_hash;
-			break;
-		}
-	}
-
-	*id =3D hello->id;
-	*guid =3D l_strdup_printf("%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx"
-				"%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx%02hhx"
-				"%02hhx%02hhx",
-				hello->id128[0], hello->id128[1],
-				hello->id128[2], hello->id128[3],
-				hello->id128[4], hello->id128[5],
-				hello->id128[6], hello->id128[7],
-				hello->id128[8], hello->id128[9],
-				hello->id128[10], hello->id128[11],
-				hello->id128[12], hello->id128[13],
-				hello->id128[14], hello->id128[15]);
-
-done:
-	memset(&cmd_free, 0, sizeof(cmd_free));
-	cmd_free.size =3D sizeof(cmd_free);
-	cmd_free.offset =3D hello->offset;
-
-	ioctl(fd, KDBUS_CMD_FREE, &cmd_free);
-
-	return ret;
-}
-
-int _dbus_kernel_send(int fd, size_t bloom_size, uint8_t bloom_n_hash,
-			struct l_dbus_message *message)
-{
-	size_t kmsg_size;
-	bool unique;
-	uint64_t uninitialized_var(id);
-	const char *dest;
-	size_t dest_len;
-	struct kdbus_item *item;
-	void *header;
-	size_t header_size;
-	void *footer;
-	size_t footer_size;
-	int ret;
-	struct kdbus_cmd_send cmd;
-	uint32_t num_fds;
-	int *fds;
-	L_AUTO_FREE_VAR(struct kdbus_msg *, kmsg);
-
-	dest =3D l_dbus_message_get_destination(message);
-	if (dest)
-		unique =3D _dbus_parse_unique_name(dest, &id);
-	else
-		unique =3D false;
-
-	dest_len =3D dest ? strlen(dest) : 0;
-
-	kmsg_size =3D sizeof(struct kdbus_msg);
-
-	/* Reserve space for header + body */
-	kmsg_size +=3D KDBUS_ITEM_SIZE(sizeof(struct kdbus_vec));
-	kmsg_size +=3D KDBUS_ITEM_SIZE(sizeof(struct kdbus_vec));
-
-	/* Reserve space for bloom filter */
-	if (_dbus_message_get_type(message) =3D=3D DBUS_MESSAGE_TYPE_SIGNAL)
-		kmsg_size +=3D KDBUS_ITEM_SIZE(sizeof(struct kdbus_bloom_filter) +
-						bloom_size);
-
-	/* Reserve space for well-known destination header */
-	if (dest && !unique)
-		kmsg_size +=3D KDBUS_ITEM_SIZE(dest_len + 1);
-
-	/* Reserve space for fds */
-	fds =3D _dbus_message_get_fds(message, &num_fds);
-	if (num_fds)
-		kmsg_size +=3D KDBUS_ITEM_SIZE(num_fds * sizeof(int));
-
-	kmsg =3D aligned_alloc(8, kmsg_size);
-	if (!kmsg)
-		return -ENOMEM;
-
-	memset(kmsg, 0, kmsg_size);
-	item =3D kmsg->items;
-
-	kmsg->payload_type =3D KDBUS_PAYLOAD_DBUS;
-	kmsg->priority =3D 0;
-	kmsg->cookie =3D _dbus_message_get_serial(message);
-
-	if (l_dbus_message_get_no_autostart(message))
-		kmsg->flags |=3D KDBUS_MSG_NO_AUTO_START;
-
-	if (!l_dbus_message_get_no_reply(message))
-		kmsg->flags |=3D KDBUS_MSG_EXPECT_REPLY;
-
-	if (!unique && dest) {
-		kmsg->dst_id =3D KDBUS_DST_ID_NAME;
-		item->size =3D KDBUS_ITEM_HEADER_SIZE + dest_len + 1;
-		item->type =3D KDBUS_ITEM_DST_NAME;
-		strcpy(item->str, dest);
-		item =3D KDBUS_ITEM_NEXT(item);
-	} else if (!unique && !dest)
-		kmsg->dst_id =3D KDBUS_DST_ID_BROADCAST;
-	else
-		kmsg->dst_id =3D id;
-
-	switch(_dbus_message_get_type(message)) {
-	case DBUS_MESSAGE_TYPE_METHOD_RETURN:
-	case DBUS_MESSAGE_TYPE_ERROR:
-	{
-		uint32_t reply_cookie =3D _dbus_message_get_reply_serial(message);
-
-		if (reply_cookie =3D=3D 0)
-			return -EINVAL;
-
-		kmsg->cookie_reply =3D reply_cookie;
-		break;
-	}
-	case DBUS_MESSAGE_TYPE_METHOD_CALL:
-		if (!l_dbus_message_get_no_reply(message)) {
-			struct timespec now;
-
-			clock_gettime(CLOCK_MONOTONIC_COARSE, &now);
-
-			kmsg->timeout_ns =3D
-				now.tv_sec * 1000000000ULL + now.tv_nsec +
-				30000 * 1000000ULL;
-		}
-
-		break;
-	case DBUS_MESSAGE_TYPE_SIGNAL:
-		kmsg->flags |=3D KDBUS_MSG_SIGNAL;
-
-		item->size =3D KDBUS_ITEM_HEADER_SIZE +
-				sizeof(struct kdbus_bloom_filter) + bloom_size;
-		item->type =3D KDBUS_ITEM_BLOOM_FILTER;
-
-		item->bloom_filter.generation =3D 0;
-		_dbus_kernel_calculate_bloom(message,
-					(uint64_t *) item->bloom_filter.data,
-					bloom_size, bloom_n_hash);
-
-		item =3D KDBUS_ITEM_NEXT(item);
-		break;
-	}
-
-	header =3D _dbus_message_get_header(message, &header_size);
-	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct kdbus_vec);
-	item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
-	item->vec.address =3D (uintptr_t) header;
-	item->vec.size =3D header_size;
-	item =3D KDBUS_ITEM_NEXT(item);
-
-	footer =3D _dbus_message_get_footer(message, &footer_size);
-
-	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(struct kdbus_vec);
-	item->type =3D KDBUS_ITEM_PAYLOAD_VEC;
-	item->vec.address =3D (uintptr_t) footer;
-	item->vec.size =3D footer_size;
-	item =3D KDBUS_ITEM_NEXT(item);
-
-	if (num_fds) {
-		item->size =3D KDBUS_ITEM_HEADER_SIZE + num_fds * sizeof(int);
-		item->type =3D KDBUS_ITEM_FDS;
-		memcpy(item->fds, fds, num_fds * sizeof(int));
-		item =3D KDBUS_ITEM_NEXT(item);
-	}
-
-	kmsg->size =3D (void *)item - (void *)kmsg;
-
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.size =3D sizeof(cmd);
-	cmd.msg_address =3D (uintptr_t) kmsg;
-
-	ret =3D ioctl(fd, KDBUS_CMD_SEND, &cmd);
-	if (ret < 0)
-		return -errno;
-
-	return 0;
-}
-
-static void collect_body_parts(struct kdbus_msg *kmsg, size_t size, void *=
*data)
-{
-	struct kdbus_item *item;
-	size_t offset =3D 0;
-
-	*data =3D l_malloc(size);
-
-	KDBUS_ITEM_FOREACH(item, kmsg, items) {
-		switch (item->type) {
-		case KDBUS_ITEM_PAYLOAD_OFF:
-			memcpy(*data + offset, (void *) kmsg + item->vec.offset,
-				item->vec.size);
-
-			offset +=3D item->vec.size;
-
-			break;
-		}
-	}
-}
-
-static int _dbus_kernel_make_message(struct kdbus_msg *kmsg,
-				struct l_dbus_message **out_message)
-{
-	struct kdbus_item *item;
-	void *data =3D 0;
-	size_t size =3D 0;
-	struct dbus_header *hdr;
-	const char *destination =3D 0;
-	char unique_bus_name[128];
-	uint32_t num_fds =3D 0;
-	int *fds =3D NULL;
-	unsigned int i;
-
-	KDBUS_ITEM_FOREACH(item, kmsg, items) {
-		switch (item->type) {
-		case KDBUS_ITEM_PAYLOAD_OFF:
-			if (!size) {
-				if (item->vec.size < sizeof(struct dbus_header))
-					return -EBADMSG;
-
-				hdr =3D (void *)kmsg + item->vec.offset;
-			}
-
-			size +=3D item->vec.size;
-
-			break;
-		case KDBUS_ITEM_PAYLOAD_MEMFD:
-			if (!size)
-				return -EBADMSG;
-
-			return -ENOTSUP;
-		case KDBUS_ITEM_FDS:
-			if (fds || item->size <=3D KDBUS_ITEM_HEADER_SIZE)
-				return -EBADMSG;
-
-			num_fds =3D (item->size - KDBUS_ITEM_HEADER_SIZE) /
-				sizeof(int);
-			fds =3D item->fds;
-
-			/* Set FD_CLOEXEC on all file descriptors */
-			for (i =3D 0; i < num_fds; i++) {
-				long flags;
-
-				if (fds[i] =3D=3D -1)
-					continue;
-
-				flags =3D fcntl(fds[i], F_GETFD, NULL);
-				if (flags < 0 || (flags & FD_CLOEXEC))
-					continue;
-
-				fcntl(fds[i], F_SETFD, flags | FD_CLOEXEC);
-			}
-
-			break;
-		case KDBUS_ITEM_DST_NAME:
-			if (!_dbus_valid_bus_name(item->str))
-				return -EBADMSG;
-
-			destination =3D item->str;
-			break;
-		}
-	}
-
-	if (!size)
-		return -EBADMSG;
-
-	if (hdr->endian !=3D DBUS_NATIVE_ENDIAN)
-		return -EPROTOTYPE;
-
-	if (hdr->version !=3D 2)
-		return -EPROTO;
-
-	collect_body_parts(kmsg, size, &data);
-
-	*out_message =3D dbus_message_from_blob(data, size, fds, num_fds);
-
-	l_free(data);
-
-	if (!*out_message)
-		return -EBADMSG;
-
-	if (kmsg->src_id !=3D KDBUS_SRC_ID_KERNEL) {
-		sprintf(unique_bus_name, ":1.%llu", kmsg->src_id);
-		_dbus_message_set_sender(*out_message, unique_bus_name);
-	} else
-		_dbus_message_set_sender(*out_message, "org.freedesktop.DBus");
-
-	switch (kmsg->dst_id) {
-	case KDBUS_DST_ID_NAME:
-		break;
-	case KDBUS_DST_ID_BROADCAST:
-		break;
-	default:
-		sprintf(unique_bus_name, ":1.%llu", kmsg->dst_id);
-		_dbus_message_set_destination(*out_message, unique_bus_name);
-	}
-
-	if (destination)
-		_dbus_message_set_destination(*out_message, destination);
-
-	return 0;
-}
-
-int _dbus_kernel_recv(int fd, void *kdbus_pool,
-			l_dbus_message_func_t message_func,
-			_dbus_name_owner_change_func_t name_owner_change_func,
-			void *user_data)
-{
-	struct kdbus_cmd_recv recv_cmd;
-	struct kdbus_cmd_free cmd_free;
-	struct kdbus_msg *msg;
-	struct l_dbus_message *dbus_msg;
-	struct kdbus_item *item;
-	int r;
-	size_t min_size;
-	const char *error;
-	char unique_bus_name[128];
-
-	memset(&recv_cmd, 0, sizeof(recv_cmd));
-
-	recv_cmd.size =3D sizeof(recv_cmd);
-
-	r =3D ioctl(fd, KDBUS_CMD_RECV, &recv_cmd);
-	if (r < 0)
-		return -errno;
-
-	msg =3D (struct kdbus_msg *)(kdbus_pool + recv_cmd.msg.offset);
-
-	switch (msg->payload_type) {
-	case KDBUS_PAYLOAD_DBUS:
-		r =3D _dbus_kernel_make_message(msg, &dbus_msg);
-		if (!r)
-			message_func(dbus_msg, user_data);
-		break;
-	case KDBUS_PAYLOAD_KERNEL:
-		if (msg->size < sizeof(*msg) + KDBUS_ITEM_HEADER_SIZE) {
-			r =3D -EPROTONOSUPPORT;
-			break;
-		}
-
-		item =3D msg->items;
-
-		switch (item->type) {
-		case KDBUS_ITEM_NAME_ADD:
-		case KDBUS_ITEM_NAME_CHANGE:
-		case KDBUS_ITEM_NAME_REMOVE:
-			min_size =3D KDBUS_ITEM_SIZE(sizeof(item->name_change));
-			if (msg->size < sizeof(*msg) + min_size ||
-					item->size < min_size) {
-				r =3D -EPROTONOSUPPORT;
-				break;
-			}
-
-			name_owner_change_func(item->name_change.name,
-						item->name_change.old_id.id,
-						item->name_change.new_id.id,
-						user_data);
-			break;
-
-		case KDBUS_ITEM_ID_ADD:
-		case KDBUS_ITEM_ID_REMOVE:
-			min_size =3D KDBUS_ITEM_SIZE(sizeof(item->id_change));
-			if (msg->size < sizeof(*msg) + min_size ||
-					item->size < min_size) {
-				r =3D -EPROTONOSUPPORT;
-				break;
-			}
-
-			sprintf(unique_bus_name, ":1.%llu", item->id_change.id);
-
-			if (item->type =3D=3D KDBUS_ITEM_ID_ADD)
-				name_owner_change_func(unique_bus_name,
-							0, item->id_change.id,
-							user_data);
-			else
-				name_owner_change_func(unique_bus_name,
-							item->id_change.id, 0,
-							user_data);
-			break;
-
-		case KDBUS_ITEM_REPLY_TIMEOUT:
-		case KDBUS_ITEM_REPLY_DEAD:
-			if (item->type =3D=3D KDBUS_ITEM_REPLY_TIMEOUT)
-				error =3D "Did not receive a reply.";
-			else
-				error =3D "Message recipient disconnected from "
-					"message bus without replying.";
-
-			dbus_msg =3D _dbus_message_new_error(
-					2, msg->cookie_reply, NULL,
-					"org.freedesktop.DBus.Error.NoReply",
-					error);
-			if (dbus_msg)
-				message_func(dbus_msg, user_data);
-
-			break;
-
-		default:
-			break;
-		}
-
-		break;
-	default:
-		r =3D -EPROTONOSUPPORT;
-		break;
-	}
-
-	memset(&cmd_free, 0, sizeof(cmd_free));
-	cmd_free.size =3D sizeof(cmd_free);
-	cmd_free.offset =3D recv_cmd.msg.offset;
-
-	ioctl(fd, KDBUS_CMD_FREE, &cmd_free);
-
-	return r;
-}
-
-int _dbus_kernel_name_acquire(int fd, const char *name, bool allow_replace=
ment,
-				bool replace_existing, bool queue, bool *queued)
-{
-	struct {
-		struct kdbus_cmd head;
-		char param[64];
-	} cmd_name;
-	struct kdbus_item *item;
-	size_t nlen;
-
-	if (!name)
-		return false;
-
-	nlen =3D strlen(name) + 1;
-	if (KDBUS_ITEM_SIZE(nlen) > sizeof(cmd_name.param))
-		return false;
-
-	memset(&cmd_name, 0, sizeof(cmd_name));
-
-	cmd_name.head.size =3D sizeof(cmd_name.head) + KDBUS_ITEM_SIZE(nlen);
-
-	item =3D cmd_name.head.items;
-	item->size =3D KDBUS_ITEM_HEADER_SIZE + nlen;
-	item->type =3D KDBUS_ITEM_NAME;
-	strcpy(item->str, name);
-
-	if (replace_existing)
-		cmd_name.head.flags |=3D KDBUS_NAME_REPLACE_EXISTING;
-
-	if (allow_replacement)
-		cmd_name.head.flags |=3D KDBUS_NAME_ALLOW_REPLACEMENT;
-
-	if (queue)
-		cmd_name.head.flags |=3D KDBUS_NAME_QUEUE;
-
-	if (ioctl(fd, KDBUS_CMD_NAME_ACQUIRE, &cmd_name) < 0)
-		return -errno;
-
-	if (queued)
-		*queued =3D !!(cmd_name.head.flags & KDBUS_NAME_IN_QUEUE);
-
-	return 0;
-}
-
-int _dbus_kernel_add_match(int fd, uint64_t bloom_size, uint64_t bloom_n_h=
ash,
-				const struct _dbus_filter_condition *rule,
-				int rule_len, unsigned int id)
-{
-	struct kdbus_item *bloom, *item;
-	struct kdbus_cmd_match *cmd;
-	size_t cmd_size;
-	const char *prefix;
-	char argstr[8];
-	int r, i;
-	uint64_t sender_id;
-
-	cmd_size =3D sizeof(struct kdbus_cmd_match);
-	cmd_size +=3D KDBUS_ITEM_SIZE(bloom_size);
-
-	for (i =3D 0; i < rule_len; i++) {
-		switch (rule[i].type) {
-		case L_DBUS_MATCH_SENDER:
-			if (_dbus_parse_unique_name(rule->value, NULL))
-				cmd_size +=3D KDBUS_ITEM_SIZE(sizeof(item->id));
-			else
-				cmd_size +=3D KDBUS_ITEM_SIZE(
-						strlen(rule[i].value) + 1);
-			break;
-		default:
-			break;
-		}
-	}
-
-	cmd =3D alloca(cmd_size);
-	memset(cmd, 0, cmd_size);
-	cmd->size =3D cmd_size;
-	cmd->cookie =3D id;
-	item =3D cmd->items;
-
-	bloom =3D item;
-	bloom->size =3D KDBUS_ITEM_HEADER_SIZE + bloom_size;
-	bloom->type =3D KDBUS_ITEM_BLOOM_MASK;
-
-	for (; rule_len; rule++, rule_len--) {
-		switch ((int) rule->type) {
-		case L_DBUS_MATCH_SENDER:
-			item =3D KDBUS_ITEM_NEXT(item);
-
-			if (_dbus_parse_unique_name(rule->value, &sender_id)) {
-				item->size =3D KDBUS_ITEM_HEADER_SIZE +
-					strlen(rule->value) + 1;
-				item->type =3D KDBUS_ITEM_ID;
-				item->id =3D id;
-			} else {
-				item->size =3D KDBUS_ITEM_HEADER_SIZE +
-					strlen(rule->value) + 1;
-				item->type =3D KDBUS_ITEM_NAME;
-				strcpy(item->str, rule->value);
-			}
-
-			continue;
-		case L_DBUS_MATCH_TYPE:
-			prefix =3D "message-type";
-			break;
-		case L_DBUS_MATCH_PATH:
-			prefix =3D "path";
-			break;
-		case L_DBUS_MATCH_INTERFACE:
-			prefix =3D "interface";
-			break;
-		case L_DBUS_MATCH_MEMBER:
-			prefix =3D "member";
-			break;
-		case L_DBUS_MATCH_ARG0...(L_DBUS_MATCH_ARG0 + 63):
-			prefix =3D argstr;
-			snprintf(argstr, sizeof(argstr), "arg%i",
-					rule->type - L_DBUS_MATCH_ARG0);
-			break;
-		default:
-			return -ENOTSUP;
-		}
-
-		_dbus_kernel_bloom_add((uint64_t *) bloom->data64, bloom_size,
-					bloom_n_hash, prefix, rule->value);
-	}
-
-	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, cmd);
-	if (r < 0)
-		return -errno;
-
-	return 0;
-}
-
-int _dbus_kernel_remove_match(int fd, unsigned int id)
-{
-	struct kdbus_cmd_match cmd;
-	int r;
-
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.size =3D sizeof(cmd);
-	cmd.cookie =3D id;
-
-	r =3D ioctl(fd, KDBUS_CMD_MATCH_REMOVE, &cmd);
-	if (r < 0)
-		return -errno;
-
-	return 0;
-}
-
-int _dbus_kernel_enable_name_owner_notify(int fd)
-{
-	struct {
-		struct kdbus_cmd_match cmd;
-		uint8_t param[KDBUS_ITEM_SIZE(
-				sizeof(struct kdbus_notify_name_change)) +
-				KDBUS_ITEM_SIZE(
-				sizeof(struct kdbus_notify_id_change))];
-	} cmd_match;
-	struct kdbus_item *item;
-	int r;
-
-	memset(&cmd_match, 0, sizeof(cmd_match));
-	item =3D cmd_match.cmd.items;
-	item->type =3D KDBUS_ITEM_NAME_ADD;
-	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->name_change);
-	item->name_change.old_id.id =3D KDBUS_MATCH_ID_ANY;
-	item->name_change.new_id.id =3D KDBUS_MATCH_ID_ANY;
-	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
-
-	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
-	if (r < 0)
-		return -errno;
-
-	memset(&cmd_match, 0, sizeof(cmd_match));
-	item =3D cmd_match.cmd.items;
-	item->type =3D KDBUS_ITEM_NAME_CHANGE;
-	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->name_change);
-	item->name_change.old_id.id =3D KDBUS_MATCH_ID_ANY;
-	item->name_change.new_id.id =3D KDBUS_MATCH_ID_ANY;
-	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
-
-	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
-	if (r < 0)
-		return -errno;
-
-	memset(&cmd_match, 0, sizeof(cmd_match));
-	item =3D cmd_match.cmd.items;
-	item->type =3D KDBUS_ITEM_NAME_REMOVE;
-	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->name_change);
-	item->name_change.old_id.id =3D KDBUS_MATCH_ID_ANY;
-	item->name_change.new_id.id =3D KDBUS_MATCH_ID_ANY;
-	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
-
-	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
-	if (r < 0)
-		return -errno;
-
-	memset(&cmd_match, 0, sizeof(cmd_match));
-	item =3D cmd_match.cmd.items;
-	item->type =3D KDBUS_ITEM_ID_ADD;
-	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->id_change);
-	item->id_change.id =3D KDBUS_MATCH_ID_ANY;
-	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
-
-	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
-	if (r < 0)
-		return -errno;
-
-	memset(&cmd_match, 0, sizeof(cmd_match));
-	item =3D cmd_match.cmd.items;
-	item->type =3D KDBUS_ITEM_ID_REMOVE;
-	item->size =3D KDBUS_ITEM_HEADER_SIZE + sizeof(item->id_change);
-	item->id_change.id =3D KDBUS_MATCH_ID_ANY;
-	cmd_match.cmd.size =3D sizeof(cmd_match.cmd) + item->size;
-
-	r =3D ioctl(fd, KDBUS_CMD_MATCH_ADD, &cmd_match);
-	if (r < 0)
-		return -errno;
-
-	return 0;
-}
-
-uint64_t _dbus_kernel_get_name_owner(int fd, void *kdbus_pool,
-					const char *name)
-{
-	struct kdbus_cmd_list cmd;
-	struct kdbus_cmd_free cmd_free;
-	struct kdbus_info *entry, *end;
-	struct kdbus_item *item;
-	const char *entry_name;
-	uint64_t owner_id =3D 0;
-	bool is_unique;
-	uint64_t uninitialized_var(id);
-
-	is_unique =3D _dbus_parse_unique_name(name, &id);
-
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.size =3D sizeof(cmd);
-	cmd.flags =3D is_unique ? KDBUS_LIST_UNIQUE : KDBUS_LIST_NAMES;
-
-	if (ioctl(fd, KDBUS_CMD_LIST, &cmd) < 0)
-		return 0;
-
-	entry =3D kdbus_pool + cmd.offset;
-	end =3D (void *) entry + cmd.list_size;
-
-	for (; entry < end; entry =3D (void *) entry + entry->size) {
-		entry_name =3D NULL;
-
-		KDBUS_ITEM_FOREACH(item, entry, items) {
-			if (item->type =3D=3D KDBUS_ITEM_OWNED_NAME) {
-				entry_name =3D item->name.name;
-				break;
-			}
-		}
-
-		if (entry_name && !strcmp(entry_name, name)) {
-			owner_id =3D entry->id;
-			break;
-		}
-
-		if (is_unique && id =3D=3D entry->id) {
-			owner_id =3D id;
-			break;
-		}
-	}
-
-	memset(&cmd_free, 0, sizeof(cmd_free));
-	cmd_free.size =3D sizeof(cmd_free);
-	cmd_free.offset =3D cmd.offset;
-
-	ioctl(fd, KDBUS_CMD_FREE, &cmd_free);
-
-	return owner_id;
-}
diff --git a/ell/dbus-message.c b/ell/dbus-message.c
index b5c9222..fca38f4 100644
--- a/ell/dbus-message.c
+++ b/ell/dbus-message.c
@@ -73,8 +73,6 @@ struct l_dbus_message {
 	uint32_t num_fds;
 =

 	bool sealed : 1;
-	bool kdbus_sender : 1;
-	bool kdbus_destination : 1;
 	bool signature_free : 1;
 };
 =

@@ -137,20 +135,14 @@ void _dbus_message_set_serial(struct l_dbus_message *=
msg, uint32_t serial)
 {
 	struct dbus_header *hdr =3D msg->header;
 =

-	if (_dbus_message_is_gvariant(msg))
-		hdr->kdbus.cookie =3D serial;
-	else
-		hdr->dbus1.serial =3D serial;
+	hdr->dbus1.serial =3D serial;
 }
 =

 uint32_t _dbus_message_get_serial(struct l_dbus_message *msg)
 {
 	struct dbus_header *hdr =3D msg->header;
 =

-	if (_dbus_message_is_gvariant(msg))
-		return hdr->kdbus.cookie;
-	else
-		return hdr->dbus1.serial;
+	return hdr->dbus1.serial;
 }
 =

 LIB_EXPORT bool l_dbus_message_set_no_reply(struct l_dbus_message *msg, bo=
ol on)
@@ -430,12 +422,6 @@ LIB_EXPORT void l_dbus_message_unref(struct l_dbus_mes=
sage *message)
 		l_free(message->sender);
 	}
 =

-	if (message->kdbus_sender)
-		l_free(message->sender);
-
-	if (message->kdbus_destination)
-		l_free(message->destination);
-
 	if (message->signature_free)
 		l_free(message->signature);
 =

@@ -689,10 +675,6 @@ static bool valid_header(const struct dbus_header *hdr)
 	if (hdr->version =3D=3D 1) {
 		if (hdr->dbus1.serial =3D=3D 0)
 			return false;
-	} else {
-		/* We don't support 64-bit GVariant cookies */
-		if (hdr->kdbus.cookie =3D=3D 0 || (hdr->kdbus.cookie >> 32))
-			return false;
 	}
 =

 	return true;
@@ -1636,7 +1618,6 @@ void _dbus_message_set_sender(struct l_dbus_message *=
message,
 	l_free(message->sender);
 =

 	message->sender =3D l_strdup(sender);
-	message->kdbus_sender =3D true;
 }
 =

 void _dbus_message_set_destination(struct l_dbus_message *message,
@@ -1648,112 +1629,6 @@ void _dbus_message_set_destination(struct l_dbus_me=
ssage *message,
 	l_free(message->destination);
 =

 	message->destination =3D l_strdup(destination);
-	message->kdbus_destination =3D true;
-}
-
-bool _dbus_kernel_calculate_bloom(struct l_dbus_message *message,
-					uint64_t filter[], size_t f_size,
-					uint8_t num_hash)
-{
-	const char *attr;
-	const char *signature;
-	void *body;
-	size_t body_size;
-	struct l_dbus_message_iter iter;
-	uint8_t argn;
-	char buf[256];
-	bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
-
-	/* The string "interface:" suffixed by the interface name */
-	attr =3D l_dbus_message_get_interface(message);
-	if (attr)
-		_dbus_kernel_bloom_add(filter, f_size, num_hash,
-					"interface", attr);
-
-	/* The string "member:" suffixed by the member name */
-	attr =3D l_dbus_message_get_member(message);
-	if (attr)
-		_dbus_kernel_bloom_add(filter, f_size, num_hash,
-					"member", attr);
-
-	/*
-	 * The string "path:" suffixed by the path name
-	 *
-	 * The string "path-slash-prefix:" suffixed with the path name, and
-	 * also all prefixes of the path name (cut off at "/"), also prefixed
-	 * with "path-slash-prefix"
-	 */
-	attr =3D l_dbus_message_get_path(message);
-	if (attr) {
-		_dbus_kernel_bloom_add(filter, f_size, num_hash, "path", attr);
-		_dbus_kernel_bloom_add(filter, f_size, num_hash,
-					"path-slash-prefix", attr);
-		_dbus_kernel_bloom_add_parents(filter, f_size, num_hash,
-						"path-slash-prefix", attr, '/');
-	}
-
-	/*
-	 * The string "message-type:" suffixed with the strings "signal",
-	 * "method_call", "error" or "method_return" for the respective
-	 * message type of the message.
-	 */
-	_dbus_kernel_bloom_add(filter, f_size, num_hash, "message-type",
-				_dbus_message_get_type_as_string(message));
-
-	signature =3D l_dbus_message_get_signature(message);
-	if (!signature)
-		return true;
-
-	body =3D _dbus_message_get_body(message, &body_size);
-
-	if (_dbus_message_is_gvariant(message)) {
-		if (!_gvariant_iter_init(&iter, message, signature, NULL,
-						body, body_size))
-			return false;
-
-		get_basic =3D _gvariant_iter_next_entry_basic;
-	} else {
-		_dbus1_iter_init(&iter, message, signature, NULL,
-					body, body_size);
-
-		get_basic =3D _dbus1_iter_next_entry_basic;
-	}
-
-	argn =3D 0;
-
-	/*
-	 * systemd-master/src/libsystemd/sd-bus/PORTING-DBUS1:
-	 *
-	 * "If the first argument of the message is a string,
-	 * "arg0-slash-prefix" suffixed with the first argument, and also
-	 * all prefixes of the argument (cut off at "/"), also prefixed
-	 * with "arg0-slash-prefix".
-	 *
-	 * Similar for all further arguments that are strings up to 63,
-	 * for the arguments and their "dot" and "slash" prefixes. On the
-	 * first argument that is not a string, addition to the bloom
-	 * filter should be stopped however."
-	 */
-	while (*signature =3D=3D 's' || *signature =3D=3D 'o' || *signature =3D=
=3D 'g') {
-		if (!get_basic(&iter, *signature, &attr))
-			return false;
-
-		sprintf(buf, "arg%hhu", argn);
-		_dbus_kernel_bloom_add(filter, f_size, num_hash, buf, attr);
-
-		sprintf(buf, "arg%hhu-slash-prefix", argn);
-		_dbus_kernel_bloom_add_parents(filter, f_size, num_hash, buf,
-						attr, '/');
-
-		sprintf(buf, "arg%hhu-dot-prefix", argn);
-		_dbus_kernel_bloom_add_parents(filter, f_size, num_hash, buf,
-						attr, '.');
-
-		argn +=3D 1;
-		signature +=3D 1;
-	}
-
-	return true;
 }
 =

 LIB_EXPORT struct l_dbus_message_builder *l_dbus_message_builder_new(
diff --git a/ell/dbus-private.h b/ell/dbus-private.h
index a4118c6..441e668 100644
--- a/ell/dbus-private.h
+++ b/ell/dbus-private.h
@@ -56,11 +56,6 @@ struct dbus_header {
 			uint32_t serial;
 			uint32_t field_length;
 		} __attribute__ ((packed)) dbus1;
-
-		struct {
-			uint32_t reserved1;
-			uint64_t cookie;
-		} __attribute__ ((packed)) kdbus;
 	};
 } __attribute__ ((packed));
 #define DBUS_HEADER_SIZE 16
@@ -234,46 +229,11 @@ bool _dbus_object_tree_property_changed(struct l_dbus=
 *dbus,
 					const char *interface_name,
 					const char *property_name);
 =

-void _dbus_kernel_bloom_add(uint64_t filter[], size_t size, uint8_t num_ha=
sh,
-				const char *prefix, const char *str);
-void _dbus_kernel_bloom_add_parents(uint64_t filter[], size_t size,
-					uint8_t num_hash, const char *prefix,
-					const char *str, const char sep);
-
-int _dbus_kernel_create_bus(const char *name);
-
-bool _dbus_kernel_calculate_bloom(struct l_dbus_message *message,
-					uint64_t filter[], size_t f_size,
-					uint8_t num_hash);
-
-int _dbus_kernel_hello(int fd, const char *connection_name,
-			size_t *bloom_size, uint8_t *bloom_n_hash,
-			uint64_t *id, void **pool, char **guid);
-void _dbus_kernel_unmap_pool(void *pool);
-
 typedef void (*_dbus_name_owner_change_func_t)(const char *name,
 						uint64_t old_owner,
 						uint64_t new_owner,
 						void *user_data);
 =

-int _dbus_kernel_send(int fd, size_t bloom_size, uint8_t n_bloom_hash,
-			struct l_dbus_message *message);
-int _dbus_kernel_recv(int fd, void *kdbus_pool,
-			l_dbus_message_func_t message_func,
-			_dbus_name_owner_change_func_t name_owner_change_func,
-			void *user_data);
-
-int _dbus_kernel_name_acquire(int fd, const char *name, bool allow_replace=
ment,
-				bool replace_existing, bool queue,
-				bool *queued);
-int _dbus_kernel_add_match(int fd, uint64_t bloom_size, uint64_t bloom_n_h=
ash,
-				const struct _dbus_filter_condition *rule,
-				int rule_len, unsigned int id);
-int _dbus_kernel_remove_match(int fd, unsigned int it);
-int _dbus_kernel_enable_name_owner_notify(int fd);
-uint64_t _dbus_kernel_get_name_owner(int fd, void *kdbus_pool,
-					const char *name);
-
 uint8_t _dbus_get_version(struct l_dbus *dbus);
 int _dbus_get_fd(struct l_dbus *dbus);
 struct _dbus_object_tree *_dbus_get_tree(struct l_dbus *dbus);
diff --git a/ell/dbus.c b/ell/dbus.c
index ddc51aa..db69c0d 100644
--- a/ell/dbus.c
+++ b/ell/dbus.c
@@ -101,14 +101,6 @@ struct l_dbus {
 	const struct l_dbus_ops *driver;
 };
 =

-struct l_dbus_kdbus {
-	struct l_dbus super;
-	uint8_t bloom_n_hash;		/* Number of hash indexes to use */
-	size_t bloom_size;		/* Size of the filter in bytes */
-	uint64_t kdbus_id;		/* Unique id */
-	void *kdbus_pool;		/* KDBus Memory pool */
-};
-
 struct l_dbus_classic {
 	struct l_dbus super;
 	void *auth_command;
@@ -1154,257 +1146,6 @@ static struct l_dbus *setup_unix(char *params)
 	return setup_dbus1(fd, guid);
 }
 =

-static void kdbus_ready(void *user_data)
-{
-	struct l_dbus *dbus =3D user_data;
-
-	bus_ready(dbus);
-}
-
-static void kdbus_free(struct l_dbus *dbus)
-{
-	struct l_dbus_kdbus *kdbus =3D
-		container_of(dbus, struct l_dbus_kdbus, super);
-
-	if (kdbus->kdbus_pool)
-		_dbus_kernel_unmap_pool(kdbus->kdbus_pool);
-
-	l_free(kdbus);
-}
-
-static bool kdbus_send_message(struct l_dbus *dbus,
-					struct l_dbus_message *message)
-{
-	struct l_dbus_kdbus *kdbus =3D
-			container_of(dbus, struct l_dbus_kdbus, super);
-	int fd =3D l_io_get_fd(dbus->io);
-	int r;
-
-	r =3D _dbus_kernel_send(fd, kdbus->bloom_size,
-				kdbus->bloom_n_hash, message);
-	if (r < 0) {
-		l_util_debug(dbus->debug_handler,
-				dbus->debug_data, strerror(-r));
-		return false;
-	}
-
-	return true;
-}
-
-struct kdbus_message_recv_data {
-	struct l_dbus_message *message;
-	struct l_dbus *dbus;
-};
-
-static void kdbus_message_func(struct l_dbus_message *message, void *user_=
data)
-{
-	struct kdbus_message_recv_data *recv_data =3D user_data;
-
-	recv_data->message =3D message;
-
-	l_util_debug(recv_data->dbus->debug_handler,
-			recv_data->dbus->debug_data, "Read KDBUS Message");
-}
-
-static void kdbus_name_owner_change_func(const char *name, uint64_t old_ow=
ner,
-						uint64_t new_owner,
-						void *user_data)
-{
-	struct kdbus_message_recv_data *recv_data =3D user_data;
-	char owner[32];
-
-	l_util_debug(recv_data->dbus->debug_handler,
-			recv_data->dbus->debug_data,
-			"Read KDBUS Name Owner Change notification");
-
-	if (new_owner)
-		snprintf(owner, sizeof(owner), ":1.%" PRIu64, new_owner);
-	else
-		owner[0] =3D '\0';
-
-	_dbus_name_cache_notify(recv_data->dbus->name_cache, name, owner);
-}
-
-static struct l_dbus_message *kdbus_recv_message(struct l_dbus *dbus)
-{
-	struct l_dbus_kdbus *kdbus =3D
-			container_of(dbus, struct l_dbus_kdbus, super);
-	int fd =3D l_io_get_fd(dbus->io);
-	struct kdbus_message_recv_data recv_data =3D { NULL, dbus };
-	int r;
-
-	r =3D _dbus_kernel_recv(fd, kdbus->kdbus_pool, kdbus_message_func,
-				kdbus_name_owner_change_func, &recv_data);
-	if (r < 0) {
-		l_util_debug(dbus->debug_handler,
-				dbus->debug_data, strerror(-r));
-		return NULL;
-	}
-
-	return recv_data.message;
-}
-
-static bool kdbus_add_match(struct l_dbus *dbus, unsigned int id,
-				const struct _dbus_filter_condition *rule,
-				int rule_len)
-{
-	struct l_dbus_kdbus *kdbus =3D
-		container_of(dbus, struct l_dbus_kdbus, super);
-	int fd =3D l_io_get_fd(dbus->io);
-	int r;
-
-	r =3D _dbus_kernel_add_match(fd, kdbus->bloom_size, kdbus->bloom_n_hash,
-					rule, rule_len, id);
-	if (r < 0)
-		l_util_debug(dbus->debug_handler,
-				dbus->debug_data, strerror(-r));
-
-	return !r;
-}
-
-static bool kdbus_remove_match(struct l_dbus *dbus, unsigned int id)
-{
-	int fd =3D l_io_get_fd(dbus->io);
-	int r;
-
-	r =3D _dbus_kernel_remove_match(fd, id);
-	if (r < 0)
-		l_util_debug(dbus->debug_handler,
-				dbus->debug_data, strerror(-r));
-
-	return !r;
-}
-
-static bool kdbus_get_name_owner(struct l_dbus *dbus, const char *name)
-{
-	struct l_dbus_kdbus *kdbus =3D
-		container_of(dbus, struct l_dbus_kdbus, super);
-	int fd =3D l_io_get_fd(dbus->io);
-	uint64_t owner_id;
-	char owner[32];
-	int r;
-
-	owner_id =3D _dbus_kernel_get_name_owner(fd, kdbus->kdbus_pool, name);
-
-	if (owner_id)
-		snprintf(owner, sizeof(owner), ":1.%" PRIu64, owner_id);
-	else
-		owner[0] =3D '\0';
-
-	_dbus_name_cache_notify(dbus->name_cache, name, owner);
-
-	if (!dbus->name_notify_enabled) {
-		r =3D _dbus_kernel_enable_name_owner_notify(fd);
-		if (r < 0)
-			l_util_debug(dbus->debug_handler,
-					dbus->debug_data, strerror(-r));
-
-		dbus->name_notify_enabled =3D true;
-	}
-
-	return true;
-}
-
-static uint32_t kdbus_name_acquire(struct l_dbus *dbus, const char *name,
-					bool allow_replacement,
-					bool replace_existing, bool queue,
-					l_dbus_name_acquire_func_t callback,
-					void *user_data)
-{
-	int fd =3D l_io_get_fd(dbus->io);
-	bool queued =3D false;
-	bool result;
-	int r;
-
-	r =3D _dbus_kernel_name_acquire(fd, name, allow_replacement,
-					replace_existing, queue, &queued);
-
-	result =3D r >=3D 0 || r =3D=3D -EALREADY;
-
-	if (!result)
-		l_util_debug(dbus->debug_handler,
-				dbus->debug_data, strerror(-r));
-
-	if (callback)
-		callback(dbus, result, queued, user_data);
-
-	return 0;
-}
-
-static const struct l_dbus_ops kdbus_ops =3D {
-	.version  =3D 2,
-	.free =3D kdbus_free,
-	.send_message =3D kdbus_send_message,
-	.recv_message =3D kdbus_recv_message,
-	.name_ops =3D {
-		.get_name_owner =3D kdbus_get_name_owner,
-	},
-	.filter_ops =3D {
-		.add_match =3D kdbus_add_match,
-		.remove_match =3D kdbus_remove_match,
-	},
-	.name_acquire =3D kdbus_name_acquire,
-};
-
-static struct l_dbus *setup_kdbus(int fd)
-{
-	struct l_dbus *dbus;
-	struct l_dbus_kdbus *kdbus;
-
-	kdbus =3D l_new(struct l_dbus_kdbus, 1);
-	dbus =3D &kdbus->super;
-	dbus->driver =3D &kdbus_ops;
-
-	if (_dbus_kernel_hello(fd, "ell-connection",
-				&kdbus->bloom_size, &kdbus->bloom_n_hash,
-				&kdbus->kdbus_id, &kdbus->kdbus_pool,
-				&dbus->guid) < 0) {
-		l_free(dbus);
-		close(fd);
-		return NULL;
-	}
-
-	dbus_init(dbus, fd);
-
-	dbus->unique_name =3D l_strdup_printf(":1.%llu", kdbus->kdbus_id);
-
-	l_idle_oneshot(kdbus_ready, dbus, NULL);
-
-	return dbus;
-}
-
-static struct l_dbus *setup_kernel(char *params)
-{
-	char *path =3D NULL;
-	int fd;
-
-	while (params) {
-		char *key =3D strsep(&params, ",");
-		char *value;
-
-		if (!key)
-			break;
-
-		value =3D strchr(key, '=3D');
-		if (!value)
-			continue;
-
-		*value++ =3D '\0';
-
-		if (!strcmp(key, "path"))
-			path =3D value;
-	}
-
-	if (!path)
-		return NULL;
-
-	fd =3D open(path, O_RDWR | O_CLOEXEC);
-	if (fd < 0)
-		return NULL;
-
-	return setup_kdbus(fd);
-}
-
 static struct l_dbus *setup_address(const char *address)
 {
 	struct l_dbus *dbus =3D NULL;
@@ -1423,11 +1164,7 @@ static struct l_dbus *setup_address(const char *addr=
ess)
 		if (params)
 			*params++ =3D '\0';
 =

-		if (!strcmp(transport, "kernel")) {
-			/* Function will modify params string */
-			dbus =3D setup_kernel(params);
-			break;
-		} else if (!strcmp(transport, "unix")) {
+		if (!strcmp(transport, "unix")) {
 			/* Function will modify params string */
 			dbus =3D setup_unix(params);
 			break;
-- =

2.9.3


--===============0693534791277834975==--

