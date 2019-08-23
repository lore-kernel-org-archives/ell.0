Content-Type: multipart/mixed; boundary="===============6474165364599051575=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 6/8] tls: Validate peer certificate's DNSNames against mask
Date: Sat, 24 Aug 2019 01:50:39 +0200
Message-ID: <CAOq732+cuHcfxDGOKQ=zT-BPXgOU=BgJpYxhUiNUYxAWiQEiaw@mail.gmail.com>
In-Reply-To: <7c7c5ed7-d5b4-ca16-641e-4d8b05659f7d@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6474165364599051575==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 23 Aug 2019 at 23:54, Denis Kenzior <denkenz@gmail.com> wrote:
> On 8/23/19 12:51 PM, Andrew Zaborowski wrote:
> > On Fri, 23 Aug 2019 at 18:00, Denis Kenzior <denkenz@gmail.com> wrote:
> >> On 8/22/19 7:41 PM, Andrew Zaborowski wrote:
> >>> -     if (!cn)
> >>> +     if (cn)
> >>> +             for (i =3D mask; *i; i++)
> >>> +                     if (tls_domain_match_mask(cn, cn_len, *i, strle=
n(*i)))
> >>> +                             return true;
> >>> +
> >>> +     /*
> >>> +      * Locate SubjectAltName (RFC5280 Section 4.2.1.6) and descend =
into
> >>> +      * the sole SEQUENCE element, check if any DNSName matches.
> >>> +      */
> >>
> >> So I think the recommended approach is to check all SubjectAltName
> >> dNSName tags first.  And only then try to match the CN, no?
> >
> > Maybe more optimal, so I can switch this around, although as far as
> > I've seen in HTTPS certificates the server name is usually right in
> > the CN.  The return value is going to be the same independent of the
> > order in which we do the checks.
>
> Yes, I think you're right that the check order doesn't really matter in
> the end.  I'm just thinking the code would be more readable doing it in
> the order that the the spec wants.  You can quote the Hotspot spec if
> need-be.

Ok, will do.

Best regards

--===============6474165364599051575==--

