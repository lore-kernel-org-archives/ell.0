Content-Type: multipart/mixed; boundary="===============2390972017761244939=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] dbus: Add and validate the UNIX_FDS msg header field
Date: Mon, 02 May 2016 10:10:24 -0500
Message-ID: <57276DE0.5070902@gmail.com>
In-Reply-To: <CAOq732LynqbRX=D4Vxwh2u2aAByi4UgBOxNRqjnyn8UrV8pSBQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2390972017761244939==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/30/2016 09:58 AM, Andrzej Zaborowski wrote:
> On 30 April 2016 at 03:15, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 04/29/2016 06:52 PM, Andrzej Zaborowski wrote:
>>> On 30 April 2016 at 01:17, Denis Kenzior <denkenz@gmail.com> wrote:
>>>>
>>>> On 04/29/2016 05:44 PM, Andrew Zaborowski wrote:
>>>>>
>>>>> @@ -764,11 +764,22 @@ struct l_dbus_message
>>>>> *dbus_message_from_blob(const
>>>>> void *data, size_t size,
>>>>>                   get_header_field(message, DBUS_MESSAGE_FIELD_SIGNAT=
URE,
>>>>>                                           'g', &message->signature);
>>>>>
>>>>> -       if (num_fds > L_ARRAY_SIZE(message->fds)) {
>>>>> -               for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i=
++)
>>>>> -                       close(fds[i]);
>>>>> +       if (num_fds) {
>>>>> +               uint32_t unix_fds;
>>>>>
>>>>> -               num_fds =3D L_ARRAY_SIZE(message->fds);
>>>>> +               if (!get_header_field(message,
>>>>> DBUS_MESSAGE_FIELD_UNIX_FDS,
>>>>> +                                       'u', &unix_fds))
>>>>> +                       goto free;
>>>>> +
>>>>> +               if (num_fds > unix_fds)
>>>>> +                       num_fds =3D unix_fds;
>>>>
>>>>
>>>>
>>>> If num_fds > unix_fds, should all unused fds (e.g. fds[unix_fds ..
>>>> num_fds-1] be closed just in case as well?
>>>
>>>
>>> Ok, let's do that.
>>>
>>>>
>>>> Also, what if unix_fds > num_fds?
>>>
>>>
>>> Well, not sure if there's anything we can do.  As far as I've tried to
>>> understand the sendmsg/recvmsg semantics the message boundaries are
>>> not preserved and I understand FDs may also be delivered in a recvmsg
>>> call different than that in which the message is received when there
>>> are multiple messages in the queue.  The solution would be to keep
>>> buffers of header/body data another buffer with FDs received and pair
>>> them based on the UNIX_FDS headers but perhaps we don't want to
>>> overcomplicate it.  For simplicity I take the minimum of num_fds,
>>> unix_fds and L_ARRAY_SIZE(message->fds).
>>>
>>
>> Isn't this a transport detail?  This function in particular is taking the
>> full dbus-message blob.  Same with dbus_message_build().
>
> Yeah, we should possibly handle that in dbus.c but we'd need to use
> get_header_field etc., and it would get complicated.
>

I'm not following.  So we have dbus_message_from_blob, which takes =

headers, body and the fds array.  If the number of fds specified in the =

header (e.g. unix_fds) doesn't match what the fds[] size is, then we =

should take some action.  This is separate from the transport details =

inside dbus.c.

>>
>> We probably do have a separate problem inside classic_recv_message(). Si=
nce
>> the UNIX socket is a stream, the message boundaries are not preserved, as
>> you point out.
>>
>> One way might be to use MSG_WAITALL flag.  Alternatively, allocate a buf=
fer
>> and keep reading into it until enough data is read.
>
> Do you mean in case the read is interrupted by a signal?  I think
> that's easy to handle but I'm not sure it can actually happen if the
> dbus daemon always writes complete messages.

Regardless of whether dbus-daemon writes complete messages, the kernel =

is free to return however many bytes to the process calling recvfrom, =

even if more bytes are actually available in the receive buffer. =

MSG_WAITALL tells the kernel to give us all of the data the recvfrom =

caller is requesting, unless interrupted by a signal.

Without MSG_WAITALL we might start seeing partial reads on a heavily =

loaded system and things will start breaking.

The best way would be to peek at the next header, allocate space for the =

message and keep calling recvfrom until all of the message has been =

read.  Normally this would take 1 recvfrom call, but can take as many as =

needed.  Only once the entire message has been read, we can send it in =

for processing by dbus_message_from_blob or dbus_message_build.  We can =

put this more-complicated scheme on the TODO list for now...

>
>>
>> This reminds me, since we utilize MSG_CMSG_CLOEXEC flag in recvmsg.  Do =
we
>> still need a separate loop to set the O_CLOEXEC flag?  I suppose its saf=
e to
>> keep it just in case we're running on Linux kernel less than 2.6.23.
>>
>> Is a similar flag implied over kdbus?
>
> Yeah, I'd also noticed we probably didn't need this loop.  But I don't
> think kdbus supports this, there's nothing in the kernel code to set
> this flag.
>

Okay, lets leave it.

Regards,
-Denis

--===============2390972017761244939==--

