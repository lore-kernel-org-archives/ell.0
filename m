Content-Type: multipart/mixed; boundary="===============3336299535363964931=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Add message variable argument setter
Date: Wed, 08 Mar 2017 15:45:20 -0600
Message-ID: <0818566b-4c9b-2f1e-991c-19f800634bd7@gmail.com>
In-Reply-To: <20170308212045.15402-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3336299535363964931==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 03/08/2017 03:20 PM, Tim Kourt wrote:
> ---
>  ell/dbus-message.c | 17 +++++++++++++++++
>  ell/dbus.h         |  2 ++
>  2 files changed, 19 insertions(+)

<snip>

> @@ -174,6 +174,8 @@ bool l_dbus_message_iter_get_variant(struct l_dbus_me=
ssage_iter *iter,
>
>  bool l_dbus_message_set_arguments(struct l_dbus_message *message,
>  						const char *signature, ...);
> +bool l_dbus_message_set_varguments(struct l_dbus_message *message,
> +					const char *signature, va_list args);
>

ell generally uses _valist suffix for this.  e.g.
l_dbus_message_new_error_valist
l_hwdb_lookup_valist

The v prefix is only used for vprintf versions.

>  struct l_dbus_message_builder *l_dbus_message_builder_new(
>  						struct l_dbus_message *message);
>

Regards,
-Denis

--===============3336299535363964931==--

