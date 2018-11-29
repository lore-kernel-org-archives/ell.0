Content-Type: multipart/mixed; boundary="===============0652113291076294739=="
MIME-Version: 1.0
From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] build: Add -ldl to LIBS as needed.
Date: Thu, 29 Nov 2018 23:48:56 +0100
Message-ID: <nycvar.YFH.7.76.1811292346250.28476@n3.vanv.qr>
In-Reply-To: <20181129214610.30694-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0652113291076294739==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Thursday 2018-11-29 22:46, Ossama Othman wrote:
>
>Lastly, only add "-ldl" to the library flags in ELL's pkg-config file
>(ell.pc) when necessary.
>index 4fc933b..65ea88e 100644
>--- a/ell/ell.pc.in
>+++ b/ell/ell.pc.in
>@@ -6,5 +6,5 @@ includedir=3D@includedir@
> Name: ELL
> Description: Embedded Linux library
> Version: @VERSION@
>-Libs: -L${libdir} -lell -ldl
>+Libs: -L${libdir} -lell @LIBS@
> Cflags: -I${includedir}

The change does not correspond to the claim. "-ldl" will still always
end up in the .pc (on Linux/glibc), even though it's already
recorded in the .so file.

This ought to be

  Libs.private: @LIBS@

instead.

--===============0652113291076294739==--

