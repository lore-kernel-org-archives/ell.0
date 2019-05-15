Content-Type: multipart/mixed; boundary="===============5833821897356740698=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: Re: l_dbus_message_set_arguments
Date: Wed, 15 May 2019 11:23:35 -0700
Message-ID: <670f48d6254aaf413856ca144edc96d1869a8630.camel@linux.intel.com>
In-Reply-To: <1557944201.32584.9.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5833821897356740698==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On Wed, 2019-05-15 at 18:16 +0000, Gix, Brian wrote:
> When creating a response to a D-Bus message with =

> =

> reply =3D l_dbus_message_new_method_return(msg);
> =

> where the original method has an empty (void) return list, is it
> neccessary to set the arguments:
> =

> l_dbus_message_set_arguments(reply, "");
> =

> or can I just:
> =

> return l_dbus_message_new_method_return(msg);
> =

> from within the message handler? (without setting non-existant
> arguments)

I don't think you have to set the arguments if there isn't any. We do
it both ways in IWD, but it doesn't seem to be required.

Thanks,
James

> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell


--===============5833821897356740698==--

