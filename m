Content-Type: multipart/mixed; boundary="===============4580992533152452858=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] genl: Return false, not NULL, for boolean return.
Date: Fri, 12 Mar 2021 13:32:17 -0600
Message-ID: <24a9f412-6552-7862-022e-5e691cf9b881@gmail.com>
In-Reply-To: <20210312190416.183218-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4580992533152452858==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 3/12/21 1:04 PM, Ossama Othman wrote:
> From: Ossama Othman <ossama.othman@gmail.com>
> =

> The return type of the l_genl_request_family() function is bool, not a
> pointer.  Return false instead of NULL to match the return type.
> ---
>   ell/genl.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============4580992533152452858==--

