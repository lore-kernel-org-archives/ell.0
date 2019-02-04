Content-Type: multipart/mixed; boundary="===============4228324890237484567=="
MIME-Version: 1.0
From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH v2] uuid: Added l_uuid_from_string
Date: Mon, 04 Feb 2019 15:29:00 +0100
Message-ID: <nycvar.YFH.7.76.1902041527340.19955@n3.vanv.qr>
In-Reply-To: <20190204104107.17893-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4228324890237484567==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Monday 2019-02-04 11:41, Micha=C5=82 'Khorne' Lowas-Rzechonek wrote:
>+static void test_from_string_too_short(const void *data)
>+{
>+	uint8_t uuid[16];
>+	const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7d";

You can make these

	static const char string_uid[] =3D "65f.."

>+	const char *string_uuid =3D "65fcc697-0776-5bf9-8573-72a51080c7detoolong=
";

	static const char string_uuid[]

>+	uint8_t expected_uuid[16] =3D { 0x65, 0xfc, 0xc6, 0x97, 0x07, 0x76, 0x5b=
, 0xf9,
>+		                          0x85, 0x73, 0x72, 0xa5, 0x10, 0x80, 0xc7, 0xd=
e };

	static const uint8_t expected_uuid;

and so on.

--===============4228324890237484567==--

