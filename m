Content-Type: multipart/mixed; boundary="===============5715004796875847305=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Wed, 13 Apr 2016 01:30:32 +0200
Message-ID: <CAOq732JMGVZ2MV=araQ=zxU2YcrQKhGKZm_5CDDUa3Z5=1OpCw@mail.gmail.com>
In-Reply-To: <570D823A.3000907@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5715004796875847305==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 13 April 2016 at 01:18, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/12/2016 06:06 PM, Andrzej Zaborowski wrote:
>> On 13 April 2016 at 00:25, Denis Kenzior <denkenz@gmail.com> wrote:
>>> On 04/12/2016 05:10 PM, Andrzej Zaborowski wrote:
>>>> Hmm true.  But the body is now enclosed in a variant, so what buffer
>>>> do you suggest to write that into and assign to item->ver.address?
>>>>
>>>
>>> This is actually a nasty issue with kdbus.  As you say, variant must be=
 a
>>> single type, this is specified in DBus-1 Spec somewhere.  So if we are =
to
>>> enclose it in a variant like kdbus wants, then it either needs to be:
>>> 1. enclosed in '()'
>>> 2. special cased.
>>>
>>> You're doing 1, however won't this result in the message signature being
>>> different depending on the the transport being used?
>>
>>
>> Why?  If we assume that the message's signature is the type in the
>> variant witout the () I don't see any ambiguity there.
>>
>
> From what I understood, the current setup will result in
> l_dbus_message_get_signature() returning different results, depending on
> transport.

Could you give an example?  For a GetProperties reply
l_dbus_message_get_signature() should return "a{sv}" on both kdbus and
dbus1.  On kdbus the we'll have a (yyyyuta{tv}v) gvariant where the
variant contians a (a{sv}) gvariant, but the API should completely
hide that unless I screwed it up.

>
> So we probably need to some extra handling to make that extra set of '()'
> hidden.
>
>> I didn't find a specific statement of that in the docs although
>> https://wiki.gnome.org/Projects/GLib/GDBus/Version2 does say:
>>
>> "The body of the message is inside of the variant at the end. The body
>> must be a tuple. "
>>
>
> That's not terribly specific.  How does the kdbus signature look like?
>
>>>
>>> Can we special case the building of this variant for gvariant based
>>> messages?  Similar to how we're generating the signature on the fly in
>>> the
>>> builder?
>>
>>
>> Is it worth it though, just to save a memcpy?
>>
>
> If the memcpy is like 64k, then it might be worth it.
>
> Can we generate the needed variant inside dbus_message_builder_finalize? =
or
> somewhere around that time?

But we'll still need a memcpy, unless we use a separate io vector when
sending the message to the kdbus FD, but I'd have to check if it
doesn't break the splitting rules.

>
> And this whole thing is a great example of how not to design a marshaling
> format.

Well, for one it gets rid of the split between the header and body in
Dbus1 which was unneeded and while doing that is saves bytes because
the variant adds fewer extra bytes than the
DBUS_MESSAGE_FIELD_SIGNATURE field in Dbus1 ;)

Best regards

--===============5715004796875847305==--

