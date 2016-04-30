Content-Type: multipart/mixed; boundary="===============3928437511075329063=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/5] dbus: Add and validate the UNIX_FDS msg header field
Date: Sat, 30 Apr 2016 16:58:29 +0200
Message-ID: <CAOq732LynqbRX=D4Vxwh2u2aAByi4UgBOxNRqjnyn8UrV8pSBQ@mail.gmail.com>
In-Reply-To: <57240744.1010904@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3928437511075329063==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 30 April 2016 at 03:15, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/29/2016 06:52 PM, Andrzej Zaborowski wrote:
>> On 30 April 2016 at 01:17, Denis Kenzior <denkenz@gmail.com> wrote:
>>>
>>> On 04/29/2016 05:44 PM, Andrew Zaborowski wrote:
>>>>
>>>> @@ -764,11 +764,22 @@ struct l_dbus_message
>>>> *dbus_message_from_blob(const
>>>> void *data, size_t size,
>>>>                  get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATUR=
E,
>>>>                                          'g', &message->signature);
>>>>
>>>> -       if (num_fds > L_ARRAY_SIZE(message->fds)) {
>>>> -               for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i+=
+)
>>>> -                       close(fds[i]);
>>>> +       if (num_fds) {
>>>> +               uint32_t unix_fds;
>>>>
>>>> -               num_fds =3D L_ARRAY_SIZE(message->fds);
>>>> +               if (!get_header_field(message,
>>>> DBUS_MESSAGE_FIELD_UNIX_FDS,
>>>> +                                       'u', &unix_fds))
>>>> +                       goto free;
>>>> +
>>>> +               if (num_fds > unix_fds)
>>>> +                       num_fds =3D unix_fds;
>>>
>>>
>>>
>>> If num_fds > unix_fds, should all unused fds (e.g. fds[unix_fds ..
>>> num_fds-1] be closed just in case as well?
>>
>>
>> Ok, let's do that.
>>
>>>
>>> Also, what if unix_fds > num_fds?
>>
>>
>> Well, not sure if there's anything we can do.  As far as I've tried to
>> understand the sendmsg/recvmsg semantics the message boundaries are
>> not preserved and I understand FDs may also be delivered in a recvmsg
>> call different than that in which the message is received when there
>> are multiple messages in the queue.  The solution would be to keep
>> buffers of header/body data another buffer with FDs received and pair
>> them based on the UNIX_FDS headers but perhaps we don't want to
>> overcomplicate it.  For simplicity I take the minimum of num_fds,
>> unix_fds and L_ARRAY_SIZE(message->fds).
>>
>
> Isn't this a transport detail?  This function in particular is taking the
> full dbus-message blob.  Same with dbus_message_build().

Yeah, we should possibly handle that in dbus.c but we'd need to use
get_header_field etc., and it would get complicated.

>
> We probably do have a separate problem inside classic_recv_message(). Sin=
ce
> the UNIX socket is a stream, the message boundaries are not preserved, as
> you point out.
>
> One way might be to use MSG_WAITALL flag.  Alternatively, allocate a buff=
er
> and keep reading into it until enough data is read.

Do you mean in case the read is interrupted by a signal?  I think
that's easy to handle but I'm not sure it can actually happen if the
dbus daemon always writes complete messages.

>
> This reminds me, since we utilize MSG_CMSG_CLOEXEC flag in recvmsg.  Do we
> still need a separate loop to set the O_CLOEXEC flag?  I suppose its safe=
 to
> keep it just in case we're running on Linux kernel less than 2.6.23.
>
> Is a similar flag implied over kdbus?

Yeah, I'd also noticed we probably didn't need this loop.  But I don't
think kdbus supports this, there's nothing in the kernel code to set
this flag.

Best regards

--===============3928437511075329063==--

