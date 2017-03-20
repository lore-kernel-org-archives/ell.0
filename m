Content-Type: multipart/mixed; boundary="===============1517441913092578588=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Mon, 20 Mar 2017 17:53:00 +0100
Message-ID: <CAOq732KffO_OX=8sZrPF4S9rCQfyNxXaagNX17LrwHYMSc1kZA@mail.gmail.com>
In-Reply-To: <70173441-32e0-6bc0-3a07-5f8773ccecd2@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1517441913092578588==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 20 March 2017 at 15:53, Denis Kenzior <denkenz@gmail.com> wrote:
>> Not sure, I thought it would be better to guarantee the ordering on
>> the dbus socket generally for all messages and not have to worry if
>> the issue may possibly come back in the future.  I think it should
>
>
> If you're worried about every possibility that you're being this heavy
> handed, it might be simpler to just get rid of the coalescing code and
> simply always emit the property changed signal right away.  We're not sav=
ing
> much on average by having it.
>
>> affect at least method returns, signals and errors, if we want to do
>> it.  Method calls I'm not sure because services don't make any except
>> to agents, but it may be worth doing for the agent calls.
>
>
> errors should not affect properties.

I don't see why not, a Connect error will cause State to change for
example, could also affect some KnownNetwork properties, but there
will be some more obvious cases.

>
> Your signal + InterfacesAdded example is valid, though probably never occ=
urs
> in practice.  I can't think of any other situation where an in-order sign=
al
> reception was useful.

In all cases it can be worked around by clients like in the Scan case.
We can fix it on the iwd side just for this one case but I think
instead we should have a policy that tells clients if they can rely on
the order of the signals or not.  If not then the test utilities
should deal with this.

>
> Method calls I think we can ignore completely.
>
>>
>>>
>>> Also, this causes (potentially lots) of getter calls to be made.  Would
>>> it
>>> not be better (and safer) to only send the properties for the object
>>> which
>>> is generating the method return?
>>
>>
>> Again if we do that there will be some situations where the clients
>> will have to work around issues.  If the getter calls are an issue we
>> can probably move the other messages to idle callbacks too, relatively
>> easily.
>
>
> I detect hand-waving :)  Can you describe specific situations where this =
is
> a concern?

The Scanning case is one but really it's same as other situations
related to State and other properties, where the client code
(including agent methods) need to take some decision based on the
properties.

Fixing it just for the Scanning case probably costs us about a line
more or the same amount code as actually fixing it in general.
Dropping the coalescing code would simplify the code even more though.

Best regards

--===============1517441913092578588==--

