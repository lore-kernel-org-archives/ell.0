Content-Type: multipart/mixed; boundary="===============1326793669228026123=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] fswatch: Add fswatch API
Date: Fri, 20 Jul 2018 12:16:25 -0500
Message-ID: <2e29b28a-c46d-0edf-50af-6deebbdfbe4f@gmail.com>
In-Reply-To: <CAOq732L7RuTJmVJLbi7YpX80JH9ijraVviRWy=2hJAjwhwK2Eg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1326793669228026123==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> BTW I looked at the for loop in the man page and it seems it's
> actually not initialising 'event' before first use so I won't be
> following that pattern.

for (ptr =3D buf; ptr < buf + len;
	ptr +=3D sizeof(struct inotify_event) + event->len) {

	event =3D (const struct inotify_event *) ptr;

...
}

This looks fine to me?  The ptr +=3D is not executed until the end of the =

iteration.

Regards,
-Denis

--===============1326793669228026123==--

