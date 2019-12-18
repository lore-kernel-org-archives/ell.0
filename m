Content-Type: multipart/mixed; boundary="===============3262737014018447331=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3] dbus: NULL check proxy on method calls
Date: Wed, 18 Dec 2019 10:25:23 -0600
Message-ID: <1c250367-89b9-66f0-4b25-5d3ff1f58cf4@gmail.com>
In-Reply-To: <20191218151235.21355-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3262737014018447331==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 12/18/19 9:12 AM, Brian Gix wrote:
> l_dbus_proxy_method_call() seg-faults when called with a NULL proxy
> pointer.  This NULL check follows the pattern of NULL checks in the
> other LIB_EXPORT methods in module.
> ---
>   ell/dbus-client.c | 3 +++
>   1 file changed, 3 insertions(+)

Applied, thanks.

Regards,
-Denis
--===============3262737014018447331==--

