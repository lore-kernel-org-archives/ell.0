Content-Type: multipart/mixed; boundary="===============0188425355724775343=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/11] net: Add l_net_subnet_matches
Date: Mon, 18 Apr 2022 19:01:14 +0200
Message-ID: <CAOq732JYG1Ld4OLboAvWGZZYbT=sQNB4xPTnvbzWYTJM3RXsGw@mail.gmail.com>
In-Reply-To: 04db266e-cc38-0832-b19f-d9f8c22a1c56@gmail.com

--===============0188425355724775343==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Mon, 18 Apr 2022 at 18:34, Denis Kenzior <denkenz(a)gmail.com> wrote:
> > +     return !bits ||
> > +             ((((const uint8_t *) a)[bytes] ^ ((const uint8_t *) b)[by=
tes]) &
> > +              (0xff00u >> bits)) =3D=3D 0;
>
> There were a bit too many '()' for my liking.  I moved the casts to the v=
ariable
> declaration block above which ended up being the same number of lines and=
 looked
> a bit cleaner.

Do we want to do the array[bytes] access after the !bits check to
avoid accessing the byte after the end of the address for weird cases
where the prefix_len is exactly the number of bits in the two buffers
we received.

Best regards
--===============0188425355724775343==--

