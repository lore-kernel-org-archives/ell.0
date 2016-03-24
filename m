Content-Type: multipart/mixed; boundary="===============4799152341567558112=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 09/15] dbus: Classic dbus filter_ops implementation.
Date: Thu, 24 Mar 2016 12:41:15 -0500
Message-ID: <56F426BB.4020105@gmail.com>
In-Reply-To: <1458598224-29325-9-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4799152341567558112==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
> For the name owner tracking I decided to subscribe to all name
> owner changes instead of adding separate rules for every name because
> in some scenarios that saves us cycles/memory and we don't have
> to hold a list of IDs of every such rule so that we could remove them
> when no longer needed.
> ---
>   ell/dbus.c | 135 ++++++++++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   1 file changed, 135 insertions(+)
>

I went ahead and applied this one.

One thought / suggestion below:

> +static bool classic_remove_match(struct l_dbus *dbus, unsigned int id)
> +{
> +	struct l_dbus_classic *classic =3D
> +		container_of(dbus, struct l_dbus_classic, super);
> +	char *match_str =3D l_hashmap_remove(classic->match_strings,
> +						L_UINT_TO_PTR(id));

DBus-1 doesn't reference the AddMatch/RemoveMatch stuff by id, so we =

store the match strings here for future lookup.

In theory, we could get rid of this hashmap by sending in the full rule =

set into the remove_match method as well.  If I grok things correctly, =

the information is present in the filter_node structures, we'd just need =

to build the rule set during remove_recurse, which can be done with a =

simple stack structure.

This should save us some run-time memory at the expense of a bit more =

processing.

> +	struct l_dbus_message *message;
> +
> +	if (!match_str)
> +		return false;
> +
> +	message =3D l_dbus_message_new_method_call(dbus,
> +						DBUS_SERVICE_DBUS,
> +						DBUS_PATH_DBUS,
> +						L_DBUS_INTERFACE_DBUS,
> +						"RemoveMatch");
> +
> +	l_dbus_message_set_arguments(message, "s", match_str);
> +
> +	send_message(dbus, false, message, NULL, NULL, NULL);
> +
> +	l_free(match_str);
> +
> +	return true;
> +}
> +

Regards,
-Denis


--===============4799152341567558112==--

