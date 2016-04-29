Content-Type: multipart/mixed; boundary="===============5037953718566154877=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 08/11] dbus: Remove memcpy and fix setting of FD_CLOEXEC
 on FDs
Date: Fri, 29 Apr 2016 23:46:33 +0200
Message-ID: <CAOq732JMe5qh4YVv1u0ZMDnWkS5UPwMNE5+Ed4gy0HMJPBBxGQ@mail.gmail.com>
In-Reply-To: <572387B6.7090706@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5037953718566154877==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 29 April 2016 at 18:11, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/28/2016 10:32 PM, Andrew Zaborowski wrote:
>>
>> Make sure the size of the FD buffer passed to recvmsg is properly
>> aligned, etc. and remove the memcpy which seems unneeded.  Also it looks
>> like the fcntl() calls operated on one dbus socket FD instead of the
>> message FDs.
>> ---
>>   ell/dbus.c | 14 +++++++-------
>>   1 file changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/ell/dbus.c b/ell/dbus.c
>> index 70da849..fc0f243 100644
>> --- a/ell/dbus.c
>> +++ b/ell/dbus.c
>> @@ -638,7 +638,8 @@ static struct l_dbus_message
>> *classic_recv_message(struct l_dbus *dbus)
>>         ssize_t len;
>>         void *header, *body;
>>         size_t header_size, body_size;
>> -       int fds[16];
>> +       uint8_t fd_buf[CMSG_SPACE(16 * sizeof(int))];
>
>
> 'man cmsg' recommends doing:
>            union {
>                /* ancillary data buffer, wrapped in a union in order to
> ensure
>                   it is suitably aligned */
>                char buf[CMSG_SPACE(sizeof myfds)];
>                struct cmsghdr align;
>            } u;
>
> And it looks like systemd does the same.  This is probably what we should=
 do
> as well.

Ah yes, I didn't think about the alignment, will fix and resend.  BTW
I my unit test (last patch) also has another issue so I need to fix
that too.

Best regards

--===============5037953718566154877==--

