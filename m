Content-Type: multipart/mixed; boundary="===============3110595589623083527=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit/test-dbus: pick up dbus-daemon from $PATH
Date: Wed, 30 Dec 2020 12:02:14 -0600
Message-ID: <708d318e-9d36-bbd0-df4f-a0d97293218e@gmail.com>
In-Reply-To: <20201227121620.30667-1-flokli@flokli.de>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3110595589623083527==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Florian,

On 12/27/20 6:16 AM, Florian Klink wrote:
> This allows running the unit tests in environments where `dbus-daemon`
> isn't in /usr/bin, but in $PATH.
> =

> Signed-off-by: Florian Klink <flokli@flokli.de>

We don't use SoB tags, so I took this out...

> ---
>   unit/test-dbus-message-fds.c | 4 ++--
>   unit/test-dbus-properties.c  | 4 ++--
>   unit/test-dbus.c             | 4 ++--
>   3 files changed, 6 insertions(+), 6 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============3110595589623083527==--

