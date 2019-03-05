Content-Type: multipart/mixed; boundary="===============7739411246866485526=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/5] Support C89 ELL builds
Date: Tue, 05 Mar 2019 11:43:19 -0600
Message-ID: <8d8583e1-3d6b-36a3-1523-c5743e2e61a7@gmail.com>
In-Reply-To: <CACXRGxzR-XORyw-C+qGW3tdC3+FKhiLFpkN9ZuM0vYsSCPCw=A@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7739411246866485526==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

On 03/05/2019 12:57 AM, Micha=C5=82 Lowas-Rzechonek wrote:
> Yeah, I get that! My question was mostly to Denis, about the overall poli=
cy.
> =


Please, no top posting on this mailing list :)

So my initial response would be in a form of a bewildered question: "Why =

are we even talking about this?".  The reason I ask is that we follow =

the Linux kernel coding style, which basically disallows most of the =

'interesting' C99 features.

But since we are talking about this, let me formulate the official =

policy.  We follow the same process as described in: =

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Doc=
umentation/process/programming-language.rst

So roughly speaking what this means is that the code should compile with =

-std=3Dgnu89.  C89 compliance is not an official policy or goal.

Regards,
-Denis

--===============7739411246866485526==--

