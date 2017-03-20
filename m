Content-Type: multipart/mixed; boundary="===============6742459864047882995=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Mon, 20 Mar 2017 09:53:54 -0500
Message-ID: <70173441-32e0-6bc0-3a07-5f8773ccecd2@gmail.com>
In-Reply-To: <CAOq732+D4gBVX+CoD7NYaxkc1NtuyRoDcSVobmCd=gYXTBXWFA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6742459864047882995==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>>> +       _dbus_object_tree_signals_flush(dbus);
>>> +
>>
>>
>> Should this only affect method returns?
>
> Not sure, I thought it would be better to guarantee the ordering on
> the dbus socket generally for all messages and not have to worry if
> the issue may possibly come back in the future.  I think it should

If you're worried about every possibility that you're being this heavy =

handed, it might be simpler to just get rid of the coalescing code and =

simply always emit the property changed signal right away.  We're not =

saving much on average by having it.

> affect at least method returns, signals and errors, if we want to do
> it.  Method calls I'm not sure because services don't make any except
> to agents, but it may be worth doing for the agent calls.

errors should not affect properties.

Your signal + InterfacesAdded example is valid, though probably never =

occurs in practice.  I can't think of any other situation where an =

in-order signal reception was useful.

Method calls I think we can ignore completely.

>
>>
>> Also, this causes (potentially lots) of getter calls to be made.  Would =
it
>> not be better (and safer) to only send the properties for the object whi=
ch
>> is generating the method return?
>
> Again if we do that there will be some situations where the clients
> will have to work around issues.  If the getter calls are an issue we
> can probably move the other messages to idle callbacks too, relatively
> easily.

I detect hand-waving :)  Can you describe specific situations where this =

is a concern?

Again, my argument above applies.  If we're being this heavy handed, =

maybe coalescing needs to not happen in the first place.

Regards,
-Denis

--===============6742459864047882995==--

