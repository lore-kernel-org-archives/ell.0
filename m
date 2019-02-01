Content-Type: multipart/mixed; boundary="===============3005985185027019577=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= 'Khorne' Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH] uuid: Added l_uuid_parse
Date: Fri, 01 Feb 2019 18:28:25 +0100
Message-ID: <20190201172825.c3hwc4x2ks2uure7@kynes>
In-Reply-To: <b90e57e8-4a9a-5826-3564-1a4161d4a7fa@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3005985185027019577==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis.

On 02/01, Denis Kenzior wrote:
> Hmm, portability where?  Is this an actual concern? Any platform that ell
> can actually run on, PRIx/SCNx =3D=3D 'x', no?

You're right about PRIx, but it's different for SCN:

#include <stdio.h>
#include <inttypes.h>

int main()
{
    printf("PRIx8=3D%s, SCNx8=3D%s\n", PRIx8 "", SCNx8 "");
}

$ ./a.out
PRIx8=3Dx, SCNx8=3Dhhx

I'll drop the change in l_uuid_to_string, but I'd like to keep SCNx,
even though it indeed does look messy.

-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND

--===============3005985185027019577==--

