Content-Type: multipart/mixed; boundary="===============9139300868762789611=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/5] dbus: Add and validate the UNIX_FDS msg header field
Date: Sat, 30 Apr 2016 01:52:01 +0200
Message-ID: <CAOq732+e0Ugrfw5oeYAcXmAPa0FBd5AxFSs93aG1BL5vs2HQyQ@mail.gmail.com>
In-Reply-To: <5723EB91.7050600@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9139300868762789611==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 30 April 2016 at 01:17, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/29/2016 05:44 PM, Andrew Zaborowski wrote:
>> @@ -764,11 +764,22 @@ struct l_dbus_message *dbus_message_from_blob(const
>> void *data, size_t size,
>>                 get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE,
>>                                         'g', &message->signature);
>>
>> -       if (num_fds > L_ARRAY_SIZE(message->fds)) {
>> -               for (i =3D L_ARRAY_SIZE(message->fds); i < num_fds; i++)
>> -                       close(fds[i]);
>> +       if (num_fds) {
>> +               uint32_t unix_fds;
>>
>> -               num_fds =3D L_ARRAY_SIZE(message->fds);
>> +               if (!get_header_field(message,
>> DBUS_MESSAGE_FIELD_UNIX_FDS,
>> +                                       'u', &unix_fds))
>> +                       goto free;
>> +
>> +               if (num_fds > unix_fds)
>> +                       num_fds =3D unix_fds;
>
>
> If num_fds > unix_fds, should all unused fds (e.g. fds[unix_fds ..
> num_fds-1] be closed just in case as well?

Ok, let's do that.

>
> Also, what if unix_fds > num_fds?

Well, not sure if there's anything we can do.  As far as I've tried to
understand the sendmsg/recvmsg semantics the message boundaries are
not preserved and I understand FDs may also be delivered in a recvmsg
call different than that in which the message is received when there
are multiple messages in the queue.  The solution would be to keep
buffers of header/body data another buffer with FDs received and pair
them based on the UNIX_FDS headers but perhaps we don't want to
overcomplicate it.  For simplicity I take the minimum of num_fds,
unix_fds and L_ARRAY_SIZE(message->fds).

Best regards

--===============9139300868762789611==--

