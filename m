Content-Type: multipart/mixed; boundary="===============3851919987225498872=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: [PATCH] cipher: add AES-CMAC hashing support
Date: Wed, 29 May 2019 03:25:04 +0000
Message-ID: <1559100302.25030.14.camel@intel.com>
In-Reply-To: <AD071452-7D69-4328-9464-651E0C029DA6@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3851919987225498872==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

It does work, Thanks.

I will probably do one patch anyway, to add a couple tests to test-checksum=
.c, because currently a unit test
for l_checksum_new_cmac_aes() is conspicuous in it's absence.


On Wed, 2019-05-29 at 03:04 +0000, Gix, Brian wrote:
> Hi Denis,
> =

> > On May 28, 2019, at 6:32 PM, Denis Kenzior <denkenz@gmail.com> wrote:
> > =

> > Hi Brian,
> > =

> > > On 05/28/2019 07:49 PM, Brian Gix wrote:
> > > The algorythm is supported in the kernel, and it is used heavily by
> > > Bluetooth Mesh, and is the one Mesh required algorythm missing from E=
LL.
> > > ---
> > >  ell/cipher.c       | 88 ++++++++++++++++++++++++++++++++++++++++++++=
++++++++++
> > >  ell/cipher.h       | 16 ++++++++++
> > >  unit/test-cipher.c | 74 +++++++++++++++++++++++++++++++++++++++++++++
> > >  3 files changed, 178 insertions(+)
> > =

> > Please be aware of our patch submission guidelines found in HACKING. E.=
g. the unit test should be in a
> > separate commit.
> > =

> > Have you checked whether l_checksum_new_cmac_aes() satisfies your needs?
> =

> I didn=E2=80=99t see that. I will check it out, and if it works, I will w=
ithdraw my patch altogether. If it does not
> work, I will resubmit as a patch-set.
> =

> > =

> > Regards,
> > -Denis
> =

> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell
--===============3851919987225498872==--

