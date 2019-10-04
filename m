Content-Type: multipart/mixed; boundary="===============0134235636682450608=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v10 1/4] pem: make endp setting smarter
Date: Fri, 04 Oct 2019 16:59:08 -0500
Message-ID: <f372c79c-45c9-06b3-2cd9-add1530021ce@gmail.com>
In-Reply-To: <20191004195111.8751-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0134235636682450608==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/4/19 2:51 PM, James Prestwood wrote:
> Always doing eol + 1 could result in endp pointing past the bounds
> of the PEM if the PEM does not have a final newline. Now we check
> that we aren't going past the bounds of the buffer before setting
> endp, and if we are just set endp to eol.
> ---
>   ell/pem.c | 8 ++++++--
>   1 file changed, 6 insertions(+), 2 deletions(-)
> =


All applied, thanks.

Regards,
-Denis

--===============0134235636682450608==--

