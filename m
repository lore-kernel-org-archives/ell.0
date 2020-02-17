Content-Type: multipart/mixed; boundary="===============2821742535013250559=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] genl: Update genl refcount when creating/freeing a
 family
Date: Mon, 17 Feb 2020 10:32:52 -0600
Message-ID: <17a9c184-b9ac-7e6f-ae34-6f094f81c91e@gmail.com>
In-Reply-To: <20200214233732.20146-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2821742535013250559==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 2/14/20 5:37 PM, Andrew Zaborowski wrote:
> Since struct l_genl is already refcounted we can hold references to the
> l_genl object in an l_genl_family to allow the user to free them in
> arbitrary order.
> ---
>   ell/genl.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
> =


All applied, thanks.

Regards,
-Denis

--===============2821742535013250559==--

