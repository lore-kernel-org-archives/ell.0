Content-Type: multipart/mixed; boundary="===============8249516771128704194=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: RFC: DBus send_with_reply wrapper doesn't time out
Date: Sun, 12 Apr 2020 02:16:25 +0000
Message-ID: <c48cf681be84fe8cb3ed2b3d50c15f81e16ee5a0.camel@intel.com>
In-Reply-To: <c0ed64f0-199a-60f1-3d95-4aa0be7a9e7f@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8249516771128704194==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 2020-04-09 at 02:52 -0500, Denis Kenzior wrote:
> Hi Brian,
> =

> > It does, however, create the potential for at least a temporary resourc=
e leak. The hashmap gets saved for
> > as long as it takes...   if we time out the on the responde, is there a=
nyway to tell ELL to cancel and
> > cleanup the hashmap?
> =

> That is what the destroy callback of l_dbus_send_with_reply is for.  The =

> destroy callback gets called on userdata in all cases to free up any =

> resources.
> =

> In the normal case it is called after the callback is invoked, but can =

> also be called as a result of l_dbus_cancel, etc.

Ah...  That is the API I need.  l_dbus_send_with_reply() returns a serial n=
umber, and l_dbus_cancel() accepts a
serial number to cancel.  So we can add our own timeouts, and call the dbus=
_cancel with the saved serial number
if we don't get the timeout we are waiting for.

Thanks.

> =

> Regards,
> -Denis

--===============8249516771128704194==--

