Content-Type: multipart/mixed; boundary="===============9168850854138287178=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/2] string: Add l_utf8_get_codepoint to string
Date: Mon, 12 Dec 2016 09:49:06 -0600
Message-ID: <acb79411-ebcc-93d9-80f7-db1061304a2a@gmail.com>
In-Reply-To: <20161211182130.5799-1-ongy@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9168850854138287178==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Markus,

On 12/11/2016 12:21 PM, Markus Ongyerth wrote:
> From: Markus Ongyerth <ell@ongy.net>
>
> Add a function to get an unicode codepoint from a utf-8 string.
> This can be used to convert strings to other representations.
> Also rewrite the l_utf8_validdate to use the new function.
> ---
>  ell/string.c | 85 +++++++++++++++++++++++++++++++++++++++---------------=
------
>  ell/string.h |  2 ++
>  2 files changed, 57 insertions(+), 30 deletions(-)
>

Both applied, thanks.

Regards,
-Denis


--===============9168850854138287178==--

