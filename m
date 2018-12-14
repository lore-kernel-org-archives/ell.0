Content-Type: multipart/mixed; boundary="===============1212908096094518203=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 8/9] tls: Allow user to set custom list of cipher suites
Date: Fri, 14 Dec 2018 20:49:12 +0100
Message-ID: <CAOq732Kz4kKcv7iB4wfaqswsZgy4rZNW55Hq0rycYPF5ONLbfg@mail.gmail.com>
In-Reply-To: <3b61dc91-95e6-f99c-a522-1af77f990667@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1212908096094518203==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 14 Dec 2018 at 20:28, Denis Kenzior <denkenz@gmail.com> wrote:
> On 12/14/2018 01:12 PM, Andrew Zaborowski wrote:
> > On Fri, 14 Dec 2018 at 17:33, Denis Kenzior <denkenz@gmail.com> wrote:
> >> On 12/13/2018 01:57 PM, Andrew Zaborowski wrote:
> >>> TLS "security profiles" define which minimum cipher suites and other
> >>> parameter values are allowed in a specific usage scenario for TLS, for
> >>> example WPA3 in theory requires a specific security profile for its
> >>> TLS-based EAP method.  This will also allow the unit tests to test
> >>> individual cipher suites.
> >>
> >> Do we want to expose this fine level of granularity in a public API
> >> though?  It would seem at least at WPA2 vs WPA3 level that a single
> >> SuiteB selector is all that is needed?
> >
> > Yes, but there are more TLS profiles out there, like the BCP-195
> > profile and three profiles called DICOM profiles so we probably don't
> > want to define APIs for each and instead can have the user read the
> > spec and copy the cipher suite names?
> >
>
> Yes, but you also have to consider the audience for our TLS
> implementation.  It isn't browsers.  It is just iwd and maybe eventually
> ConnMan for the portals stuff.  So can we optimize the API for those use
> cases ?

I don't think we should but ok.  BTW we won't be Suite B compliant for
a while still because of the DSA certificates and likely more things.

>
> > I note that openssl does let you set/list cipher suites and so do some
> > https servers.
> >
> Perhaps you should just keep this private for now.

Ok.

>
> >>> +LIB_EXPORT void l_tls_set_cipher_suites(struct l_tls *tls,
> >>> +                                     const char **suite_list)
> >>
> >> void?  Don't we want to fail if nothing valid was passed?
> >>
> >> And wouldn't / shouldn't l_tls_start() also fail in this case?
> >
> > l_tls_start() *should* fail so I thought it's easier on the user if
> > they only need a single conditional statement after setting the
> > versions and cipher suites instead of checking at every step.
>
> But the server side at least doesn't?  Still, I'd think it would be
> useful to have a return value for this or make this private...

Ok, if we're keeping it private let's return a bool.

>
> >>
> >> Another question is whether storing a bool default_cipher_pref : 1
> >> instead of doing all this magic dancing would be easier.
> >
> > So I initially was just setting a NULL tls->cipher_suite_pref_list to
> > indicate we're using the defaults but I then tried to concentrate the
> > conditional code in one place as there's this one place where we set
> > this list but many places that have to read and process it and they
> > were not easy to move into one function.  We already have some rather
> > convoluted checks when we negotiate the versions and cipher suites.
>
> But you could just assign tls->cipher_suite_pref_list to the global
> value and twiddle a bit.  Then the bit just has to be checked here and
> in l_tls_free when deciding whether to use l_free().  Or use a const
> pointer for the rest of the code and a non-const pointer to store the
> allocated value (or NULL).
>
> Seems easier to me anyway.

Yeah, I considered just doing:

if (tls->cipher_suite_pref_list !=3D tls_cipher_suite_pref)
    l_free(tls->cipher_suite_pref_list);

but one is just an array of cipher suites and the other is an array of
pointers to cipher suites, perhaps I can convert tls_cipher_suite_pref
to an array of pointers.

BTW since tls.c is pretty big we could split out all the cipher suite
definitions and the functions used by them into tls-suites.c or
similar.  For ECDHE we'll need to add extensions support and I'm also
thinking of defining the extensions in a new file tls-extensions.c
(we'll support very few initially but the different specs actually
define many).

Best regards

--===============1212908096094518203==--

