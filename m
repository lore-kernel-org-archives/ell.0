Content-Type: multipart/mixed; boundary="===============0718352067683926301=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= 'Khorne' Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH v2] uuid: Added l_uuid_from_string
Date: Mon, 04 Feb 2019 18:36:01 +0100
Message-ID: <20190204173601.pef4xgowvasy7tbw@kynes>
In-Reply-To: <nycvar.YFH.7.76.1902041527340.19955@n3.vanv.qr>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0718352067683926301==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jan,
 =

On 02/04, Jan Engelhardt wrote:
> >+	uint8_t uuid[16];
> >+	const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7d";
> =

> You can make these
> =

> 	static const char string_uid[] =3D "65f.."

True, but I don't think it matters, since this is test code. I was just
following examples.

-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND

--===============0718352067683926301==--

