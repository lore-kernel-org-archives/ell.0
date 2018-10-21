Content-Type: multipart/mixed; boundary="===============3341671429576617459=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] ell/dir.c: include limits.h for NAME_MAX
Date: Sun, 21 Oct 2018 10:24:11 +0200
Message-ID: <6E88A287-09CE-4654-8F00-C44D5F6CBDF2@holtmann.org>
In-Reply-To: <20181020210129.27142-1-thinkabit.ukim@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3341671429576617459==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi William,

> fixes compilation on musl libc systems that are stricter
> =

> the error:
> =

> ell/dir.c: In function 'inotify_read_cb':
> ell/dir.c:176:45: error: 'NAME_MAX' undeclared (first use in this functio=
n); did you mean 'SIZE_MAX'?
>  uint8_t buf[sizeof(struct inotify_event) + NAME_MAX + 1]
>                                             ^~~~~~~~
>                                             SIZE_MAX
> ell/dir.c:176:45: note: each undeclared identifier is reported only once =
for each function it appears in
> =

> Signed-off-by: William Maxwell <thinkabit.ukim@gmail.com>
> ---
> ell/dir.c | 1 +
> 1 file changed, 1 insertion(+)

a slightly modified patch has been applied.

Regards

Marcel


--===============3341671429576617459==--

