Content-Type: multipart/mixed; boundary="===============5830728134301217218=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 1/2] settings: fix segfault if when settings has no
 group
Date: Thu, 21 Feb 2019 16:40:33 -0600
Message-ID: <92ff5312-5ecb-8e64-09f9-c1f7cee339d3@gmail.com>
In-Reply-To: <20190221223355.31790-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5830728134301217218==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 02/21/2019 04:33 PM, James Prestwood wrote:
> A settings file containing a key/value but no group caused
> l_settings_load_from_data to segfault. This was due to not checking
> that a group was actually found before parsing a key/value pair.
> =

> A new flag was added, 'has_group', which gets set after a group has
> been parsed successfully. This flag also must be true for the load
> to be successful.
> =

> Also, the return of parse_key was being checked against false, when
> it actually is returning a unsigned int. This was changed to just
> check !parse_key.
> ---
>   ell/settings.c | 13 ++++++++++---
>   1 file changed, 10 insertions(+), 3 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis


--===============5830728134301217218==--

