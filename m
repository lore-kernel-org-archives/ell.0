Content-Type: multipart/mixed; boundary="===============9100717641281217751=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/3] tls: change APIs to use l_cert/l_certchain/l_key
Date: Wed, 02 Oct 2019 10:07:59 -0500
Message-ID: <1b227152-5645-5a46-9058-223ca5ca2192@gmail.com>
In-Reply-To: <20191001213140.2163-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9100717641281217751==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/1/19 4:31 PM, James Prestwood wrote:
> l_tls_set_auth_data/l_tls_set_cacert both expected file paths to be
> passed in, and the certs/keys would be loaded internally. This prevents
> the caller from loading certs any way but from files. This makes
> loading certs/keys from data impossible if using TLS. For example,
> a certificate may be embedded inside a file which has additional data.
> =

> To handle both file/data cases its now up to the caller to load the
> cert/key as an l_cert/l_certchain/l_key/l_queue and pass that structure
> in directly.
> =

> The structure being passed in will now be owned by l_tls, and will be
> freed on l_tls_free.
> ---
>   ell/tls.c | 42 +++++++++++-------------------------------
>   ell/tls.h | 27 +++++++++++++++------------
>   2 files changed, 26 insertions(+), 43 deletions(-)
> =

> -v2:
>   * Updated API comments
>   * Removed debug prints
> =


Patches 1 & 3 applied, thanks.

Regards,
-Denis

--===============9100717641281217751==--

