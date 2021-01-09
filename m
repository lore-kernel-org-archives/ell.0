Content-Type: multipart/mixed; boundary="===============8700192557535233010=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 6/8] cert: Add PKCS#12 loading support
Date: Sat, 09 Jan 2021 03:46:55 +0100
Message-ID: <CAOq732LkCWY91awkfQ904+VDwtVLdNHHoXU+jwXwZZQPuzN=wA@mail.gmail.com>
In-Reply-To: <1bfbcc64-9925-4a9f-cf6f-9a24f699ac67@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8700192557535233010==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Sat, 9 Jan 2021 at 03:30, Denis Kenzior <denkenz@gmail.com> wrote:
> On 1/8/21 7:04 PM, Andrew Zaborowski wrote:
> > On Fri, 8 Jan 2021 at 05:59, Denis Kenzior <denkenz@gmail.com> wrote:
> >>> +     plaintext =3D l_malloc(encrypted_len);
> >>> +     ok =3D l_cipher_decrypt(alg, encrypted, plaintext, encrypted_le=
n);
> >>> +     l_cipher_free(alg);
> >>> +
> >>> +     if (!ok)
> >>> +             return NULL;
> >>> +
> >>
> >> is plaintext leaked here?
> >
> > l_cipher_decrypt has failed so the read() either failed or didn't happe=
n.
> >
>
> By my reading you l_malloc plaintext and never free it, no?

Oops, yes, I missed your point and didn't see it in the code either.

Best regards
--===============8700192557535233010==--

