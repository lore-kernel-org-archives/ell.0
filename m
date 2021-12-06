Content-Type: multipart/mixed; boundary="===============5668387938214613227=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] genl: add l_genl_family_request_sent
Date: Mon, 06 Dec 2021 13:49:22 -0600
Message-ID: <a25e31cb-c2aa-dd83-bf90-e845457b55c2@gmail.com>
In-Reply-To: 20211206181745.1161158-1-prestwoj@gmail.com

--===============5668387938214613227==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 12/6/21 12:17 PM, James Prestwood wrote:
> Returns true if a request has been sent to genl. This is useful
> for knowning if a l_genl_family_cancel call will have any effect
> besides NULLing out the callback.
> ---
>   ell/ell.sym |  1 +
>   ell/genl.c  | 16 ++++++++++++++++
>   ell/genl.h  |  1 +
>   3 files changed, 18 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============5668387938214613227==--

