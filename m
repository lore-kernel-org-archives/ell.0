Content-Type: multipart/mixed; boundary="===============7478161304312858994=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] uuid: Added l_uuid_parse
Date: Fri, 01 Feb 2019 11:22:38 -0600
Message-ID: <b90e57e8-4a9a-5826-3564-1a4161d4a7fa@gmail.com>
In-Reply-To: <20190201134617.28831-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7478161304312858994==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

> I've also changed printf/scanf formatting to use PRIx/SCNx macros, for
> better portability

Hmm, portability where?  Is this an actual concern? Any platform that =

ell can actually run on, PRIx/SCNx =3D=3D 'x', no?

The use of PRI* macros makes the printf statement quite a bit less =

readable IMO.  I can understand the need when using size_t or other =

esoteric types that depend on the arch, but uint8_t isn't one of them...

Anyway, no biggie, just wondering...

Regards,
-Denis

--===============7478161304312858994==--

