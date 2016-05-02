Content-Type: multipart/mixed; boundary="===============1454612086126761456=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/5] dbus: Add and validate the UNIX_FDS msg header field
Date: Tue, 03 May 2016 00:25:23 +0200
Message-ID: <CAOq732JefaOUbNfy0DLLVFK+8Oaq8cFv1=ngAb6x+sxzdXUjGA@mail.gmail.com>
In-Reply-To: <57276DE0.5070902@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1454612086126761456==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 2 May 2016 at 17:10, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/30/2016 09:58 AM, Andrzej Zaborowski wrote:
>> On 30 April 2016 at 03:15, Denis Kenzior <denkenz@gmail.com> wrote:
>>> On 04/29/2016 06:52 PM, Andrzej Zaborowski wrote:
>>>> On 30 April 2016 at 01:17, Denis Kenzior <denkenz@gmail.com> wrote:
>>>>> Also, what if unix_fds > num_fds?
>>>>
>>>> Well, not sure if there's anything we can do.  As far as I've tried to
>>>> understand the sendmsg/recvmsg semantics the message boundaries are
>>>> not preserved and I understand FDs may also be delivered in a recvmsg
>>>> call different than that in which the message is received when there
>>>> are multiple messages in the queue.  The solution would be to keep
>>>> buffers of header/body data another buffer with FDs received and pair
>>>> them based on the UNIX_FDS headers but perhaps we don't want to
>>>> overcomplicate it.  For simplicity I take the minimum of num_fds,
>>>> unix_fds and L_ARRAY_SIZE(message->fds).
>>>
>>> Isn't this a transport detail?  This function in particular is taking t=
he
>>> full dbus-message blob.  Same with dbus_message_build().
>>
>> Yeah, we should possibly handle that in dbus.c but we'd need to use
>> get_header_field etc., and it would get complicated.
>>
>
> I'm not following.  So we have dbus_message_from_blob, which takes header=
s,
> body and the fds array.  If the number of fds specified in the header (e.=
g.
> unix_fds) doesn't match what the fds[] size is, then we should take some
> action.  This is separate from the transport details inside dbus.c.

Elsewhere in the code we treat messages with too few / missing FDs as
valid and I think I commented on this in one of the commit messages,
another thing to consider is that we currently hardcode an FD limit of
16 per message and will happily generate such messages ourselves.  So
the code can handle the situation when unix_fds > num_fds and there's
nothing specific we have to do unless we decide to make it an error.

If we want to be really smart about queuing up FDs in a circular
buffer to assign to messages by unix_fds value then we would probably
want a separate function that would take a header and just return the
unix_fds value.

>
>>>
>>> We probably do have a separate problem inside classic_recv_message().
>>> Since
>>> the UNIX socket is a stream, the message boundaries are not preserved, =
as
>>> you point out.
>>>
>>> One way might be to use MSG_WAITALL flag.  Alternatively, allocate a
>>> buffer
>>> and keep reading into it until enough data is read.
>>
>>
>> Do you mean in case the read is interrupted by a signal?  I think
>> that's easy to handle but I'm not sure it can actually happen if the
>> dbus daemon always writes complete messages.
>
>
> Regardless of whether dbus-daemon writes complete messages, the kernel is
> free to return however many bytes to the process calling recvfrom, even if
> more bytes are actually available in the receive buffer. MSG_WAITALL tells
> the kernel to give us all of the data the recvfrom caller is requesting,
> unless interrupted by a signal.
>
> Without MSG_WAITALL we might start seeing partial reads on a heavily load=
ed
> system and things will start breaking.

That's the theory, i think it depends on the transport type if this
happens in practice (assuming no signal and the producer writes full
messages to the transport fd).

>
> The best way would be to peek at the next header, allocate space for the
> message and keep calling recvfrom until all of the message has been read.
> Normally this would take 1 recvfrom call, but can take as many as needed.
> Only once the entire message has been read, we can send it in for process=
ing
> by dbus_message_from_blob or dbus_message_build.  We can put this
> more-complicated scheme on the TODO list for now...

Well, I can do the code directly, I think it's going to be a small
change.  We'll need it for sendmsg too.

Best regards

--===============1454612086126761456==--

