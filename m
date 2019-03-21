Content-Type: multipart/mixed; boundary="===============7410632997139296700=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] utf8: Fix expected bytes in l_utf8_get_codepoint
Date: Wed, 20 Mar 2019 20:09:00 -0500
Message-ID: <48391be5-1a49-f836-67b7-1523fd9aa34a@gmail.com>
In-Reply-To: <20190320233145.8063-2-michael.tretter@posteo.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7410632997139296700==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Michael,

On 03/20/2019 06:31 PM, Michael Tretter wrote:
> UTF-8 requires the form 10xxxxxx for the second, third and forth bytes
> of a well-formed byte sequences. Therefore, comparing with 0 is not
> sufficient to exclude ill-formed byte sequences, but the first two bit
> must follow the specified form.
> =

> Without this check, iwd crashes if it encounters Latin-1 Supplement
> encoded SSIDs during scanning, because they are erroneously accepted as
> valid UTF-8.
> ---
>   ell/utf8.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Good catch! That bug has been in there since 2011.

Both applied, thanks.

Regards,
-Denis

--===============7410632997139296700==--

