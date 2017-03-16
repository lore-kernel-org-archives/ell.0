Content-Type: multipart/mixed; boundary="===============0847180214749719257=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: l_genl_family_new() successfully returns if generic netlink
 family doesn't exist.
Date: Wed, 15 Mar 2017 22:08:31 -0500
Message-ID: <326424ec-aa2e-299b-56b2-7cb86f5dc6e8@gmail.com>
In-Reply-To: <CAPyD+=C_JaXz9TWBv6+kCGVCa3ZZeF6yQbq3x67VXrx+pwacZw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0847180214749719257==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 03/15/2017 03:38 PM, Othman, Ossama wrote:
> Hi,
>
> The function l_genl_family_new() successfully returns if the desired
> generic netlink family isn't available in the kernel.  For example,
> suppose one does the following:
>
>     struct l_genl_family * family =3D l_genl_family_new(genl, "foo");
>
> If the "foo" generic netlink family doesn't exist in the kernel, for
> whatever reason, l_genl_family_new() will still return a valid
> pointer.  Is this the expected behavior?

Yes.  The family detection is asynchronous, so the object is created, =

but you can't assume the family is valid until the appeared callback has =

been called.  This can be used to detect families that can come and go =

in the kernel.  E.g. via module loading / unloading.

>
> It looks like some code exists in the implementation that would have
> allowed one to be notified of such a problem by calling a
> user-specified "vanished" watch callback.  Specifically,
> l_genl_family_new() constructs a CTRL_ATTR_FAMILY_NAME generic netlink
> message with a callback function get_family_callback().  The latter
> detects and handles an error like so:
>
>     error =3D l_genl_msg_get_error(msg);
>         if (error < 0) {
>             if (family->watch_vanished)
>                 family->watch_vanished(family->watch_data);
>                return;
>     }
>
> A "vanished" watch never gets called since there is apparently no way
> to set it beforehand.  Is that correct?

You set it after-hand.  E.g.
l_genl_family_new();
l_genl_family_set_watches(family, family_appeared, family_vanished, ...);

This works because the underlying CTRL_CMD_GETFAMILY is not actually =

sent over the socket until the next event loop iteration.

Regards,
-Denis

--===============0847180214749719257==--

