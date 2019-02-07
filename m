Content-Type: multipart/mixed; boundary="===============7533934019942550956=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] ecc: fix potential buffer overrun
Date: Thu, 07 Feb 2019 12:15:46 -0600
Message-ID: <b5383aeb-7c08-ca91-28fd-a47f2b2b4a51@gmail.com>
In-Reply-To: <20190207181458.29466-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7533934019942550956==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 02/07/2019 12:14 PM, James Prestwood wrote:
> l_ecc_curve_get_[tls|ike]_group were iterating over curves and assuming
> a NULL terminated list which was not the case. This never got caught
> because IWD played nice and only got groups it already new existed.
> =

> This was changed to iterate over L_ARRAY_SIZE(curves).
> ---
>   ell/ecc.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============7533934019942550956==--

