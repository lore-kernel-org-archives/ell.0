Content-Type: multipart/mixed; boundary="===============1966286560534496901=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dbus-service: Do not auto-emit property changes
Date: Wed, 29 Jan 2020 10:53:01 -0600
Message-ID: <94f11a42-7730-31ad-e112-455ab42bf9d4@gmail.com>
In-Reply-To: <20200128201348.28916-1-denkenz@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1966286560534496901==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

On 1/28/20 2:13 PM, Denis Kenzior wrote:
> This is a behavioral change to not emit property changes by default
> after the set callback 'complete' method is called.  This allows
> applications a bit more flexibility in if & when they actually emit the
> property changed signal.  Two common scenarios are:
> =

> 	- The property is set to value 'A' and a D-Bus client requests
> 	the property to be set to 'A'.  Generally most D-Bus
> 	applications would want to silently accept such a request and
> 	not emit a PropertyChanged signal needlessly.  With ell's
> 	current behavior the signal is emitted regardless.
> 	- A property 'set' might be set successfully, but its actual
> 	value is updated via some asynchronous means (perhaps inotify,
> 	netlink, etc).  So it would be advantageous for applications to
> 	call the 'complete' callback and have the property changed
> 	signal be emitted when the relevant async notification arrives.
> =

> The implications of this behavior change is that property setter
> implementations must manually invoke l_dbus_property_changed whenever
> the underlying property value has been updated in order for the relevant
> signal to be emitted.  Alternatively, supplying
> L_DBUS_PROPERTY_FLAG_AUTO_EMIT flag in l_dbus_interface_property() will
> preserve the current behavior.
> ---
>   ell/dbus-service.c | 43 +++++++++++++++++++++++++++++++++++--------
>   ell/dbus-service.h |  1 +
>   2 files changed, 36 insertions(+), 8 deletions(-)
> =


Both applied

Regards,
-Denis
--===============1966286560534496901==--

