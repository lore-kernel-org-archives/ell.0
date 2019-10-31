Content-Type: multipart/mixed; boundary="===============6848814403529054847=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] genl: Add forward declaration to fix build warning
Date: Thu, 31 Oct 2019 13:07:20 -0500
Message-ID: <ed676e87-0fcd-2e89-9b49-84fea74a50a9@gmail.com>
In-Reply-To: <20191031174416.16580-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6848814403529054847==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/31/19 12:44 PM, Mat Martineau wrote:
> The l_genl_msg_append_attrv() declaration in genl.h uses struct iovec *,
> but there's no guarantee that sys/uio.h has been included (and
> the genl user might not need that header itself).
> ---
> =

> v2: Use forward declaration instead of including system header
> =

>   ell/genl.h | 2 ++
>   1 file changed, 2 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============6848814403529054847==--

