Content-Type: multipart/mixed; boundary="===============8138124466236156830=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/8] dbus: l_dbus_name_acquire public API and driver
 declarations
Date: Thu, 24 Mar 2016 22:03:59 -0500
Message-ID: <56F4AA9F.2040600@gmail.com>
In-Reply-To: <1458785229-23266-4-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8138124466236156830==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/23/2016 09:07 PM, Andrew Zaborowski wrote:
> ---
>   ell/dbus.c | 33 +++++++++++++++++++++++++++++++++
>   ell/dbus.h |  8 ++++++++
>   2 files changed, 41 insertions(+)

<snip>

>
> +
> +/**
> + * l_dbus_name_acquire:
> + * @dbus: D-Bus connection
> + * @name: Well-known bus name to be acquired
> + * @allow_replacement: Whether to allow another peer's name request to
> + *                     take the name ownership away from this connection
> + * @replace_existing: Whether to allow D-Bus to take the name's ownership
> + *                    away from another peer in case the name is already
> + *                    owned and allows replacement.  Ignored if name is
> + *                    currently free.
> + * @queue: Whether to allow the name request to be queued by D-Bus in
> + *         case it cannot be acquired now, rather than to return a failu=
re.
> + * @callback: Callback to receive the request result when done.
> + *
> + * Acquire a well-known bus name (service name) on the bus.
> + *
> + * Returns: a non-zero request serial that can be passed to l_dbus_cancel
> + *          while waiting for the callback, or zero on failure.

Yet kdbus version returns some hard-coded number that can't be used by =

l_dbus_cancel.  I don't like this API asymmetry.  Can't we just return =

void and let the callback parameters tell the application what happened?

Regards,
-Denis

--===============8138124466236156830==--

