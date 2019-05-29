Content-Type: multipart/mixed; boundary="===============2931727072478298325=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: [PATCH] cipher: add AES-CMAC hashing support
Date: Wed, 29 May 2019 20:07:12 +0000
Message-ID: <1559160429.3694.23.camel@intel.com>
In-Reply-To: <20190529192627.j32awzp3rq7u5t3p@kynes>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2931727072478298325==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Michal,


On Wed, 2019-05-29 at 21:26 +0200, michal.lowas-rzechonek(a)silvair.com wro=
te:
> Hi Brian, Denis,
> =

> On 05/29, Gix, Brian wrote:
> > > Is this about mesh_crypto_aes_ccm_encrypt and
> > > mesh_crypto_aes_ccm_decrypt functions in mesh/crypto.c?
> > =

> > The code you copy pasted below *is* the usage of AES_CCM that we use in=
 mesh,
> =

> Um, it's not - mesh_crypto_aes_ccm_* functions seem to implement AES_CCM
> on top of ECB, in user space. As Denis mentioned, this is somewhat
> inefficient, but at least it works on older kernels.

Yes, I understand now...  You wrote the code snippet, that looked an awful =
lot like the patch I was in the
middle of writing for mesh_crypto_aes_ccm_*....

my best guess right now is that we will probably decide to go ahead and pat=
ch mesh such that it assumes an up-
to-date kernel version, and a working underlying architecture.

It will then be the responsibility of the vendor (you guys) to patch mesh s=
uch that it continues to work on
your older kernels and perhaps architectures.  That way future kernels and =
platforms are not perpetually "held
back" to support kernels that should be obsoleted or fixed. =


> =

> I was thinking about submitting a patch to change that, but then I'd be
> shooting myself in the foot, because my target platform runs kernel 4.4
> if I recall correctly ;)
> =

> > but it is *not* the topic of the patch I posted here to ELL yesterday.
> > AES-CMAC is the algorithm we use in Mesh to generate all of the
> > various Keys and IDs from master Net and App keys....
> =

> Ah, right, it's the K* family of functions. Sorry, I confused CCM and
> CMAC modes.
> =

> regards

Best Reagrds,
Brian
--===============2931727072478298325==--

