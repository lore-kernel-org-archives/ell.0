Content-Type: multipart/mixed; boundary="===============8374501410628282871=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] dbus: NULL check proxy on method calls
Date: Tue, 17 Dec 2019 17:38:25 -0600
Message-ID: <1200cabb-6e24-2cdf-aa9a-2e9b0b50e4a9@gmail.com>
In-Reply-To: <20191217172753.3899-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8374501410628282871==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 12/17/19 11:27 AM, Brian Gix wrote:
> l_dbus_proxy_method_call() seg-faults when called with a NULL proxy
> pointer.  This NULL check follows the pattern of NULL checks in the
> other LIB_EXPORT methods in module.
> ---
>   ell/dbus-client.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
> =


Good catch...

> diff --git a/ell/dbus-client.c b/ell/dbus-client.c
> index 541f3e8..f735f33 100644
> --- a/ell/dbus-client.c
> +++ b/ell/dbus-client.c
> @@ -301,6 +301,9 @@ LIB_EXPORT uint32_t l_dbus_proxy_method_call(struct l=
_dbus_proxy *proxy,
>   {
>   	struct method_call_request *req;
>   =

> +	if (unlikely(!proxy))
> +		return 0;
> +
>   	req =3D l_new(struct method_call_request, 1);
>   	req->proxy =3D proxy;
>   	req->setup =3D setup;
> @@ -648,8 +651,8 @@ LIB_EXPORT void l_dbus_client_destroy(struct l_dbus_c=
lient *client)
>   		client->proxy_cb_data_destroy(client->proxy_cb_data);
>   =

>   	if (client->objects_call)
> -		l_dbus_cancel(client->dbus, client->objects_call)
> -;
> +		l_dbus_cancel(client->dbus, client->objects_call);
> +

... but this part belongs in a separate commit.

>   	l_queue_destroy(client->proxies,
>   				(l_queue_destroy_func_t)dbus_proxy_destroy);
>   =

> =


Regards,
-Denis
--===============8374501410628282871==--

