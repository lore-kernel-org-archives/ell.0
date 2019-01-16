Content-Type: multipart/mixed; boundary="===============1168293553262844315=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: Re: [PATCH v2 2/2] ecc: document where ECC groups came from
Date: Wed, 16 Jan 2019 09:05:43 -0800
Message-ID: <10ce642d0b7bd24194ab61a5b2dd0a2c7389625d.camel@linux.intel.com>
In-Reply-To: <3e0d3d35-f8ae-b02d-be35-b3ee6f778372@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1168293553262844315==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 2019-01-16 at 10:38 -0600, Denis Kenzior wrote:
> Hi James,
> =

> On 01/15/2019 04:43 PM, James Prestwood wrote:
> > For future reference a comment was added pointing to RFC 5114
> > ---
> >   ell/ecc.c | 6 ++++++
> >   1 file changed, 6 insertions(+)
> > =

> =

> Applied.
> =

> But the original question was actually about where the group
> identifiers =

> came from?  E.g. group 19, 20 etc.

Ah, ok. Well they are in that RFC, just a different section. Actually
after looking into this I am somewhat confused. I originally based my
ECC groups off hostapd, and e.g. EAP-PWD which says group 19 (256-bit)
must be supported. Sort of after the fact I saw that these group
numbers were defined in RFC 5114. Now after revisiting this I see there
are actually two tables, one for IKE and one for TLS, and the group
numbers do not match. Maybe once ECC is used in TLS we will need a
mapping?

Thanks,
James
> =

> Regards,
> -Denis
> =



--===============1168293553262844315==--

