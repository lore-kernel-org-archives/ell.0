Content-Type: multipart/mixed; boundary="===============5085471626962306266=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] rtnl: Add l_rtnl_address_dup
Date: Tue, 01 Jun 2021 09:48:36 -0500
Message-ID: <eec98c9f-f141-0c0c-5cf0-2c8b0f0540d7@gmail.com>
In-Reply-To: <20210529000319.2897056-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5085471626962306266==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/28/21 7:03 PM, Andrew Zaborowski wrote:
> Returns a new l_rtnl_address that is a copy of the one passed in
> parameter.
> ---
>   ell/rtnl.c | 6 ++++++
>   ell/rtnl.h | 1 +
>   2 files changed, 7 insertions(+)
> =


I named this l_rtnl_address_clone to be consistent with some other APIs we =
have =

and added ell.sym entry.  Applied, thanks.

Regards,
-Denis
--===============5085471626962306266==--

