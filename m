Content-Type: multipart/mixed; boundary="===============8870931743355747167=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] unit: remove kdbus
Date: Fri, 17 Mar 2017 22:33:51 -0500
Message-ID: <e59435c4-6d44-ed95-1a94-21b030659e67@gmail.com>
In-Reply-To: <20170317205914.6511-3-lrusak@libreelec.tv>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8870931743355747167==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Lukas,

On 03/17/2017 03:59 PM, Lukas Rusak wrote:
> From: Lukas Rusak <lorusak@gmail.com>
>
> ---
>  unit/test-dbus-message-fds.c |  25 ------
>  unit/test-dbus-message.c     |  30 -------
>  unit/test-dbus-properties.c  |  25 ------
>  unit/test-kdbus.c            | 200 -------------------------------------=
------
>  4 files changed, 280 deletions(-)
>  delete mode 100644 unit/test-kdbus.c
>


I went ahead and applied all 5 patches.  I did have to fix up the =

affected unit tests in commit 9105f7611653fb8ecd93587c68bf6ab203a6c202 =

since you forgot to take out a few extra lines.

Thanks!

Regards,
-Denis

--===============8870931743355747167==--

