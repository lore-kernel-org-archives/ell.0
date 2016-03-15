Content-Type: multipart/mixed; boundary="===============1328379389684959735=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 04/20] dbus: Fix _dbus_kernel_calculate_bloom for multiple
 arguments.
Date: Tue, 15 Mar 2016 23:08:50 +0100
Message-ID: <CAOq732KHuTsBx0WZ+681pyEe4rzJx+xchnvcjxWDHHnqRXixaA@mail.gmail.com>
In-Reply-To: <56E837D8.5040907@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1328379389684959735==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 15 March 2016 at 17:27, Denis Kenzior <denkenz@gmail.com> wrote:
> On 03/14/2016 05:11 PM, Andrzej Zaborowski wrote:
>> Sorry, l_dbus_message_iter_get_type is a typo, I wanted to say
>> message_iter_next_entry here.  This function calls it with a fixed
>> number of parameters and sooner or later it will receive a message
>> with more arguments and by my reading will segfault.
>>
>
> So l_dbus_message_iter_next_entry is assuming that the programmer knows t=
he
> signature of the next parameter and passes in a variable meant to hold th=
at
> parameter.  If there's a mismatch, then yes, it might crash. However, that
> is why we check the signature ahead of time.

So i've looked at l_dbus_message_iter_next_entry many times and it
seems it won't stop at the next parameter, although the name could
suggest that.  It is expecting that the arguments list has a pointer
for every remaining item in the iterator and it doesn't check for
NULLs either.  So you can't just pass a single parameter without
knowing how many items are in the message. and you can't call it
multiple times on the same iterator except with arrays (I think...).

>
> I guess I'm still not quite sure what you're trying to say here :)
>
>>>
>>>> the number and types of call arguments don't match the message
>>>> arguments.
>>>> Also try to support the string arguments that come after non-string
>>>> arguments in the bloom filter.
>>>
>>>
>>>
>>>  From my reading of systemd code, I didn't think this was possible.  But
>>> I
>>> could be wrong...
>>
>>
>> I see no problem with the bloom filter containing, say, arg3=3D"hello",
>> even though arguments 1 and 2 are integers.  I don't know if systemd
>> supports that but if for example a client adds a match with this kind
>> of filter, the service must also support that or the signal won't pass
>> through the filter.
>>
>
> That is the problem with systemd, it does not explicitly document what is
> and what is not supported.  Having glanced at their bloom filter code aga=
in,
> I'm pretty sure only string arguments are currently supported and non-str=
ing
> arguments in between are not skipped.  This is why our code looks the way=
 it
> does.
>
> Can you also take a look and confirm?  We are stuck supporting only what
> systemd supports.

I'm going to look at the systemd code although I'd like to think kdbus
is not systemd.  Could we do what seems correct and submit a bug
report against systemd?

I'm pretty sure it is a bug if a message with "foo" as the 3rd
argument doesn't match a filter which includes arg2=3D"foo" (2 because
0-based..), and there's not even a warning issued when you create such
a filter, or in the docs.

>
>>>
>>>
>>>> ---
>>>>    ell/dbus-message.c | 38 ++++++++++++++++++++++++++++----------
>>>>    1 file changed, 28 insertions(+), 10 deletions(-)
>>>>
>>>> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
>>>> index f223c70..a123a8a 100644
>>>> --- a/ell/dbus-message.c
>>>> +++ b/ell/dbus-message.c
>>>> @@ -1412,9 +1412,12 @@ bool _dbus_kernel_calculate_bloom(struct
>>>> l_dbus_message *message,
>>>>          const char *signature;
>>>>          void *body;
>>>>          size_t body_size;
>>>> -       struct l_dbus_message_iter iter;
>>>> +       struct l_dbus_message_iter iter, tmp;
>>>>          uint8_t argn;
>>>>          char buf[256];
>>>> +       bool (*skip_entry)(struct l_dbus_message_iter *);
>>>> +       bool (*get_basic)(struct l_dbus_message_iter *, char, void *);
>>>> +       char type;
>>>>
>>>>          /* The string "interface:" suffixed by the interface name */
>>>>          attr =3D l_dbus_message_get_interface(message);
>>>> @@ -1458,17 +1461,32 @@ bool _dbus_kernel_calculate_bloom(struct
>>>> l_dbus_message *message,
>>>>
>>>>          body =3D _dbus_message_get_body(message, &body_size);
>>>>
>>>> -       if (_dbus_message_is_gvariant(message))
>>>> -               _gvariant_iter_init(&iter, message, signature, NULL,
>>>> -                                       body, body_size);
>>>> -       else
>>>> +       if (_dbus_message_is_gvariant(message)) {
>>>> +               if (!_gvariant_iter_init(&iter, message, signature,
>>>> NULL,
>>>> +                                               body, body_size))
>>>> +                       return false;
>>>> +
>>>> +               skip_entry =3D _gvariant_iter_skip_entry;
>>>> +               get_basic =3D _gvariant_iter_next_entry_basic;
>>>> +       } else {
>>>>                  _dbus1_iter_init(&iter, message, signature, NULL,
>>>> -                               body, body_size);
>>>> +                                       body, body_size);
>>>> +
>>>> +               skip_entry =3D _dbus1_iter_skip_entry;
>>>> +               get_basic =3D _dbus1_iter_next_entry_basic;
>>>> +       }
>>>>
>>>>          argn =3D 0;
>>>>
>>>> -       while (*signature =3D=3D 's' || *signature =3D=3D 'o' || *sign=
ature =3D=3D
>>>> 'g') {
>>>> -               if (!message_iter_next_entry(&iter, &attr))
>>>> +       do {
>>>> +               type =3D l_dbus_message_iter_get_type(&iter);
>>>> +               if (!strchr("sog", type))
>>>> +                       goto next;
>>>> +
>>>> +               /* Don't let get_basic move iter->pos without moving
>>>> sig_pos */
>>>> +               memcpy(&tmp, &iter, sizeof(tmp));
>>>> +
>>>> +               if (!get_basic(&tmp, type, &attr))
>>>>                          return false;
>>>
>>>
>>>
>>> Is this to avoid double skipping this entry?  Can we find a less hacky
>>> way
>>> to do this?  Perhaps peek_basic, or restructure the loop in some way?
>>
>>
>> The problem is that get_basic moves the data position (iter->pos) but
>> doesn't move the iter->sig_pos, as fas as I can see.  Maybe instead we
>
>
> I'm pretty sure it does.  See bottom of _dbus1_iter_next_entry_basic() for
> example.  However, the signature handling is full of nasty details.  See
> below.

Ah, yes, it does.  I apparently just read up to the first switch case
and forgot there could be more code.

In that case we can just "continue" the loop and not use skip_entry.

>
>> should just do iter->sig_pos +=3D 1, similarly to what
>> message_iter_next_entry_valist does?
>
>
> It is really bad form to mess with iterator's internal data structures
> outside its core functions.

Yep.

> If you need it to do something specific, lets
> introduce an iterator method specific to your usecase.
>
> Hence my suggestion to restructure the loop or introduce new operations.

It seems there's no need for that, it was just my wrong assumption
about _dbus1_iter_next_entry_basic.

Best regards

--===============1328379389684959735==--

