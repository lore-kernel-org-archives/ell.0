Content-Type: multipart/mixed; boundary="===============3662242893537609393=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Added l_dbus_signal_emit
Date: Fri, 01 Feb 2019 11:39:39 -0600
Message-ID: <5e688fdb-ed07-2aa0-b9b1-1ce4749150ef@gmail.com>
In-Reply-To: <20190201134118.28458-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3662242893537609393==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 02/01/2019 07:41 AM, Micha=C5=82 'Khorne' Lowas-Rzechonek wrote:
> From: Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
> =

> After declaring a signal with l_dbus_interface_signal, we need a way to
> actually publish it.
> =

> This commit adds API for this, along with an updated example.
> ---
>   ell/dbus-service.c      | 98 +++++++++++++++++++++++++++++++++++++++++
>   ell/dbus-service.h      |  4 ++
>   examples/dbus-service.c | 12 ++++-
>   3 files changed, 112 insertions(+), 2 deletions(-)
> =


I'm confused why this is needed? You can emit a signal today by doing:

sig =3D l_dbus_message_new_signal();
l_dbus_message_set_arguments(sig, "...", ...);
l_dbus_send();

Regards,
-Denis


--===============3662242893537609393==--

