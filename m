Content-Type: multipart/mixed; boundary="===============3174644694429521354=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] dbus: Add and validate the UNIX_FDS msg header field
Date: Fri, 29 Apr 2016 20:15:48 -0500
Message-ID: <57240744.1010904@gmail.com>
In-Reply-To: <CAOq732+e0Ugrfw5oeYAcXmAPa0FBd5AxFSs93aG1BL5vs2HQyQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3174644694429521354==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/29/2016 06:52 PM, Andrzej Zaborowski wrote:
> On 30 April 2016 at 01:17, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 04/29/2016 05:44 PM, Andrew Zaborowski wrote:
>>> @@ -764,11 +764,22 @@ struct l_dbus_message *dbus_message_from_blob(con=
st
>>> void *data, size_t size,
>>>                  get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
>>>                                          'g', &message->signature);
>>>
>>> -       if (num_fds > L_ARRAY_SIZE(message->fds)) {
>>> -               for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
>>> -                       close(fds[i]);
>>> +       if (num_fds) {
>>> +               uint32_t unix_fds;
>>>
>>> -               num_fds =3D L_ARRAY_SIZE(message->fds);
>>> +               if (!get_header_field(message,
>>> DBUS_MESSAGE_FIELD_UNIX_FDS,
>>> +                                       'u', &unix_fds))
>>> +                       goto free;
>>> +
>>> +               if (num_fds > unix_fds)
>>> +                       num_fds =3D unix_fds;
>>
>>
>> If num_fds > unix_fds, should all unused fds (e.g. fds[unix_fds ..
>> num_fds-1] be closed just in case as well?
>
> Ok, let's do that.
>
>>
>> Also, what if unix_fds > num_fds?
>
> Well, not sure if there's anything we can do.  As far as I've tried to
> understand the sendmsg/recvmsg semantics the message boundaries are
> not preserved and I understand FDs may also be delivered in a recvmsg
> call different than that in which the message is received when there
> are multiple messages in the queue.  The solution would be to keep
> buffers of header/body data another buffer with FDs received and pair
> them based on the UNIX_FDS headers but perhaps we don't want to
> overcomplicate it.  For simplicity I take the minimum of num_fds,
> unix_fds and L_ARRAY_SIZE(message->fds).
>

Isn't this a transport detail?  This function in particular is taking =

the full dbus-message blob.  Same with dbus_message_build().

We probably do have a separate problem inside classic_recv_message(). =

Since the UNIX socket is a stream, the message boundaries are not =

preserved, as you point out.

One way might be to use MSG_WAITALL flag.  Alternatively, allocate a =

buffer and keep reading into it until enough data is read.

This reminds me, since we utilize MSG_CMSG_CLOEXEC flag in recvmsg.  Do =

we still need a separate loop to set the O_CLOEXEC flag?  I suppose its =

safe to keep it just in case we're running on Linux kernel less than 2.6.23.

Is a similar flag implied over kdbus?

> Best regards
>

Regards,
-Denis

--===============3174644694429521354==--

