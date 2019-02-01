Content-Type: multipart/mixed; boundary="===============6996934557804312433=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= 'Khorne' Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH] uuid: Added l_uuid_parse
Date: Fri, 01 Feb 2019 18:22:48 +0100
Message-ID: <20190201172248.ylwlb42ilq42cenl@kynes>
In-Reply-To: <35E8B0B5-82F3-4A91-A08E-FA506815851A@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6996934557804312433==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

Thanks for the review. I'll change the name and extract formatting
macros to a separate commit.

On 02/01, Marcel Holtmann wrote:
> > +LIB_EXPORT bool l_uuid_parse(const char *src, size_t src_size,
> > +							 uint8_t uuid[16])
> > +{
> =

> Don=E2=80=99t bother with src_size parameter. You can use strlen for that
> since supporting non null-terminated strings seems rather pointless.
> You will required space or null terminator at the end of make sscanf
> actually work correctly anyway. So I would rather check that the
> string is long enough to hold an actual UUID text representation and
> that you have a proper terminator at the end.

I don't think that's true. Since format passed to scanf expects a fixed
input length, this works as expected:

    const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7detoolon=
g";
    l_uuid_parse(string_uuid, strlen(string_uuid) - strlen('toolong'), uuid=
);

The use case would be retrieving the UUID from a substring (at given
offset), e.g. from a path. I'll add the unit test for this.

regards
-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND

--===============6996934557804312433==--

