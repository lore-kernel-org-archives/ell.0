Content-Type: multipart/mixed; boundary="===============4512353490957287731=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC 4/6] dbus: Add support for proxy interface
Date: Fri, 01 Dec 2017 09:40:36 -0600
Message-ID: <6db58dc6-c89f-3655-a56f-cc5c46856b44@gmail.com>
In-Reply-To: <3899174.ZFCDLsYfQH@ix>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4512353490957287731==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Szymon,

>> I'm okay with this being the first naive solution, but this seems quite
>> wasteful.  Can we store the serialized property data without the
>> enclosing message?  E.g. by using GVariant serializer and storing the
>> raw data?
> =

> Yeah, I was aware of that when sending patches :) Just wasn't sure on what
> else could I use. I can fix that in subsequent patch if this is OK?
> =


That's fine.

>>> +	/* TODO should we allow to set different root? */
>>> +	client->objects_call =3D l_dbus_method_call(dbus, client->service, "/=
",
>>
>> Should "/" be client->path instead?  Note that ell only exports
>> ObjectManager on the root path.  It doesn't export it for any child
>> paths.  However, BlueZ might act differently.
> =

> BlueZ also exports it on "/".
> Maybe to cover all we could have root param in l_dbus_client_new()?
> Other option would be to add eg l_dbus_client_new_full() that would
> allow to specify root while l_dbus_client_new() would always use "/"?
> =


If you have no usecase for this right now I would simply not worry about =

it for now.  Just drop the client parameter from client_new and if we =

ever need this at some point we can either add a _set function or a new =

constructor.

Regards,
-Denis

--===============4512353490957287731==--

