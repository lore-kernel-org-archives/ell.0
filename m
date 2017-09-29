Content-Type: multipart/mixed; boundary="===============0276276336320575382=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus: Check nesting depth and set proper D-Bus stack
 depth
Date: Fri, 29 Sep 2017 16:25:05 -0500
Message-ID: <67181960-d7ad-8165-c683-4bbd75506a1f@gmail.com>
In-Reply-To: <20170929204215.9897-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0276276336320575382==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 09/29/2017 03:42 PM, Mat Martineau wrote:
> The maximum nesting level was not being enforced, and the stack array use=
d to
> generate D-Bus messages was not large enough.
> ---
>   ell/dbus-message.c | 24 +++++++++++++++++++++---
>   1 file changed, 21 insertions(+), 3 deletions(-)
> =

> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
> index ae132c4..9b24752 100644
> --- a/ell/dbus-message.c
> +++ b/ell/dbus-message.c

<snip>

> @@ -548,6 +553,9 @@ static bool message_iter_next_entry_valist(struct l_d=
bus_message_iter *orig,
>   			break;
>   		case ')':
>   		case '}':
> +			if (indent =3D=3D 0)
> +				return false;
> +
>   			signature +=3D 1;
>   			indent -=3D 1;
>

If we validate the signature in the beginning, then this really can't =

happen.  We should put an unlikely in here and maybe even a comment.

> @@ -1082,7 +1090,8 @@ static bool append_arguments(struct l_dbus_message =
*message,
>   	char *generated_signature;
>   	char subsig[256];
>   	const char *sigend;
> -	struct container stack[32];
> +	/* Nesting requires an extra stack entry for the base level */
> +	struct container stack[DBUS_MAX_NESTING + 1];
>   	unsigned int stack_index =3D 0;
>   =

>   	if (_dbus_message_is_gvariant(message))
> @@ -1127,7 +1136,7 @@ static bool append_arguments(struct l_dbus_message =
*message,
>   				ret =3D false;
>   			}
>   =

> -			if (!ret)
> +			if (!ret || !stack_index)
>   				goto error;

Hmm, this again should not be possible given that the leave_foo =

functions should fail.  Should we have this check prior to attempting to =

call the driver->leave_foo methods?  And again, unlikely would be good here.

>   =

>   			stack_index -=3D 1;

Regards,
-Denis

--===============0276276336320575382==--

