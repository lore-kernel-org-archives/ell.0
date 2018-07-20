Content-Type: multipart/mixed; boundary="===============1114010098520291509=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/2] fswatch: Add fswatch API
Date: Fri, 20 Jul 2018 19:37:57 +0200
Message-ID: <CAOq732+7cQKBpYh9pFLne=WBwnJUBky9kJBYsofHiGsoq1xGMw@mail.gmail.com>
In-Reply-To: <2e29b28a-c46d-0edf-50af-6deebbdfbe4f@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1114010098520291509==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 20 July 2018 at 19:16, Denis Kenzior <denkenz@gmail.com> wrote:
>> BTW I looked at the for loop in the man page and it seems it's
>> actually not initialising 'event' before first use so I won't be
>> following that pattern.
>
>
> for (ptr =3D buf; ptr < buf + len;
>         ptr +=3D sizeof(struct inotify_event) + event->len) {
>
>         event =3D (const struct inotify_event *) ptr;
>
> ...
> }
>
> This looks fine to me?  The ptr +=3D is not executed until the end of the
> iteration.

Oh true, it doesn't do the length check before initial iteration.  I
thought it's better to have a sanity check.

The loop is wrong though and would cause valgrind to complain because
after your last iteration ptr equals buf + len, so 'event' also points
at the end of buf and event->len is beyond the end of your buffer.

Cheers

--===============1114010098520291509==--

