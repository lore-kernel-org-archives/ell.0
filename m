Content-Type: multipart/mixed; boundary="===============4587141413437831607=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Mon, 20 Mar 2017 13:17:59 -0500
Message-ID: <483511e0-bb23-a0c8-3959-cccf04170729@gmail.com>
In-Reply-To: <CAOq732KffO_OX=8sZrPF4S9rCQfyNxXaagNX17LrwHYMSc1kZA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4587141413437831607==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>>
>> errors should not affect properties.
>
> I don't see why not, a Connect error will cause State to change for
> example, could also affect some KnownNetwork properties, but there
> will be some more obvious cases.

I think in our case we emit signals after returning from the Connect =

method call and KnownNetworks doesn't have properties.  But fair enough.

>
>>
>> Your signal + InterfacesAdded example is valid, though probably never oc=
curs
>> in practice.  I can't think of any other situation where an in-order sig=
nal
>> reception was useful.
>
> In all cases it can be worked around by clients like in the Scan case.
> We can fix it on the iwd side just for this one case but I think
> instead we should have a policy that tells clients if they can rely on
> the order of the signals or not.  If not then the test utilities
> should deal with this.

In general the stated policy is that the client cannot rely on the order =

of signals.  However, in certain cases it is extremely advantageous for =

us to implement a logical order and stick to it.  This has the effect =

that a client with decent D-Bus bindings will 'just work'.

Scan() is one such example.

>>
>> I detect hand-waving :)  Can you describe specific situations where this=
 is
>> a concern?
>
> The Scanning case is one but really it's same as other situations
> related to State and other properties, where the client code
> (including agent methods) need to take some decision based on the
> properties.

My original comment was about limiting the scope to a single object. =

E.g. if /foo emits a property change and then sends a method return, =

only property changed signals for /foo should be processed.  The rest =

can be still coalesced.

Can you see a situation where a signal order can be guaranteed across =

objects?

>
> Fixing it just for the Scanning case probably costs us about a line
> more or the same amount code as actually fixing it in general.
> Dropping the coalescing code would simplify the code even more though.
>

So that's the question.  My feeling is that if we don't limit the scope, =

then the coalescing logic is more trouble than it is worth and we should =

just send the signals directly.

Regards,
-Denis


--===============4587141413437831607==--

