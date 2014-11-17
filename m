Content-Type: multipart/mixed; boundary="===============1655610464656007732=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: Re: [RFC/PATCH 00/21] Add support for the
 org.freedesktop.DBus.Properties interface
Date: Mon, 17 Nov 2014 12:34:32 +0200
Message-ID: <5469CF38.9000106@linux.intel.com>
In-Reply-To: <5464D099.3010901@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1655610464656007732==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

>> There is already a dbus service API in ell. I wanted to keep it, =

>> wrapping the
>> gdbus-like API within the existing functions. However that has proven =

>> to be
>> impossible unless I would modify the existing API. Thus my =

>> conclusion: if I
>> have to break the existing API, let's do it all. So I finnally got =

>> rid of the
>> existing API.
>
> I find table/macro based approach unreadable and that is why I did not =

> use the gdbus approach in ell.  I'm actually quite happy with the =

> current API, it fits in with ell's design philosophy much better.  If =

> someone wants to re-use the API from gdbus I'm good with that, but =

> please don't throw stuff out in the process.
>
> Right now we are only focused on iwd, and this is our opportunity to =

> try new things.  I wouldn't rush to try and replicate old ways of =

> doing things.

I am fine with trying new things as long as we identify problems to get =

fixed in the old way of doing things.
Readability is pretty subjective, I did not consider it. (I am ok with =

the table/macro approach)
The good part with tables over function calls is that it does all at once.
Technically also, it uses less memory, does way less function calls, =

probably less context switches etc...
That's also why I kept most of underlying implementation, since it =

technically brings some nice stuff.

The other motivation was of course moving from gdbus to ell in existing =

projects could be much harder if the API is that different.

>> - When it's required to send an empty reply, it would be good to have =

>> a helper
>>    function I think, which wraps l_dbus_message_new_method_return() +
>>    l_dbus_message_set_arguments + l_dbus_send together (see patch 15 in
>>    function l_dbus_pending_property_success).
>>
>
> We probably need a simple wrapper for l_dbus_message_new_method_return =

> that takes varargs.  Similar to l_dbus_message_new_error().  The send =

> step should probably not be combined in the ell API directly.

Better approach yes, will prepare a patch for it.

Tomasz

--===============1655610464656007732==--

