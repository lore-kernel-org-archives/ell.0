Content-Type: multipart/mixed; boundary="===============0175947583895123395=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: ELL double free during debug exit cleanup
Date: Tue, 05 Nov 2019 22:56:24 +0000
Message-ID: <78972de8d3b111cf96d5c4f2116f75e1e0432154.camel@intel.com>
In-Reply-To: <ce508cbf17bd72b98558bf286ca7d949efb4f0c0.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0175947583895123395==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis and others,

On Tue, 2019-11-05 at 21:31 +0000, Gix, Brian wrote:
> Hi Denis,
> =

> On Tue, 2019-11-05 at 14:48 -0600, Denis Kenzior wrote:
> > Hi Brian,
> > =

> > > > -__attribute__((constructor)) static void register_debug_section()
> > > > +__attribute__((constructor)) void l_register_debug_section()
> > =

> > So really, this would be about the last solution I'd pick, no matter =

> > where the forward declaration lives.
> > =

> > Have you looked into why the library/or this file is being statically =

> > linked twice?

After disecting what the BLUEZ Makefile was doing, I did find the inclusion=
 of both log.c and ell/libell-
internal.la in the unit test that was failing.  Thankfully, I was also able=
 to confirm that the issue was
limited to the one test, and now have a template to include other ELL based=
 unit tests.

I apologize for the alarm, but will now at least be including openSUSE and =
LTO in my validation passes. =


Thank you so much for your time, Denis.

> Regards,
> > -Denis
> _______________________________________________
> ell mailing list -- ell(a)lists.01.org
> To unsubscribe send an email to ell-leave(a)lists.01.org

--===============0175947583895123395==--

