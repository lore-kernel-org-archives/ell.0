Content-Type: multipart/mixed; boundary="===============4795061110297515737=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: Re: [PATCH v4 1/5] ecc: moved ecc from IWD into ell
Date: Mon, 10 Dec 2018 08:47:34 -0800
Message-ID: <14d4957d39a5a5e2302e5753b0699f47333834d8.camel@linux.intel.com>
In-Reply-To: <FAE891F7-EA35-4A4E-B6E3-9AD9BB029057@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4795061110297515737==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Mon, 2018-12-10 at 12:19 +0100, Marcel Holtmann wrote:
> Hi Denis,
> =

> > > so I am not a big fan of these nested directory structures in the
> > > first place and especially not a big fan of the 3rdparty thing.
> > > If we modify the source files to make them compile or use our
> > > internal definitions, then it is no longer external code. If it
> > > is code that purely external, we can do ell/ecc-external.[ch] or
> > > something like that. We can do the same as we do in ell/siphash.c
> > > where we take the code as ELL code and acknowledge the original
> > > code and its origin.
> > =

> > So I'd like to separate as much as possible the original 3rd party
> > code from what we ended up adding (which was quite a bit) to it in
> > order to support EAP-PWD/SAE/OWE.  I want to make it easier to
> > update this file from external sources if we need to (e.g. as
> > vulnerabilities / bugs are potentially discovered and fixed.)  In
> > iwd we created this hodge-podge of the original 3rdparty code + our
> > additions and I don't think that was a good idea.
> > =

> > If you want to keep it in ecc-external.c, that would be
> > fine.  3rdparty subdirectory seems clearer, but whichever
> > accomplishes the above is fine.
> =

> so I have a test tree that uses the latest micro-ecc repository as
> base. If we want to have an easy path to pull in updates from
> upstream, then this needs to be uECC.[ch] and friends. However I need
> to send patches to micro-ecc since it will not build as simple as
> their README might indicate. Minor details, but they didn=E2=80=99t really
> test it enough.
> =

> > > Lets go back one step and tell me what this is based on? Is this
> > > the old BlueZ code or is this the micro-ecc?
> > =

> > The code was from BlueZ's version of ecc with slight
> > modifications.  And that is another issue.  The goal of this is to
> > standardize this across the projects.
> =

> That is what I thought. And that code is an old snapshot with only P-
> 256 curve in mind.
> =

> > > Do we need such a rich API? Can we start with a smaller one for
> > > things we actually need from it.
> > =

> > This is about as minimal as we can get for what iwd needs for
> > SAE/OWE/PWD.
> =

> Do we want the ECC curve really as struct? Or are we going to have an
> enum or have them as pre-defined exported symbols. It kind seems
> pointless have the curves allocated.

The curves aren't allocated, l_ecc_curve_get() just returns the static
struct in the curve list. I did it this way so all the API's that take
a curve had direct acccess to all the curve variables (rather than
looking up by group number every time).

> =

> Regards
> =

> Marcel
> =



--===============4795061110297515737==--

