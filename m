Content-Type: multipart/mixed; boundary="===============0385268394953807895=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= 'Khorne' Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH] uuid: Added l_uuid_parse
Date: Fri, 01 Feb 2019 18:29:08 +0100
Message-ID: <20190201172908.qktstzlevufj4mwz@kynes>
In-Reply-To: <163e920a-7101-5333-b03c-438c3fd0f096@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0385268394953807895==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 02/01, Denis Kenzior wrote:
> But then you know the expected UUID length anyway.  So you can simply che=
ck
> that strlen(string_uuid) is at least that long and pass in the expected U=
UID
> length to sscanf.

You're right, of course. Silly me. I'll fix the patch accordingly,
thanks.

-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND

--===============0385268394953807895==--

