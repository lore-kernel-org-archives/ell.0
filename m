Content-Type: multipart/mixed; boundary="===============3233338842018863523=="
MIME-Version: 1.0
From: michal.lowas-rzechonek@silvair.com
Subject: Re: [PATCH] cipher: add AES-CMAC hashing support
Date: Wed, 29 May 2019 21:26:27 +0200
Message-ID: <20190529192627.j32awzp3rq7u5t3p@kynes>
In-Reply-To: <1559143780.3694.10.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3233338842018863523==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian, Denis,

On 05/29, Gix, Brian wrote:
> > Is this about mesh_crypto_aes_ccm_encrypt and
> > mesh_crypto_aes_ccm_decrypt functions in mesh/crypto.c?
> =

> The code you copy pasted below *is* the usage of AES_CCM that we use in m=
esh,

Um, it's not - mesh_crypto_aes_ccm_* functions seem to implement AES_CCM
on top of ECB, in user space. As Denis mentioned, this is somewhat
inefficient, but at least it works on older kernels.

I was thinking about submitting a patch to change that, but then I'd be
shooting myself in the foot, because my target platform runs kernel 4.4
if I recall correctly ;)

> but it is *not* the topic of the patch I posted here to ELL yesterday.
> AES-CMAC is the algorithm we use in Mesh to generate all of the
> various Keys and IDs from master Net and App keys....

Ah, right, it's the K* family of functions. Sorry, I confused CCM and
CMAC modes.

regards
-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND

--===============3233338842018863523==--

