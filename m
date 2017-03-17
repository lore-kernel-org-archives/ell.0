Content-Type: multipart/mixed; boundary="===============2411107158911511157=="
MIME-Version: 1.0
From: Lukas Rusak <lrusak@libreelec.tv>
Subject: [PATCH 3/5] unit: remove kdbus
Date: Fri, 17 Mar 2017 13:10:29 -0700
Message-ID: <20170317201031.4927-3-lrusak@libreelec.tv>
In-Reply-To: <20170317201031.4927-1-lrusak@libreelec.tv>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2411107158911511157==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

From: Lukas Rusak <lorusak@gmail.com>

---
 unit/test-dbus-message-fds.c |  25 ------
 unit/test-dbus-message.c     |  30 -------
 unit/test-dbus-properties.c  |  25 ------
 unit/test-kdbus.c            | 200 ---------------------------------------=
----
 4 files changed, 280 deletions(-)
 delete mode 100644 unit/test-kdbus.c

diff --git a/unit/test-dbus-message-fds.c b/unit/test-dbus-message-fds.c
index c93f093..9039bb5 100644
--- a/unit/test-dbus-message-fds.c
+++ b/unit/test-dbus-message-fds.c
@@ -39,8 +39,6 @@
 =

 static pid_t dbus_daemon_pid =3D -1;
 =

-static int kdbus_fd =3D -1;
-
 static char bus_address[128];
 =

 static bool start_dbus_daemon(void)
@@ -80,24 +78,6 @@ static bool start_dbus_daemon(void)
 	return true;
 }
 =

-static bool create_kdbus(void)
-{
-	char bus_name[64];
-
-	snprintf(bus_name, sizeof(bus_name), "%u-ell-test", getuid());
-
-	kdbus_fd =3D _dbus_kernel_create_bus(bus_name);
-	if (kdbus_fd < 0) {
-		l_warn("kdbus not available");
-		return false;
-	}
-
-	snprintf(bus_address, sizeof(bus_address),
-				"kernel:path=3D/dev/kdbus/%s/bus", bus_name);
-
-	return true;
-}
-
 static void signal_handler(struct l_signal *signal, uint32_t signo,
 							void *user_data)
 {
@@ -364,17 +344,12 @@ int main(int argc, char *argv[])
 	if (!success)
 		goto done;
 =

-	if (!create_kdbus())
-		goto done;
-
 	dbus =3D l_dbus_new(bus_address);
 =

 	test_run();
 =

 	l_dbus_destroy(dbus);
 =

-	close(kdbus_fd);
-
 done:
 	l_signal_remove(signal);
 =

diff --git a/unit/test-dbus-message.c b/unit/test-dbus-message.c
index 0c14a7b..d1ff1ef 100644
--- a/unit/test-dbus-message.c
+++ b/unit/test-dbus-message.c
@@ -2505,34 +2505,6 @@ static void check_complex_5(const void *data)
 	l_dbus_message_unref(msg);
 }
 =

-static uint64_t bloom_1[] =3D {
-	0x8000001100001000, 0x0010304080000001, 0x0000800810000411,
-	0x0040002100000081, 0x0120004008030080, 0x8400020801000008,
-	0x0002000000008010, 0x0010000100000008,
-};
-
-static void check_bloom_1(const void *data)
-{
-	struct l_dbus_message *msg;
-	bool result;
-	uint64_t filter[8];
-	int i;
-
-	memset(filter, 0, sizeof(filter));
-
-	msg =3D _dbus_message_new_signal(2, "/test",
-					"org.test", "PropertyChanged");
-	result =3D l_dbus_message_set_arguments(msg, "");
-	assert(result);
-
-	_dbus_kernel_calculate_bloom(msg, filter, 64, 8);
-
-	for (i =3D 0; i < 8; i++)
-		assert(bloom_1[i] =3D=3D filter[i]);
-
-	l_dbus_message_unref(msg);
-}
-
 static void builder_rewind(const void *data)
 {
 	struct l_dbus_message *msg =3D build_message(data);
@@ -2789,8 +2761,6 @@ int main(int argc, char *argv[])
 	l_test_add("Complex 4", check_complex_4, &message_data_complex_4);
 	l_test_add("Complex 5", check_complex_5, &message_data_complex_5);
 =

-	l_test_add("Bloom 1", check_bloom_1, NULL);
-
 	l_test_add("Message Builder Complex 3", builder_complex_3,
 						&message_data_complex_3);
 =

diff --git a/unit/test-dbus-properties.c b/unit/test-dbus-properties.c
index a184deb..0ba05fd 100644
--- a/unit/test-dbus-properties.c
+++ b/unit/test-dbus-properties.c
@@ -36,8 +36,6 @@
 =

 static pid_t dbus_daemon_pid =3D -1;
 =

-static int kdbus_fd =3D -1;
-
 static char bus_address[128];
 =

 static bool start_dbus_daemon(void)
@@ -77,24 +75,6 @@ static bool start_dbus_daemon(void)
 	return true;
 }
 =

-static bool create_kdbus(void)
-{
-	char bus_name[64];
-
-	snprintf(bus_name, sizeof(bus_name), "%u-ell-test", getuid());
-
-	kdbus_fd =3D _dbus_kernel_create_bus(bus_name);
-	if (kdbus_fd < 0) {
-		l_warn("kdbus not available");
-		return false;
-	}
-
-	snprintf(bus_address, sizeof(bus_address),
-				"kernel:path=3D/dev/kdbus/%s/bus", bus_name);
-
-	return true;
-}
-
 static void signal_handler(struct l_signal *signal, uint32_t signo,
 							void *user_data)
 {
@@ -1030,17 +1010,12 @@ int main(int argc, char *argv[])
 	if (!success)
 		goto done;
 =

-	if (!create_kdbus())
-		goto done;
-
 	dbus =3D l_dbus_new(bus_address);
 =

 	test_run();
 =

 	l_dbus_destroy(dbus);
 =

-	close(kdbus_fd);
-
 done:
 	l_signal_remove(signal);
 =

diff --git a/unit/test-kdbus.c b/unit/test-kdbus.c
deleted file mode 100644
index ad4a754..0000000
--- a/unit/test-kdbus.c
+++ /dev/null
@@ -1,200 +0,0 @@
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
-#include <stdio.h>
-#include <unistd.h>
-#include <stdlib.h>
-#include <assert.h>
-
-#include <ell/ell.h>
-#include "ell/dbus-private.h"
-
-static void do_debug(const char *str, void *user_data)
-{
-	const char *prefix =3D user_data;
-
-	l_info("%s%s", prefix, str);
-}
-
-static void signal_handler(struct l_signal *signal, uint32_t signo,
-							void *user_data)
-{
-	switch (signo) {
-	case SIGINT:
-	case SIGTERM:
-		l_info("Terminate");
-		l_main_quit();
-		break;
-	}
-}
-
-static void signal_message(struct l_dbus_message *message, void *user_data)
-{
-	const char *path, *interface, *member, *destination, *sender;
-
-	path =3D l_dbus_message_get_path(message);
-	destination =3D l_dbus_message_get_destination(message);
-
-	l_info("path=3D%s destination=3D%s", path, destination);
-
-	interface =3D l_dbus_message_get_interface(message);
-	member =3D l_dbus_message_get_member(message);
-
-	l_info("interface=3D%s member=3D%s", interface, member);
-
-	sender =3D l_dbus_message_get_sender(message);
-
-	l_info("sender=3D%s", sender);
-}
-
-static struct l_dbus_message *test_method_call(struct l_dbus *dbus,
-						struct l_dbus_message *message,
-						void *user_data)
-{
-	struct l_dbus_message *reply;
-
-	l_info("Method Call");
-
-	reply =3D l_dbus_message_new_method_return(message);
-	l_dbus_message_set_arguments(reply, "");
-
-	return reply;
-}
-
-static void client_ready_callback(void *user_data)
-{
-	struct l_dbus *dbus =3D user_data;
-
-	l_info("client ready");
-
-	l_dbus_method_call(dbus, "org.test",
-				"/test",
-				"org.test", "TestMethod",
-				NULL,
-				NULL, NULL, NULL);
-}
-
-static void service_name_acquire_callback(struct l_dbus *dbus, bool succes=
s,
-						bool queued, void *user_data)
-{
-	if (!success)
-		l_info("Failed to acquire name");
-}
-
-static void service_ready_callback(void *user_data)
-{
-	struct l_dbus *dbus =3D user_data;
-	struct l_dbus_message *message;
-
-	l_dbus_name_acquire(dbus, "org.test", false, false, false,
-				service_name_acquire_callback, NULL);
-
-	l_info("service ready");
-
-	message =3D l_dbus_message_new_signal(dbus, "/test",
-					"org.test", "TestSignal");
-	l_dbus_message_set_arguments(message, "");
-	l_dbus_send(dbus, message);
-}
-
-static void setup_test_interface(struct l_dbus_interface *interface)
-{
-	l_dbus_interface_method(interface, "TestMethod", 0,
-				test_method_call, "", "");
-}
-
-int main(int argc, char *argv[])
-{
-	struct l_dbus *service;
-	struct l_dbus *client;
-	char bus_name[16];
-	char bus_address[64];
-	int bus_fd;
-	struct l_signal *signal;
-	sigset_t mask;
-
-	if (!l_main_init())
-		return -1;
-
-	sigemptyset(&mask);
-	sigaddset(&mask, SIGINT);
-	sigaddset(&mask, SIGTERM);
-
-	signal =3D l_signal_create(&mask, signal_handler, NULL, NULL);
-
-	l_log_set_stderr();
-
-	snprintf(bus_name, sizeof(bus_name), "%u-ell-test", getuid());
-
-	bus_fd =3D _dbus_kernel_create_bus(bus_name);
-	if (bus_fd < 0) {
-		l_warn("kdbus not available");
-		return EXIT_SUCCESS;
-	}
-
-	snprintf(bus_address, sizeof(bus_address),
-				"kernel:path=3D/dev/kdbus/%s/bus", bus_name);
-
-	service =3D l_dbus_new(bus_address);
-	assert(service);
-
-	l_dbus_set_debug(service, do_debug, "[SERVICE] ", NULL);
-	l_dbus_set_ready_handler(service, service_ready_callback,
-					service, NULL);
-
-	if (!l_dbus_register_interface(service, "org.test",
-					setup_test_interface, NULL, false)) {
-		l_info("Unable to register interface");
-		goto error;
-	}
-
-	if (!l_dbus_object_add_interface(service, "/test", "org.test", NULL)) {
-		l_info("Unable to instantiate interface");
-		goto error;
-	}
-
-	client =3D l_dbus_new(bus_address);
-	assert(client);
-
-	l_dbus_set_debug(client, do_debug, "[CLIENT] ", NULL);
-	l_dbus_set_ready_handler(client, client_ready_callback, client, NULL);
-	l_dbus_add_signal_watch(client, "org.test", NULL, NULL, NULL,
-				L_DBUS_MATCH_NONE, signal_message, NULL);
-
-	l_main_run();
-
-	l_dbus_destroy(client);
-error:
-	l_dbus_destroy(service);
-
-	close(bus_fd);
-
-	l_signal_remove(signal);
-
-	l_main_exit();
-
-	return EXIT_SUCCESS;
-}
-- =

2.9.3


--===============2411107158911511157==--

