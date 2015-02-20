Content-Type: multipart/mixed; boundary="===============5467170392205577082=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v4 4/6] unit: dbus: Add test for filter rule
Date: Fri, 20 Feb 2015 11:27:57 -0600
Message-ID: <54E76E9D.8070009@gmail.com>
In-Reply-To: <1424434601-2211-5-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5467170392205577082==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/20/2015 06:16 AM, Jukka Rissanen wrote:
> Testing the _dbus1_format_rule() function.
> ---
>   Makefile.am            |   3 ++
>   unit/test-dbus-watch.c | 109 ++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   2 files changed, 112 insertions(+)
>   create mode 100644 unit/test-dbus-watch.c
>
> diff --git a/Makefile.am b/Makefile.am
> index 36a680b..cea1b7a 100644
> --- a/Makefile.am
> +++ b/Makefile.am
> @@ -107,6 +107,7 @@ unit_tests =3D unit/test-unit \
>   			unit/test-dbus-util \
>   			unit/test-dbus-message \
>   			unit/test-dbus-service \
> +			unit/test-dbus-watch \
>   			unit/test-gvariant-util \
>   			unit/test-gvariant-message \
>   			unit/test-siphash \
> @@ -154,6 +155,8 @@ unit_test_dbus_util_LDADD =3D ell/libell-private.la
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
> index 0000000..e1d3f9d
> --- /dev/null
> +++ b/unit/test-dbus-watch.c
> @@ -0,0 +1,109 @@
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
> +struct dbus_filter_data {
> +	struct l_dbus *dbus;
> +	l_dbus_message_func_t handle_func;
> +	l_dbus_watch_func_t disconnect_func;
> +	char *sender;
> +	char *path;
> +	char *interface;
> +	char *member;
> +	char *argument;
> +	void *user_data;
> +	l_dbus_destroy_func_t destroy_func;
> +};

Don't ever do this.  If you need to use an opaque data structure, ask =

yourself why.  If it is genuinely required, then expose that in the =

header file.  Do not re-define opaque data structures in a unit test.

> +
> +struct watch_test {
> +	const char *name;
> +	const char *expected;
> +};
> +
> +static const struct watch_test match_test =3D {
> +	.name =3D ":1.101",
> +	.expected =3D "type=3D'signal',"
> +		"sender=3D'org.freedesktop.DBus',"
> +		"path=3D'/org/freedesktop/DBus',"
> +		"interface=3D'org.freedesktop.DBus',"
> +		"member=3D'NameOwnerChanged',"
> +		"arg0=3D':1.101'",
> +};
> +
> +static void setup_data(struct dbus_filter_data *data, const char *name)
> +{
> +	data->sender =3D l_strdup(DBUS_SERVICE_DBUS);
> +	data->path =3D l_strdup(DBUS_PATH_DBUS);
> +	data->interface =3D l_strdup(DBUS_INTERFACE_DBUS);
> +	data->member =3D l_strdup("NameOwnerChanged");
> +	data->argument =3D l_strdup(name);
> +}
> +
> +static void clean_data(struct dbus_filter_data *data)
> +{
> +	l_free(data->sender);
> +	l_free(data->path);
> +	l_free(data->interface);
> +	l_free(data->member);
> +	l_free(data->argument);
> +}
> +static void test_match(const void *test_data)
> +{
> +	const struct watch_test *test =3D test_data;
> +	struct dbus_filter_data data;
> +	char rule[DBUS_MAXIMUM_MATCH_RULE_LENGTH];
> +
> +	setup_data(&data, test->name);

Use _dbus1_filter_data_get

> +
> +	_dbus1_format_rule(&data, rule, sizeof(rule));
> +
> +	assert(strcmp(rule, test->expected) =3D=3D 0);
> +
> +	clean_data(&data);

Use _dbus1_filter_data_destroy

> +}
> +
> +int main(int argc, char *argv[])
> +{
> +	l_test_init(&argc, &argv);
> +
> +	l_test_add("DBus filter", test_match, &match_test);

Add more cases please, especially focusing on each type of filter =

combination.  E.g. interface only, member only, interface + member, etc.

> +
> +	return l_test_run();
> +}
>

Regards,
-Denis

--===============5467170392205577082==--

