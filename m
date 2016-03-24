Content-Type: multipart/mixed; boundary="===============2998188143158125578=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 13/15] dbus: Add message filter public API.
Date: Thu, 24 Mar 2016 13:04:33 -0500
Message-ID: <56F42C31.5090105@gmail.com>
In-Reply-To: <1458598224-29325-13-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2998188143158125578==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
> A do-it-all single method to add a signal filter, an alternative would
> be to add a bunch of functions for specific use cases.
> ---
>   ell/dbus.c | 123 ++++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/dbus.h |   7 ++++
>   2 files changed, 130 insertions(+)
>

Applied.  One more thought below:

> +LIB_EXPORT unsigned int l_dbus_add_signal_watch(struct l_dbus *dbus,
> +						const char *sender,
> +						const char *path,
> +						const char *interface,
> +						const char *member, ...)
> +{
> +	struct _dbus_filter_condition *rule;
> +	int rule_len;
> +	va_list args;
> +	const char *value;
> +	l_dbus_message_func_t signal_func;
> +	enum l_dbus_match_type type;
> +	void *user_data;
> +	unsigned int id;
> +
> +	va_start(args, member);
> +
> +	rule_len =3D 0;
> +	while ((type =3D va_arg(args, enum l_dbus_match_type)) !=3D
> +			L_DBUS_MATCH_NONE)
> +		rule_len++;
> +
> +	va_end(args);
> +
> +	rule =3D l_new(struct _dbus_filter_condition, rule_len + 5);
> +
> +	rule_len =3D 0;
> +
> +	rule[rule_len].type =3D L_DBUS_MATCH_TYPE;
> +	rule[rule_len++].value =3D "signal";
> +
> +	if (sender) {
> +		rule[rule_len].type =3D L_DBUS_MATCH_SENDER;
> +		rule[rule_len++].value =3D sender;
> +	}

Does it make sense to make glob-match values part of the tree?

For example, I can install watch 1 with:
type=3D'signal', path=3D'/'

and watch 2 with:
type=3D'signal', sender=3D'org.foo', path=3D'/'

Right now it seems we will generate 2 AddMatch cases for the above, even =

though watch 2 is already covered by watch 1.

> +
> +	if (path) {
> +		rule[rule_len].type =3D L_DBUS_MATCH_PATH;
> +		rule[rule_len++].value =3D path;
> +	}
> +
> +	if (interface) {
> +		rule[rule_len].type =3D L_DBUS_MATCH_INTERFACE;
> +		rule[rule_len++].value =3D interface;
> +	}
> +
> +	if (member) {
> +		rule[rule_len].type =3D L_DBUS_MATCH_MEMBER;
> +		rule[rule_len++].value =3D member;
> +	}
> +
> +	va_start(args, member);
> +
> +	while (true) {
> +		type =3D va_arg(args, enum l_dbus_match_type);
> +		if (type =3D=3D L_DBUS_MATCH_NONE)
> +			break;
> +
> +		value =3D va_arg(args, const char *);
> +
> +		rule[rule_len].type =3D type;
> +		rule[rule_len++].value =3D value;
> +	}
> +
> +	signal_func =3D va_arg(args, l_dbus_message_func_t);
> +	user_data =3D va_arg(args, void *);
> +
> +	va_end(args);
> +
> +	id =3D _dbus_filter_add_rule(dbus->filter, rule, rule_len,
> +					signal_func, user_data);
> +
> +	l_free(rule);
> +
> +	return id;
> +}

Regards,
-Denis


--===============2998188143158125578==--

