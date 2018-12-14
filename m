Content-Type: multipart/mixed; boundary="===============4996395069327690969=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 8/9] tls: Allow user to set custom list of cipher suites
Date: Fri, 14 Dec 2018 20:12:50 +0100
Message-ID: <CAOq732K35KLTZwxr3X5nTf2Fi=B4daZpKPikxz_Z44eueCV0xA@mail.gmail.com>
In-Reply-To: <d5908538-31fc-d089-d343-c7812a54442b@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4996395069327690969==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 14 Dec 2018 at 17:33, Denis Kenzior <denkenz@gmail.com> wrote:
> On 12/13/2018 01:57 PM, Andrew Zaborowski wrote:
> > TLS "security profiles" define which minimum cipher suites and other
> > parameter values are allowed in a specific usage scenario for TLS, for
> > example WPA3 in theory requires a specific security profile for its
> > TLS-based EAP method.  This will also allow the unit tests to test
> > individual cipher suites.
>
> Do we want to expose this fine level of granularity in a public API
> though?  It would seem at least at WPA2 vs WPA3 level that a single
> SuiteB selector is all that is needed?

Yes, but there are more TLS profiles out there, like the BCP-195
profile and three profiles called DICOM profiles so we probably don't
want to define APIs for each and instead can have the user read the
spec and copy the cipher suite names?

I note that openssl does let you set/list cipher suites and so do some
https servers.

>
> Unless you have a usecase in mind where one would really want to twiddle
> the preference order?
>
> > ---
> >   ell/ell.sym       |   1 +
> >   ell/tls-private.h |   2 +
> >   ell/tls.c         | 101 ++++++++++++++++++++++++++++++++++++++++++----
> >   ell/tls.h         |   3 ++
> >   4 files changed, 99 insertions(+), 8 deletions(-)
> >
>
> <snip>
>
> <snip>
>
> > @@ -2790,6 +2836,45 @@ LIB_EXPORT void l_tls_set_version_range(struct l=
_tls *tls,
> >               max_version : TLS_MAX_VERSION;
> >   }
> >
> > +LIB_EXPORT void l_tls_set_cipher_suites(struct l_tls *tls,
> > +                                     const char **suite_list)
>
> void?  Don't we want to fail if nothing valid was passed?
>
> And wouldn't / shouldn't l_tls_start() also fail in this case?

l_tls_start() *should* fail so I thought it's easier on the user if
they only need a single conditional statement after setting the
versions and cipher suites instead of checking at every step.

>
> > +{
> > +     unsigned int i, len;
> > +     struct tls_cipher_suite **suite;
> > +
> > +     l_free(tls->cipher_suite_pref_list);
> > +
> > +     if (suite_list)
> > +             len =3D l_strv_length((char **) suite_list);
>
> I hate C and its char ** / const char ** thing.  Oh well :)
>
> > +     else
> > +             len =3D L_ARRAY_SIZE(tls_cipher_suite_pref);
>
> You take note of len here, but then...
>
> > +
> > +     tls->cipher_suite_pref_list =3D l_new(struct tls_cipher_suite *, =
len + 1);
> > +
> > +     if (!suite_list) {
> > +             /* Use our default cipher suite preference list */
> > +             for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i+=
+)
>
> use array_size here again.  Maybe a nitpick, but using len would be
> shorter anyway.

Ok, good point.

>
> Another question is whether storing a bool default_cipher_pref : 1
> instead of doing all this magic dancing would be easier.

So I initially was just setting a NULL tls->cipher_suite_pref_list to
indicate we're using the defaults but I then tried to concentrate the
conditional code in one place as there's this one place where we set
this list but many places that have to read and process it and they
were not easy to move into one function.  We already have some rather
convoluted checks when we negotiate the versions and cipher suites.

>
> > +                     tls->cipher_suite_pref_list[i] =3D
> > +                             &tls_cipher_suite_pref[i];
> > +
> > +             return;
> > +     }
> > +
> > +     suite =3D tls->cipher_suite_pref_list;
> > +
> > +     for (; *suite_list; suite_list++) {
> > +             for (i =3D 0; i < L_ARRAY_SIZE(tls_cipher_suite_pref); i+=
+)
> > +                     if (!strcmp(tls_cipher_suite_pref[i].name, *suite=
_list))
> > +                             break;
> > +
> > +             if (i < L_ARRAY_SIZE(tls_cipher_suite_pref))
> > +                     *suite++ =3D &tls_cipher_suite_pref[i];
> > +             else
> > +                     TLS_DEBUG("Cipher suite %s is not supported",
> > +                                     *suite_list);
> > +     }
> > +}
> > +
> >   LIB_EXPORT const char *l_tls_alert_to_str(enum l_tls_alert_desc desc)
> >   {
> >       switch (desc) {
>
> Regards,
> -Denis
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell

--===============4996395069327690969==--

