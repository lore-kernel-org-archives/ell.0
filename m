Content-Type: multipart/mixed; boundary="===============3806821599447122295=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 04/20] dbus: Fix _dbus_kernel_calculate_bloom for multiple
 arguments.
Date: Tue, 15 Mar 2016 21:06:17 -0500
Message-ID: <56E8BF99.4080205@gmail.com>
In-Reply-To: <CAOq732KHuTsBx0WZ+681pyEe4rzJx+xchnvcjxWDHHnqRXixaA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3806821599447122295==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/15/2016 05:08 PM, Andrzej Zaborowski wrote:
> Hi Denis,
>
> On 15 March 2016 at 17:27, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 03/14/2016 05:11 PM, Andrzej Zaborowski wrote:
>>> Sorry, l_dbus_message_iter_get_type is a typo, I wanted to say
>>> message_iter_next_entry here.  This function calls it with a fixed
>>> number of parameters and sooner or later it will receive a message
>>> with more arguments and by my reading will segfault.
>>>
>>
>> So l_dbus_message_iter_next_entry is assuming that the programmer knows =
the
>> signature of the next parameter and passes in a variable meant to hold t=
hat
>> parameter.  If there's a mismatch, then yes, it might crash. However, th=
at
>> is why we check the signature ahead of time.
>
> So i've looked at l_dbus_message_iter_next_entry many times and it
> seems it won't stop at the next parameter, although the name could
> suggest that.  It is expecting that the arguments list has a pointer
> for every remaining item in the iterator and it doesn't check for
> NULLs either.  So you can't just pass a single parameter without
> knowing how many items are in the message. and you can't call it
> multiple times on the same iterator except with arrays (I think...).
>

Ah, now I understand.  Yes, you are correct.

l_dbus_message_iter_next_entry wants you to consume everything in the =

enclosing structure.  It is not meant to be used like the traditional =

reference dbus_iter API that iterates over a single item at a time.

Our setup uses get_arguments to parse/validate the top level structure =

and the iterators obtained must then match the signature that the =

programmer expected.

I'm not quite sure why _dbus_kernel_calculate_bloom attempts to use =

message_iter_next_entry.  Don't recall whether the behavior of =

next_entry changed afterward or it was just never tested.  Either way, =

its a bug now.

>>
>> I guess I'm still not quite sure what you're trying to say here :)
>>
>>>>
>>>>> the number and types of call arguments don't match the message
>>>>> arguments.
>>>>> Also try to support the string arguments that come after non-string
>>>>> arguments in the bloom filter.
>>>>
>>>>
>>>>
>>>>   From my reading of systemd code, I didn't think this was possible.  =
But
>>>> I
>>>> could be wrong...
>>>
>>>
>>> I see no problem with the bloom filter containing, say, arg3=3D"hello",
>>> even though arguments 1 and 2 are integers.  I don't know if systemd
>>> supports that but if for example a client adds a match with this kind
>>> of filter, the service must also support that or the signal won't pass
>>> through the filter.
>>>
>>
>> That is the problem with systemd, it does not explicitly document what is
>> and what is not supported.  Having glanced at their bloom filter code ag=
ain,
>> I'm pretty sure only string arguments are currently supported and non-st=
ring
>> arguments in between are not skipped.  This is why our code looks the wa=
y it
>> does.
>>
>> Can you also take a look and confirm?  We are stuck supporting only what
>> systemd supports.
>
> I'm going to look at the systemd code although I'd like to think kdbus
> is not systemd.  Could we do what seems correct and submit a bug
> report against systemd?
>

You'd like to think that, but in reality this is not true :)  systemd =

contains the only kdbus implementation in existence.  So what systemd =

does is the reference behavior.  I'm not aware of any attempts to =

document how argument filters work over kdbus.

> I'm pretty sure it is a bug if a message with "foo" as the 3rd
> argument doesn't match a filter which includes arg2=3D"foo" (2 because
> 0-based..), and there's not even a warning issued when you create such
> a filter, or in the docs.
>

*Shrug* Welcome to open source :)  Don't get me wrong, I do agree with =

you and have submitted patches to systemd in the past.  But that project =

is a very deep rabbit hole.

However, in reality, nobody actually uses arg filtering, outside of =

maybe filtering by arg0.  So its no big loss anyway.

Regards,
-Denis

--===============3806821599447122295==--

