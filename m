Content-Type: multipart/mixed; boundary="===============6637787622642731333=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/4] unit: End to end FD passing test
Date: Wed, 04 May 2016 11:09:01 -0500
Message-ID: <572A1E9D.1080204@gmail.com>
In-Reply-To: <1462359793-18789-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6637787622642731333==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 05/04/2016 06:03 AM, Andrew Zaborowski wrote:
> ---
>   Makefile.am                  |   3 +
>   unit/test-dbus-message-fds.c | 368 ++++++++++++++++++++++++++++++++++++=
+++++++
>   2 files changed, 371 insertions(+)
>   create mode 100644 unit/test-dbus-message-fds.c
>
> diff --git a/Makefile.am b/Makefile.am
> index 3e8e3ef..aa99bdd 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -140,6 +140,7 @@ dbus_tests =3D unit/test-kdbus \
>   			unit/test-dbus \
>   			unit/test-dbus-util \
>   			unit/test-dbus-message \
> +			unit/test-dbus-message-fds \
>   			unit/test-dbus-service \
>   			unit/test-dbus-watch \
>   			unit/test-dbus-properties \
> @@ -186,6 +187,8 @@ unit_test_dbus_LDADD =3D ell/libell-private.la
>
>   unit_test_dbus_message_LDADD =3D ell/libell-private.la
>
> +unit_test_dbus_message_fds_LDADD =3D ell/libell-private.la
> +
>   unit_test_dbus_util_LDADD =3D ell/libell-private.la
>
>   unit_test_dbus_service_LDADD =3D ell/libell-private.la
> diff --git a/unit/test-dbus-message-fds.c b/unit/test-dbus-message-fds.c
> new file mode 100644
> index 0000000..033d0a9
> --- /dev/null
> +++ b/unit/test-dbus-message-fds.c
> @@ -0,0 +1,368 @@
> +/*
> + *
> + *  Embedded Linux library
> + *
> + *  Copyright (C) 2011-2014  Intel Corporation. All rights reserved.

Please remember to update the copyright when copy-pasting stuff.

> + *
> + *  This library is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU Lesser General Public
> + *  License as published by the Free Software Foundation; either
> + *  version 2.1 of the License, or (at your option) any later version.
> + *
> + *  This library is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
> + *  Lesser General Public License for more details.
> + *
> + *  You should have received a copy of the GNU Lesser General Public
> + *  License along with this library; if not, write to the Free Software
> + *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-130=
1  USA
> + *
> + */
> +
> +#ifdef HAVE_CONFIG_H
> +#include <config.h>
> +#endif
> +
> +#include <unistd.h>
> +#include <stdlib.h>
> +#include <sys/wait.h>
> +#include <stdio.h>
> +#include <sys/stat.h>
> +#include <fcntl.h>
> +#include <errno.h>
> +
> +#include <ell/ell.h>
> +#include <ell/dbus-private.h>
> +
> +#define TEST_BUS_ADDRESS "unix:path=3D/tmp/ell-test-bus"
> +
> +static pid_t dbus_daemon_pid =3D -1;
> +
> +static int kdbus_fd =3D -1;
> +
> +static char bus_address[128];
> +
> +static void start_dbus_daemon(void)
> +{
> +	char *prg_argv[6];
> +	char *prg_envp[1];
> +	pid_t pid;
> +
> +	prg_argv[0] =3D "/usr/bin/dbus-daemon";
> +	prg_argv[1] =3D "--session";
> +	prg_argv[2] =3D "--address=3D" TEST_BUS_ADDRESS;
> +	prg_argv[3] =3D "--nopidfile";
> +	prg_argv[4] =3D "--nofork";
> +	prg_argv[5] =3D NULL;
> +
> +	prg_envp[0] =3D NULL;
> +
> +	l_info("launching dbus-daemon");
> +
> +	pid =3D fork();
> +	if (pid < 0) {
> +		l_error("failed to fork new process");
> +		return;
> +	}
> +
> +	if (pid =3D=3D 0) {
> +		execve(prg_argv[0], prg_argv, prg_envp);
> +		exit(EXIT_SUCCESS);
> +	}
> +
> +	l_info("dbus-daemon process %d created", pid);
> +
> +	dbus_daemon_pid =3D pid;
> +
> +	strcpy(bus_address, TEST_BUS_ADDRESS);
> +}
> +
> +static void create_kdbus(void)
> +{
> +	char bus_name[64];
> +
> +	snprintf(bus_name, sizeof(bus_name), "%u-ell-test", getuid());
> +
> +	kdbus_fd =3D _dbus_kernel_create_bus(bus_name);
> +	if (kdbus_fd < 0) {
> +		l_warn("kdbus not available");
> +		return;
> +	}
> +
> +	snprintf(bus_address, sizeof(bus_address),
> +				"kernel:path=3D/dev/kdbus/%s/bus", bus_name);
> +}
> +
> +static void signal_handler(struct l_signal *signal, uint32_t signo,
> +							void *user_data)
> +{
> +	switch (signo) {
> +	case SIGINT:
> +	case SIGTERM:
> +		l_info("Terminate");
> +		l_main_quit();
> +		break;
> +	case SIGCHLD:
> +		while (1) {
> +			pid_t pid;
> +			int status;
> +
> +			pid =3D waitpid(WAIT_ANY, &status, WNOHANG);
> +			if (pid < 0 || pid =3D=3D 0)
> +				break;
> +
> +			l_info("process %d terminated with status=3D%d\n",
> +								pid, status);
> +
> +			if (pid =3D=3D dbus_daemon_pid) {
> +				dbus_daemon_pid =3D -1;
> +				l_main_quit();
> +			}
> +		}
> +		break;
> +	}
> +}
> +
> +static struct l_dbus *dbus;
> +
> +struct dbus_test {
> +	const char *name;
> +	void (*start)(struct l_dbus *dbus, void *);
> +	void *data;
> +};
> +
> +static bool success;
> +static struct l_queue *tests;
> +
> +static void test_add(const char *name,
> +			void (*start)(struct l_dbus *dbus, void *),
> +			void *test_data)
> +{
> +	struct dbus_test *test =3D l_new(struct dbus_test, 1);
> +
> +	test->name =3D name;
> +	test->start =3D start;
> +	test->data =3D test_data;
> +
> +	if (!tests)
> +		tests =3D l_queue_new();
> +
> +	l_queue_push_tail(tests, test);
> +}
> +
> +static void test_next()
> +{
> +	struct dbus_test *test =3D l_queue_pop_head(tests);
> +
> +	if (!test) {
> +		success =3D true;
> +		l_main_quit();
> +		return;
> +	}
> +
> +	l_info("TEST: %s", test->name);
> +
> +	test->start(dbus, test->data);
> +
> +	l_free(test);
> +}
> +
> +#define test_assert(cond)	\
> +	do {	\
> +		if (!(cond)) {	\
> +			l_info("TEST FAILED in %s at %s:%i: %s",	\
> +				__func__, __FILE__, __LINE__,	\
> +				L_STRINGIFY(cond));	\
> +			l_main_quit();	\
> +			return;	\
> +		}	\
> +	} while (0)
> +
> +static void request_name_callback(struct l_dbus *dbus, bool success,
> +					bool queued, void *user_data)
> +{
> +	l_info("request name result=3D%s",
> +		success ? (queued ? "queued" : "success") : "failed");
> +
> +	test_next();
> +}
> +
> +static void ready_callback(void *user_data)
> +{
> +	l_info("ready");
> +
> +	l_dbus_name_acquire(dbus, "org.test", false, false, false,
> +				request_name_callback, NULL);
> +}
> +
> +static void disconnect_callback(void *user_data)
> +{
> +	l_info("Disconnected from DBus");
> +	l_main_quit();
> +}
> +
> +static struct l_dbus_message *get_random_callback(struct l_dbus *dbus,
> +					struct l_dbus_message *message,
> +					void *user_data)
> +{
> +	struct l_dbus_message *reply;
> +	int fd;
> +
> +	reply =3D l_dbus_message_new_method_return(message);
> +
> +	fd =3D open("/dev/random", O_RDONLY);
> +	l_dbus_message_set_arguments(reply, "h", fd);
> +	close(fd);
> +
> +	return reply;
> +}
> +
> +static void setup_test_interface(struct l_dbus_interface *interface)
> +{
> +	l_dbus_interface_method(interface, "GetRandom", 0, get_random_callback,
> +				"h", "", "randomfd");
> +}
> +
> +static int count_fds(void)
> +{
> +	int fd;
> +	int count =3D 0;
> +
> +	for (fd =3D 0; fd < FD_SETSIZE; fd++)
> +		if (fcntl(fd, F_GETFL) !=3D -1 || errno !=3D EBADF)
> +			count++;
> +
> +	return count;
> +}
> +
> +static bool compare_failed;
> +
> +static void compare_files(int a, int b)
> +{
> +	struct stat sa, sb;
> +
> +	compare_failed =3D true;
> +
> +	test_assert(fstat(a, &sa) =3D=3D 0);
> +	test_assert(fstat(b, &sb) =3D=3D 0);
> +
> +	test_assert(sa.st_dev =3D=3D sb.st_dev);
> +	test_assert(sa.st_ino =3D=3D sb.st_ino);
> +	test_assert(sa.st_rdev =3D=3D sb.st_rdev);
> +
> +	compare_failed =3D false;
> +}
> +
> +static int open_fds;
> +
> +static void get_random_idle_callback(void *user_data)
> +{
> +	test_assert(count_fds() =3D=3D open_fds);
> +
> +	test_next();
> +}
> +
> +static void get_random_return_callback(struct l_dbus_message *message,
> +					void *user_data)
> +{
> +	int fd0, fd1;
> +
> +	test_assert(!l_dbus_message_get_error(message, NULL, NULL));
> +
> +	test_assert(l_dbus_message_get_arguments(message, "h", &fd1));
> +
> +	fd0 =3D open("/dev/random", O_RDONLY);
> +	test_assert(fd0 !=3D -1);
> +
> +	compare_files(fd0, fd1);
> +	if (compare_failed)
> +		return;
> +
> +	close(fd0);
> +	close(fd1);
> +
> +	test_assert(l_idle_oneshot(get_random_idle_callback, NULL, NULL));
> +}
> +
> +static void test_fd_passing_1(struct l_dbus *dbus, void *test_data)
> +{
> +	open_fds =3D count_fds();
> +
> +	l_dbus_method_call(dbus, "org.test", "/test", "org.test", "GetRandom",
> +				NULL, get_random_return_callback, NULL, NULL);
> +}
> +
> +int main(int argc, char *argv[])
> +{
> +	struct l_signal *signal;
> +	sigset_t mask;
> +	int i;
> +	bool kdbus =3D false;
> +
> +	for (i =3D 1; i < argc; i++) {
> +		if (!strcmp(argv[i], "--kdbus"))
> +			kdbus =3D true;

unit tests should not take arguments.  Can we simply always run the test =

with dbus-1 and kdbus?  If kdbus is not available, then the test can be =

skipped.  Similar to how test-kdbus does it.

> +	}
> +
> +	sigemptyset(&mask);
> +	sigaddset(&mask, SIGINT);
> +	sigaddset(&mask, SIGTERM);
> +	sigaddset(&mask, SIGCHLD);
> +
> +	signal =3D l_signal_create(&mask, signal_handler, NULL, NULL);
> +
> +	l_log_set_stderr();
> +
> +	if (kdbus)
> +		create_kdbus();
> +	else
> +		start_dbus_daemon();
> +
> +	if (!bus_address[0])
> +		return -1;
> +
> +	for (i =3D 0; i < 10; i++) {
> +		usleep(200 * 1000);
> +
> +		dbus =3D l_dbus_new(bus_address);
> +		if (dbus)
> +			break;
> +	}
> +
> +	l_dbus_set_ready_handler(dbus, ready_callback, dbus, NULL);
> +	l_dbus_set_disconnect_handler(dbus, disconnect_callback, NULL, NULL);
> +
> +	if (!l_dbus_register_interface(dbus, "org.test", setup_test_interface,
> +					NULL, true)) {
> +		l_info("Unable to register interface");
> +		goto done;
> +	}
> +
> +	if (!l_dbus_object_add_interface(dbus, "/test", "org.test", NULL)) {
> +		l_info("Unable to instantiate interface");
> +		goto done;
> +	}
> +
> +	test_add("FD passing 1", test_fd_passing_1, NULL);
> +
> +	l_main_run();
> +
> +	l_queue_destroy(tests, l_free);
> +
> +done:
> +	l_dbus_destroy(dbus);
> +
> +	if (dbus_daemon_pid > 0)
> +		kill(dbus_daemon_pid, SIGKILL);
> +
> +	if (kdbus_fd >=3D 0)
> +		close(kdbus_fd);
> +
> +	l_signal_remove(signal);
> +
> +	if (!success)
> +		abort();
> +
> +	return 0;
> +}
>

Regards,
-Denis

--===============6637787622642731333==--

