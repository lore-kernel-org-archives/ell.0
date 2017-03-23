Content-Type: multipart/mixed; boundary="===============3843169079281366281=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Thu, 23 Mar 2017 16:29:47 +0100
Message-ID: <CAOq732+E9mVWiFp00dXKnLYE6sPKeykLX5yUdb=pvGGeANrTVg@mail.gmail.com>
In-Reply-To: <483511e0-bb23-a0c8-3959-cccf04170729@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3843169079281366281==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 20 March 2017 at 19:17, Denis Kenzior <denkenz@gmail.com> wrote:
>> In all cases it can be worked around by clients like in the Scan case.
>> We can fix it on the iwd side just for this one case but I think
>> instead we should have a policy that tells clients if they can rely on
>> the order of the signals or not.  If not then the test utilities
>> should deal with this.
>
>
> In general the stated policy is that the client cannot rely on the order =
of
> signals.  However, in certain cases it is extremely advantageous for us to
> implement a logical order and stick to it.  This has the effect that a
> client with decent D-Bus bindings will 'just work'.

Then doing the same thing in all the cases can't hurt either ;)

>
> Scan() is one such example.

Ok, I sent a patch trying a yet different approach, if you think that
is not what we want then I'll try just adding a public function for
Scan() to call before returning like you suggested earlier.

>
>>>
>>> I detect hand-waving :)  Can you describe specific situations where this
>>> is
>>> a concern?
>>
>>
>> The Scanning case is one but really it's same as other situations
>> related to State and other properties, where the client code
>> (including agent methods) need to take some decision based on the
>> properties.
>
>
> My original comment was about limiting the scope to a single object. E.g.=
 if
> /foo emits a property change and then sends a method return, only property
> changed signals for /foo should be processed.  The rest can be still
> coalesced.

Ok, I sent a patch attempting this, not 100% sure if this is what you
meant though.

With this patch the MFP-Options test fails for me.  I spent some time
trying to figure out why it seemed to work with the previous patch I
sent, where all signals were flushed on any message being sent.  I
think there was still a race and it works by pure luck (but works all
the times I tried).  Either the test code needs to call Scan() again
before GetOrderedNetworks() or the scan abort callback in iwd needs to
avoid forgetting the list of networks, I'll send a patch for this.

>
> Can you see a situation where a signal order can be guaranteed across
> objects?

Do you mean where it would be needed by the client?  I guess in cases
similar to the MFP-Options test except where the code relied on the
state of the Network objects instead of calling a method like
GetOrderedNetworks.  In this case the Scan() method is on one object
but the properties that the client needs are on other objects.

>
>>
>> Fixing it just for the Scanning case probably costs us about a line
>> more or the same amount code as actually fixing it in general.
>> Dropping the coalescing code would simplify the code even more though.
>>
>
> So that's the question.  My feeling is that if we don't limit the scope,
> then the coalescing logic is more trouble than it is worth and we should
> just send the signals directly.

I think it's a little costly but it's also a nice feature because the
spec seems to expect you to send related property changes and
interface changes in one signal so we'e a better citizen by doing
this.

Best regards

--===============3843169079281366281==--

