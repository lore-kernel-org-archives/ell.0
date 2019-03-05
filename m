Content-Type: multipart/mixed; boundary="===============9037792239426315644=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH 0/5] Support C89 ELL builds
Date: Tue, 05 Mar 2019 19:56:18 +0100
Message-ID: <20190305185618.bussn7oezahr6gbo@kynes>
In-Reply-To: <8d8583e1-3d6b-36a3-1523-c5743e2e61a7@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9037792239426315644==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 03/05, Denis Kenzior wrote:
> Please, no top posting on this mailing list :)
Sorry! Most MUAs nowadays default to top posting, my bad for not paying
attention.

> So my initial response would be in a form of a bewildered question: "Why =
are
> we even talking about this?".  The reason I ask is that we follow the
> Linux kernel coding style, which basically disallows most of the
> 'interesting' C99 features.
Didn't mean to offend. Since I submitted a patch and I'm probably going
to submit a few more, I wanted to know what to expect. I read the coding
style, but ELL doesn't mention -std=3Dgnu89. I know it's probably
"obvious" to you guys, since you have a kernel background, but many
other projects have substantially different policies.

> But since we are talking about this, let me formulate the official policy.
> We follow the same process as described in:
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/D=
ocumentation/process/programming-language.rst
>
> So roughly speaking what this means is that the code should compile with
> -std=3Dgnu89.  C89 compliance is not an official policy or goal.
Fair enough, thank you for clarification!

It might be worth to mention this in doc/coding-style, so a next
clueless person doesn't repeat silly questions ;)

-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND

--===============9037792239426315644==--

