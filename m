Content-Type: multipart/mixed; boundary="===============1885649424136455241=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 4/8] dbus: l_dbus_name_acquire public API and driver
 declarations
Date: Sat, 26 Mar 2016 01:15:30 +0100
Message-ID: <CAOq732LkORrwXgUBEinc-xnL-uRaBSO9aJtOmVNDgpkhEiuzuQ@mail.gmail.com>
In-Reply-To: <56F4AA9F.2040600@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1885649424136455241==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 25 March 2016 at 04:03, Denis Kenzior <denkenz@gmail.com> wrote:
> On 03/23/2016 09:07 PM, Andrew Zaborowski wrote:
>> +/**
>> + * l_dbus_name_acquire:
>> + * @dbus: D-Bus connection
>> + * @name: Well-known bus name to be acquired
>> + * @allow_replacement: Whether to allow another peer's name request to
>> + *                     take the name ownership away from this connection
>> + * @replace_existing: Whether to allow D-Bus to take the name's ownersh=
ip
>> + *                    away from another peer in case the name is already
>> + *                    owned and allows replacement.  Ignored if name is
>> + *                    currently free.
>> + * @queue: Whether to allow the name request to be queued by D-Bus in
>> + *         case it cannot be acquired now, rather than to return a
>> failure.
>> + * @callback: Callback to receive the request result when done.
>> + *
>> + * Acquire a well-known bus name (service name) on the bus.
>> + *
>> + * Returns: a non-zero request serial that can be passed to l_dbus_canc=
el
>> + *          while waiting for the callback, or zero on failure.
>
>
> Yet kdbus version returns some hard-coded number that can't be used by
> l_dbus_cancel.  I don't like this API asymmetry.

It can't be used with l_dbus_cancel because the callback has already
happened and the comment says specifically "while waiting for the
callback".

> Can't we just return void
> and let the callback parameters tell the application what happened?

The problems is the callback needs to be cancellable or I think this
will put a burden on users when they can't free their local state
immediately because they need to always wait for the callback.  What
about passing the result through the callback and returning 0 from
this function if the callback was immediate?

Best regards

--===============1885649424136455241==--

