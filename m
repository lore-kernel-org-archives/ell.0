Content-Type: multipart/mixed; boundary="===============3444243833114697416=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC/PATCH 00/21] Add support for the
 org.freedesktop.DBus.Properties interface
Date: Thu, 13 Nov 2014 09:39:05 -0600
Message-ID: <5464D099.3010901@gmail.com>
In-Reply-To: <1415874985-13034-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3444243833114697416==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

Just some preliminary comments:

> There is already a dbus service API in ell. I wanted to keep it, wrapping=
 the
> gdbus-like API within the existing functions. However that has proven to =
be
> impossible unless I would modify the existing API. Thus my conclusion: if=
 I
> have to break the existing API, let's do it all. So I finnally got rid of=
 the
> existing API.

I find table/macro based approach unreadable and that is why I did not =

use the gdbus approach in ell.  I'm actually quite happy with the =

current API, it fits in with ell's design philosophy much better.  If =

someone wants to re-use the API from gdbus I'm good with that, but =

please don't throw stuff out in the process.

Right now we are only focused on iwd, and this is our opportunity to try =

new things.  I wouldn't rush to try and replicate old ways of doing things.

To support DBus.Properties some modifications would absolutely be =

required to the l_dbus_interface_property method.  What other changes do =

you feel are necessary?

> Also, patch 4, due to the port of the constants structure, it looses the
> pre-built signature, thus adding the necessity to add a compare_signature=
()
> function as in GDBus. It was nice to get this full pre-built signature th=
at
> could be compared at once. If you have ideas how to get it without changi=
ng the
> API... Like changing the macro L_DBUS_ARGS() or L_DBUS_METHOD, so it woul=
d set
> a const char * in_signature/out_signature in struct l_dbus_method for ins=
tance?
>

Macro magic won't really help here.  However, you can do this as part of =

the l_dbus_register_interface call.  It would be no different from the =

current setup, just the information is coming from a static array =

instead of vargs.

> About other improvements:
> - patch 1 is a tiny helper I required in patch 15, since ell checks the
>    signature of the variant we try to set, before calling the set functio=
n.
> - patch 2 and 3 are there to separate the code properly. It hads thus a g=
etter
>    function for the object tree, but there is no shared structure informa=
tions
>    between dbus.c and dbus-service.c. I figured out it was cleaner that w=
ay imo.
>

I'm okay with these

> Minor issues:
> - I put the error message macros in dbus-private.h, figuring that some ot=
her
>    part of the code could need it. But maybe it's better no to share thos=
e?

Always err on the side of opaqueness. If someone needs it later, it is =

simple to move the #define appropriately.  If no one needs it, you just =

cluttered up the namespace.

>
> - When it's required to send an empty reply, it would be good to have a h=
elper
>    function I think, which wraps l_dbus_message_new_method_return() +
>    l_dbus_message_set_arguments + l_dbus_send together (see patch 15 in
>    function l_dbus_pending_property_success).
>

We probably need a simple wrapper for l_dbus_message_new_method_return =

that takes varargs.  Similar to l_dbus_message_new_error().  The send =

step should probably not be combined in the ell API directly.

Regards,
-Denis

--===============3444243833114697416==--

