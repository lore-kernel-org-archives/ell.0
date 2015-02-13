Content-Type: multipart/mixed; boundary="===============1765128898127788381=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Re: [PATCH v2 2/3] dbus: Add disconnect watch support
Date: Fri, 13 Feb 2015 16:23:10 +0200
Message-ID: <1423837390.4196.34.camel@linux.intel.com>
In-Reply-To: <54DE03B6.9070309@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1765128898127788381==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On pe, 2015-02-13 at 08:01 -0600, Denis Kenzior wrote:
> Hi Jukka,
> =

> <snip>
> =

>  >>> +struct filter_data {
> >>> +	struct l_dbus *dbus;
> >>> +	l_dbus_message_func_t handle_func;
> >>> +	l_dbus_watch_func_t connect_func;
> >>> +	l_dbus_watch_func_t disconnect_func;
> >>> +	char *name;
> >>> +	char *owner;
> >>
> >> What is the exact difference between name and owner?  I don't see a
> >> distinction...
> >
> > name is something like "org.foobar" and owner is ":1.101"
> >
> > User registers watch using a name and dbus-daemon sends its
> > notifications about NameOwnerChanged signals using the owner format so
> > we need to track both formats.
> =

> Yes, but you don't actually handle that anywhere.  So I don't see a =

> distinction in the current code.  If this is TBD, then simply don't =

> include this and mention somewhere that only unique bus names are support=
ed.

Hmm, owner and name are handled differently in the code. For example see
the format_rule() function.

> =

> <snip>
> =

> >>> +	if (arg && data->argument && strcmp(arg, data->argument))
> >>> +		goto out;
> >>
> >> This looks wrong
> >
> > Please elaborate more?
> >
> =

> If arg is NULL, the matching continues.  I do not think that is what you =

> want, but I've not read the DBus spec lately.  This needs a unit test cas=
e.
> =

> <snip>
> =

> >>> +LIB_EXPORT unsigned int l_dbus_add_service_watch(struct l_dbus *dbus,
> >>> +					const char *name,
> >>> +					l_dbus_watch_func_t connect_func,
> >>> +					l_dbus_watch_func_t disconnect_func,
> >>> +					void *user_data,
> >>> +					l_dbus_destroy_func_t destroy)
> >>> +{
> >>> +	struct filter_data *data;
> >>> +
> >>> +	if (!name)
> >>> +		return 0;
> >>> +
> >>> +	if (connect_func)
> >>> +		return -EOPNOTSUPP;
> >>
> >> Why? You seem to be handling that just fine?
> >
> > No, connect watch needs more work as more code needs to be done. I only
> > needed the disconnect watch for my app so in order to speed things up,
> > left the connect to be done later when such need arises. The connect
> > pointer is in the API so that we do not need to change the API later.
> >
> =

> Okay.  But this is still wrong.  The return value is an unsigned int. =

> You're returning a negative errno.

Yep, clearly a bug.

> =

> Might want to make this into an internal private function for now.

Ok.

> =

> Regards,
> -Denis


Jukka



--===============1765128898127788381==--

