Content-Type: multipart/mixed; boundary="===============6257214648714126325=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Fix l_dbus_client_set_proxy_handlers user data
Date: Tue, 27 Feb 2018 11:19:05 -0600
Message-ID: <7d939d66-8c67-64e7-b3ab-3764e63ab83e@gmail.com>
In-Reply-To: <20180227134319.1657-1-ckt@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6257214648714126325==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Claudio,

On 02/27/2018 07:43 AM, Claudio Takahasi wrote:
> Proxy property changed callback is passing wrong argument. The argument
> should be user data instead of destroy function.
> ---
>   ell/dbus-client.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Hah, good spot.  Applied, thanks.

And good to see you are still around :)

Regards,
-Denis

--===============6257214648714126325==--

