Content-Type: multipart/mixed; boundary="===============4043972301789526448=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: ell/settings.c, ell/settings.h dependancy rabbit hole
Date: Thu, 28 Nov 2019 16:59:26 +0000
Message-ID: <769fa1170959a67a05bd4b42f4c63808157b4755.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4043972301789526448==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi All,

In BlueZ, we are implementing a mesh.conf file, similar to the main.conf fi=
le already in use for the Bluetooth
daemon.  This will also be an issue with the main daemon once we start chan=
ging it over to using ELL as well.

Our conf files are farely simple Key+Value files like this:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[General]
# Comments
Name =3D BlueZ
AlwaysPairable =3D false
PairableTimeout =3D 0

[GATT]
ExchangeMTU =3D 517
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

For this we want to include ell/settings.[ch] into our build, which perform=
s this simple parsing.  However,
settings.c is currently including ell/pem-private.h, and has a link referen=
ce to pem_next(), via an extension
mechanism.  The PEM module then requires inclusion of cert, key, pkcs5 and =
base64.

Is there a way to make this pem more "optional"?  Because we have gone from=
 a fairly simple inclusion of
settings.c and it's header to needing to including the following modules, w=
hich is defeating part of the
purpose of keeping ELL lean and mean:

ell/settings.c
ell/pem.c
ell/cert.c
ell/key.c
ell/pkcs5.c
ell/base64.c

ell/settings.h
ell/pem.h
ell/pem-private.h
ell/asn1-private.h
ell/base64.h
ell/cert.h
ell/cert-private.h
ell/key.h
ell/pkcs5.h
ell/pkcs5-private.h

As far as I can tell, we do not use or need pem, cert, key, pkcs5, or base64

--Brian



--===============4043972301789526448==--

