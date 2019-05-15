Content-Type: multipart/mixed; boundary="===============8687726259904381597=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: l_dbus_message_set_arguments
Date: Wed, 15 May 2019 13:18:35 -0500
Message-ID: <51ecea74-fa44-fe0b-408a-d50ddd03debd@gmail.com>
In-Reply-To: <1557944201.32584.9.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8687726259904381597==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 05/15/2019 01:16 PM, Gix, Brian wrote:
> =

> When creating a response to a D-Bus message with
> =

> reply =3D l_dbus_message_new_method_return(msg);
> =

> where the original method has an empty (void) return list, is it neccessa=
ry to set the arguments:
> =

> l_dbus_message_set_arguments(reply, "");
> =

> or can I just:
> =

> return l_dbus_message_new_method_return(msg);
> =

> from within the message handler? (without setting non-existant arguments)

either will work.  The latter is what I prefer to see/use.

See:
https://git.kernel.org/pub/scm/libs/ell/ell.git/tree/ell/dbus.c#n321

Regards,
-Denis

--===============8687726259904381597==--

