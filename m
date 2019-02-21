Content-Type: multipart/mixed; boundary="===============7105844568086040141=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] settings: fix segfault if when settings has no group
Date: Thu, 21 Feb 2019 14:12:03 -0600
Message-ID: <dd7263d5-0e8b-6e41-8761-2da24e2455ad@gmail.com>
In-Reply-To: <20190221182216.29956-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7105844568086040141==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 02/21/2019 12:22 PM, James Prestwood wrote:
> A settings file containing a key/value but no group caused
> l_settings_load_from_data to segfault. This was due to both parse_key
> and parse_value not checking that the group was non-NULL.

Whoops :)

I think it might be more clear to fix this in =

l_settings_load_from_data() to not call parse_keyvalue if no group has =

been encountered previously.

> =

> Also, the return of parse_key was being checked against false, when
> it actually is returning a unsigned int. This was changed to just
> check !parse_key.
> ---
>   ell/settings.c | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)
> =


Regards,
-Denis

--===============7105844568086040141==--

