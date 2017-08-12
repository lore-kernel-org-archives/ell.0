Content-Type: multipart/mixed; boundary="===============0477250080624576247=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 07/10] cipher: Add l_cipher_from_pkcs5_id
Date: Fri, 11 Aug 2017 19:42:36 -0500
Message-ID: <da2ee151-1695-84c9-a7b6-51e49f00707b@gmail.com>
In-Reply-To: <CAOq732JXq1DS4_T==gF62=W+NcvPDcDi+jR87LH9jrp56K-Wmg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0477250080624576247==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> Since you want l_cipher_from_pkcs5_if private I was thinking of all of
> the implementation being in pkcs5.c since it's really all just the
> text of the PKCS#5 RFC.  But the PBKDF functions would be exported in
> pkcs5.h while the PBES function would only be declared in
> pkcs5-private.h as something potentially useless after the kernel
> implements this (unless we gain another use case for it in the
> meantime)

That sounds good to me.

Regards,
-Denis

--===============0477250080624576247==--

