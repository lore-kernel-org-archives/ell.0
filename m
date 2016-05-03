Content-Type: multipart/mixed; boundary="===============5285802697573392253=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] dbus: Add and validate the UNIX_FDS msg header field
Date: Mon, 02 May 2016 22:17:13 -0500
Message-ID: <57281839.3040609@gmail.com>
In-Reply-To: <CAOq732JefaOUbNfy0DLLVFK+8Oaq8cFv1=ngAb6x+sxzdXUjGA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5285802697573392253==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 > Elsewhere in the code we treat messages with too few / missing FDs as
> valid and I think I commented on this in one of the commit messages,

git show 439e259835d8b2788ca28c1dbe06badbd178dccf

This one only deals with num_fds > L_ARRAY_SIZE(message->fds), which =

makes sense.

git show 1e1aa1aa63be7b50a4d35aa01d14c001bf591fd1

Also sort of makes sense...

> another thing to consider is that we currently hardcode an FD limit of
> 16 per message and will happily generate such messages ourselves.  So
> the code can handle the situation when unix_fds > num_fds and there's
> nothing specific we have to do unless we decide to make it an error.

Which I think we should by the way.  If the message tells us we have 3 =

fds, and we only receive 1 or 0, then that should be fatal.  It would =

most likely indicate an error in our transport code logic.  I'd actually =

like to make this verbose and see if this ever happens.  AFAIK, =

dbus-daemon does not allow this.

Since kdbus uses message_from_blob and dbus-1 uses message_build, do you =

want to have different constraints between those two?

>
> If we want to be really smart about queuing up FDs in a circular
> buffer to assign to messages by unix_fds value then we would probably
> want a separate function that would take a header and just return the
> unix_fds value.

I was hoping we could avoid that via use of MSG_WAITALL.  I suspect =

you're right and we need to.

Regards,
-Denis

--===============5285802697573392253==--

