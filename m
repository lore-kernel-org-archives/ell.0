Content-Type: multipart/mixed; boundary="===============0543746871203344945=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] genl: Include <stddef.h> for size_t typedef.
Date: Wed, 06 Jun 2018 19:36:33 -0500
Message-ID: <2b86c2ef-3a48-f2c1-5b86-1d7233e931a2@gmail.com>
In-Reply-To: <20180606223423.30240-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0543746871203344945==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 06/06/2018 05:34 PM, Ossama Othman wrote:
> The l_genl_msg_append_attrv() prototype in the ELL genl.h header uses
> the size_t typedef.  Explicitly include <stddef.h> to pull in the
> size_t typedef declaration in case the user directly includes
> <ell/genl.h> without, or prior to, other headers that would have done
> the same.  This addresses an "unknown type name" compile-time error in
> such a case.
> ---
>   ell/genl.h | 1 +
>   1 file changed, 1 insertion(+)

Applied, thanks.

Regards,
-Denis


--===============0543746871203344945==--

