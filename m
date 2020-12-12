Content-Type: multipart/mixed; boundary="===============3047086608368987260=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 06/13] pkcs5: Add the PKCS#12 KDF
Date: Sat, 12 Dec 2020 01:06:42 +0100
Message-ID: <CAOq732KKq4fYh4rsPJnefoq6qHR3Rdnput7kH4=95R+5GiexDg@mail.gmail.com>
In-Reply-To: <481d483e-22b3-9604-40c4-4cbc58a2ba2c@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3047086608368987260==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 11 Dec 2020 at 16:50, Denis Kenzior <denkenz@gmail.com> wrote:
> >> So is this just a UCS2BE conversion?  If so, then using l_utf8_to_ucs2=
be might
> >> be clearer.
> >
> > Basically yes.  But with l_utf8_to_ucs2be this will look something like:
> >
> >    uint8_t *usc2;
> >
> >    if (!l_utf8_validate(utf))
> >      return false;
>
> You'll potentially need this step in either version actually.
> utf8_get_codepoint isn't really enough to tell whether the entire string =
is
> valid utf8.

Right, but as long as we don't crash and we can decrypt the contents,
we don't care.  And since I was first using strlen() and then passing
the remaining byte count to l_utf8_get_codepoint() it shouldn't crash.

>  Where is the password coming from?

Currently from the l_settings or the agent, so on second thought we
can require that the password parameter to l_pem_load_container_file
is valid UTF-8 and skip l_utf8_validate().

>
> Also, I would think you'd pre-validate utf8 validity before ever getting =
to this
> point?
>
> >
> >    ucs2 =3D l_utf8_to_ucs2be(utf, out_len);
> >    if (!str)
> >      return false;
> >
> >    memcpy(out_buf, ucs2, *out_len);
> >    explicit_bzero(ucs2);
> >    l_free(ucs2);
> >
> > I can do that but it seems we're doing less work without using
> > l_utf8_to_ucs2be here.
>
> You could add an own buffer version of utf8_to_ucs2be.  But even this mem=
cpy
> version seems to be cleaner than open-coding it.

Ok, let's use l_utf8_to_ucs2be then.

Best regards
--===============3047086608368987260==--

