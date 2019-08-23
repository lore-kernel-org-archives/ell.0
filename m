Content-Type: multipart/mixed; boundary="===============1907909061019848103=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 6/8] tls: Validate peer certificate's DNSNames against mask
Date: Fri, 23 Aug 2019 19:51:22 +0200
Message-ID: <CAOq732+caG4yqQtWfR_N=SHwgVD8fYHY2rhrBSR-GW=c_UM+Vw@mail.gmail.com>
In-Reply-To: <f19e8119-346b-6a28-fe45-53cf98683ec3@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1907909061019848103==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Fri, 23 Aug 2019 at 18:00, Denis Kenzior <denkenz@gmail.com> wrote:
> On 8/22/19 7:41 PM, Andrew Zaborowski wrote:
> > -     if (!cn)
> > +     if (cn)
> > +             for (i =3D mask; *i; i++)
> > +                     if (tls_domain_match_mask(cn, cn_len, *i, strlen(=
*i)))
> > +                             return true;
> > +
> > +     /*
> > +      * Locate SubjectAltName (RFC5280 Section 4.2.1.6) and descend in=
to
> > +      * the sole SEQUENCE element, check if any DNSName matches.
> > +      */
>
> So I think the recommended approach is to check all SubjectAltName
> dNSName tags first.  And only then try to match the CN, no?

Maybe more optimal, so I can switch this around, although as far as
I've seen in HTTPS certificates the server name is usually right in
the CN.  The return value is going to be the same independent of the
order in which we do the checks.

Best regards

--===============1907909061019848103==--

