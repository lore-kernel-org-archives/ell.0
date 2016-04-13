Content-Type: multipart/mixed; boundary="===============7383869164302353211=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Tue, 12 Apr 2016 19:14:26 -0500
Message-ID: <570D8F62.1080106@gmail.com>
In-Reply-To: <CAOq732JMGVZ2MV=araQ=zxU2YcrQKhGKZm_5CDDUa3Z5=1OpCw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7383869164302353211==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 > But we'll still need a memcpy, unless we use a separate io vector when
> sending the message to the kdbus FD, but I'd have to check if it
> doesn't break the splitting rules.
>

So one thought here would be to add extra space in the beginning of the =

body used by gvariant builder.  That way we can fill it with the variant =

contents when we finalize the builder.  We might need to keep an extra =

book-keeping variable, something like body_offset, to know where the =

body actually begins.  It will be always 0 for dbus-1.

Perhaps you can think of something better.

Regards,
-Denis

--===============7383869164302353211==--

