Content-Type: multipart/mixed; boundary="===============7489621917468981915=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC/PATCH 00/21] Add support for the
 org.freedesktop.DBus.Properties interface
Date: Mon, 17 Nov 2014 10:24:25 -0600
Message-ID: <546A2139.8020504@gmail.com>
In-Reply-To: <5469CF38.9000106@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7489621917468981915==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

On 11/17/2014 04:34 AM, Tomasz Bursztyka wrote:
> Hi Denis,
>
>>> There is already a dbus service API in ell. I wanted to keep it,
>>> wrapping the
>>> gdbus-like API within the existing functions. However that has proven
>>> to be
>>> impossible unless I would modify the existing API. Thus my
>>> conclusion: if I
>>> have to break the existing API, let's do it all. So I finnally got
>>> rid of the
>>> existing API.
>>
>> I find table/macro based approach unreadable and that is why I did not
>> use the gdbus approach in ell.  I'm actually quite happy with the
>> current API, it fits in with ell's design philosophy much better.  If
>> someone wants to re-use the API from gdbus I'm good with that, but
>> please don't throw stuff out in the process.
>>
>> Right now we are only focused on iwd, and this is our opportunity to
>> try new things.  I wouldn't rush to try and replicate old ways of
>> doing things.
>
> I am fine with trying new things as long as we identify problems to get
> fixed in the old way of doing things.
> Readability is pretty subjective, I did not consider it. (I am ok with
> the table/macro approach)

To me API readability is the most important aspect.  The function based =

approach also allows way more flexibility.  For example, in GDBUS today, =

if we want to implement the non-ObjectManager based APIs, we have omit =

the Property definitions (and thus introspection data).

> The good part with tables over function calls is that it does all at once.

Does what all at once?  You keep a bunch of static memory around until =

someone calls register_interface.

> Technically also, it uses less memory, does way less function calls,
> probably less context switches etc...

Memory? Maybe, or maybe not.  The metadata is pretty compact, what =

wastes most is the linked list overhead.  But then we are able to play =

some pretty neat tricks in order to optimize the introspection =

generation and call dispatch.

However, I digress.  This is all a drop in the bucket in the context of =

the larger program execution.  Trying to optimize any of this, while =

interesting, is not that productive.

> That's also why I kept most of underlying implementation, since it
> technically brings some nice stuff.
>
> The other motivation was of course moving from gdbus to ell in existing
> projects could be much harder if the API is that different.
>

Except you decided to diverge from GDBUS APIs as well for some reason by =

introducing L_DBUS_RW_PROPERTY, L_DBUS_RO_PROPERTY, etc ;)

So here's what I propose.  If you are dead set on adding =

DBus.Properties, then lets do this on top of the existing code.  The =

GDBUS compatibility layer can be bolted on top of that easily enough. =

At the end of the day it is just some extra struct definitions and an =

alternative call to l_dbus_register_interface.  Can probably be done in =

less than a day.

For adding DBus.Properties handlers, we can add something like:
l_dbus_interface_property_add_handlers(interface, property, get_func, =

set_func, exists_func);

The first time the above is called, we automagically add DBus.Properties =

Interface introspection and capability to the object in question.  If it =

isn't called, then we don't include DBus.Properties at all.

Regards,
-Denis

--===============7489621917468981915==--

