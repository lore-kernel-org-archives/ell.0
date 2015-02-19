Content-Type: multipart/mixed; boundary="===============1344337706125352012=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 4/4] unit: dbus: Add test for disconnect watch API
Date: Thu, 19 Feb 2015 10:07:17 -0600
Message-ID: <54E60A35.7070002@gmail.com>
In-Reply-To: <1424275716-7198-5-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1344337706125352012==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/18/2015 10:08 AM, Jukka Rissanen wrote:
> Test the dbus disconnect watch support.
> ---
>   Makefile.am            |   3 +
>   unit/test-dbus-watch.c | 153 ++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   2 files changed, 156 insertions(+)
>   create mode 100644 unit/test-dbus-watch.c
>

Okay, now we're getting much closer to what I had in mind.

> diff --git a/Makefile.am b/Makefile.am
> index 50f81eb..eff88f7 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -102,6 +102,7 @@ unit_tests =3D unit/test-unit \
>   			unit/test-dbus-util \
>   			unit/test-dbus-message \
>   			unit/test-dbus-service \
> +			unit/test-dbus-watch \
>   			unit/test-gvariant-util \
>   			unit/test-gvariant-message \
>   			unit/test-siphash \
> @@ -147,6 +148,8 @@ unit_test_dbus_util_LDADD =3D ell/libell-private.la
>
>   unit_test_dbus_service_LDADD =3D ell/libell-private.la
>
> +unit_test_dbus_watch_LDADD =3D ell/libell-private.la
> +
>   unit_test_gvariant_util_LDADD =3D ell/libell-private.la
>
>   unit_test_gvariant_message_LDADD =3D ell/libell-private.la
> diff --git a/unit/test-dbus-watch.c b/unit/test-dbus-watch.c
> new file mode 100644
> index 0000000..5e7cf60
> --- /dev/null
> +++ b/unit/test-dbus-watch.c
> @@ -0,0 +1,153 @@
> +/*
> + *
> + *  Embedded Linux library
> + *
> + *  Copyright (C) 2011-2015  Intel Corporation. All rights reserved.
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
> +#include <assert.h>
> +#include <time.h>
> +#include <stdio.h>
> +
> +#include <ell/ell.h>
> +#include "ell/dbus-private.h"
> +
> +#define DBUS_SERVICE_DBUS	"org.freedesktop.DBus"
> +#define DBUS_PATH_DBUS		"/org/freedesktop/DBus"
> +#define DBUS_INTERFACE_DBUS	"org.freedesktop.DBus"
> +#define DBUS_MAXIMUM_MATCH_RULE_LENGTH	1024
> +
> +struct watch_test {
> +	const char *name;
> +	const char *expected;
> +	int count;
> +};

Split this up into two structures and test things separately.

One structure and test to handle the actual AddMatch/RemoveMatch =

strings.  These should be in a separate patch like I already mentioned.

The other tests to cover the actual dispatcher.

> +
> +static struct watch_test match_test =3D {
> +	.name =3D ":1.101",
> +	.expected =3D "type=3D'signal',"
> +		"sender=3D'org.freedesktop.DBus',"
> +		"path=3D'/org/freedesktop/DBus',"
> +		"interface=3D'org.freedesktop.DBus',"
> +		"member=3D'NameOwnerChanged',"
> +		"arg0=3D':1.101'",
> +};
> +
> +static struct watch_test disconnect_test =3D {
> +	.name =3D ":101.1",
> +	.count =3D 0,
> +};
> +
> +static void verify_match(struct _dbus_filter_data *data,
> +						l_dbus_message_func_t filter)
> +{
> +	struct watch_test *test =3D data->user_data;
> +	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
> +
> +	_dbus1_format_rule(data, rule, sizeof(rule));
> +
> +	assert(strcmp(rule, test->expected) =3D=3D 0);
> +}
> +
> +static void test_match(const void *test_data)
> +{
> +	struct watch_test *test =3D (struct watch_test *)test_data;
> +	struct _dbus_filter_data *data;
> +
> +	data =3D _dbus1_filter_data_get(NULL, _dbus1_service_filter,
> +				DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
> +				DBUS_INTERFACE_DBUS, "NameOwnerChanged",
> +				test->name,
> +				NULL,
> +				test,
> +				NULL,
> +				verify_match);
> +
> +	_dbus1_filter_data_destroy(data, verify_match);

Just call _dbus1_format_rule directly here.

> +}
> +
> +static void match(struct _dbus_filter_data *data, l_dbus_message_func_t =
filter)
> +{
> +	data->handle_func =3D filter;
> +}
> +
> +static void disconnect_cb(struct l_dbus *dbus, void *user_data)
> +{
> +	struct watch_test *data =3D user_data;
> +
> +	data->count++;

count is not part of the test data, so just pass in a pointer to some =

arbitrary integer here.

> +}
> +
> +static void send_filter_signal(struct _dbus_filter_data *data,
> +			const char *name, const char *old, const char *new)
> +{
> +	struct l_dbus_message *message;
> +
> +	message =3D _dbus_message_new_signal(2, DBUS_PATH_DBUS,
> +					DBUS_INTERFACE_DBUS,
> +					"NameOwnerChanged");
> +	l_dbus_message_set_arguments(message, "sss", name, old, new);
> +	_dbus_message_set_sender(message, DBUS_SERVICE_DBUS);
> +	_dbus_message_filter_dispatcher(message, data);
> +	l_dbus_message_unref(message);
> +}
> +
> +static void test_disconnect_watch(const void *test_data)
> +{
> +	struct watch_test *test =3D (struct watch_test *)test_data;
> +	struct _dbus_filter_data *data;
> +
> +	data =3D _dbus1_filter_data_get(NULL, _dbus1_service_filter,
> +				DBUS_SERVICE_DBUS, DBUS_PATH_DBUS,
> +				DBUS_INTERFACE_DBUS, "NameOwnerChanged",
> +				test->name,
> +				disconnect_cb,
> +				test,
> +				NULL,
> +				match);
> +
> +	send_filter_signal(data, ":0.1", ":0.1", "");
> +	assert(test->count =3D=3D 0);
> +
> +	send_filter_signal(data, ":0.1", ":0.1", ":0.2");
> +	assert(test->count =3D=3D 0);
> +
> +	send_filter_signal(data, ":101.1", ":101.1", "");
> +	assert(test->count =3D=3D 1);
> +
> +	_dbus1_filter_data_destroy(data, match);
> +}
> +
> +int main(int argc, char *argv[])
> +{
> +	l_test_init(&argc, &argv);
> +
> +	l_test_add("DBus filter", test_match, &match_test);
> +
> +	l_test_add("DBus disconnect watch", test_disconnect_watch,
> +			&disconnect_test);
> +
> +	return l_test_run();
> +}
>

Regards,
-Denis

--===============1344337706125352012==--

