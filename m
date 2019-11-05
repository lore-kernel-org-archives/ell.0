Content-Type: multipart/mixed; boundary="===============7665667298086602443=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: ELL double free during debug exit cleanup
Date: Tue, 05 Nov 2019 21:31:56 +0000
Message-ID: <ce508cbf17bd72b98558bf286ca7d949efb4f0c0.camel@intel.com>
In-Reply-To: <5d1bbc5b-dea9-4efd-be73-fda983b3edca@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7665667298086602443==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 2019-11-05 at 14:48 -0600, Denis Kenzior wrote:
> Hi Brian,
> =

> > > -__attribute__((constructor)) static void register_debug_section()
> > > +__attribute__((constructor)) void l_register_debug_section()
> =

> So really, this would be about the last solution I'd pick, no matter =

> where the forward declaration lives.
> =

> Have you looked into why the library/or this file is being statically =

> linked twice?

I have but haven't found anything I can put my finger on yet.  I have been =
trying to figure out what make Link
Time Optimization different, and of course I do have my suspicions that *I*=
 must have done something wrong in
the BLUEZ Unit test, since I can't reproduce the issue in any of the ELL un=
it tests.

I am continuing my research focussing on how BLUEZ is building it's (one) E=
LL based unit test. This last email
was mostly about confirming the observations of the bug reporter.  =

> =

> Regards,
> -Denis

--===============7665667298086602443==--

