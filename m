Content-Type: multipart/mixed; boundary="===============1776860987081290509=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: Fix Clang 8 "-Wstring-plus-int" warning
Date: Wed, 29 May 2019 11:17:41 -0500
Message-ID: <2d8d8b31-a7d5-480e-56b4-ef3a0ffa98ee@gmail.com>
In-Reply-To: <20190424174805.7013-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1776860987081290509==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 04/24/2019 12:48 PM, Ossama Othman wrote:
> Declare the fixed string in unit/test-checksum.c as a static array
> instead of a string literal to address a warning exhibited by Clang 8
> regarding addition of an integer to a string:
> =

> unit/test-checksum.c:170:30: warning: adding 'unsigned long' to a
>        string does not append to the string [-Wstring-plus-int]
>          iov[1].iov_base =3D FIXED_STR + FIXED_LEN / 2;
>                            ~~~~~~~~~~^~~~~~~~~~~~~~~
> unit/test-checksum.c:170:30: note: use array indexing to silence this
>        warning
>          iov[1].iov_base =3D FIXED_STR + FIXED_LEN / 2;
>                                      ^
>                            &         [              ]
> =

> Storing the string in an array makes it obvious that pointer
> arithmetic is being performed.
> ---
>   unit/test-checksum.c | 10 ++++++----
>   1 file changed, 6 insertions(+), 4 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============1776860987081290509==--

