Content-Type: multipart/mixed; boundary="===============2213296330311173723=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Unchecked dependancy on openssl
Date: Wed, 30 Jun 2021 21:55:24 +0200
Message-ID: <0E00B299-8D28-43B9-A6FF-DD069A55C436@holtmann.org>
In-Reply-To: <bb8ee0c02b06f91d67ef82a6005aa1e9e4315673.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2213296330311173723==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

> Bringing up a new dev environment I noticed that ELL has a dependancy on =
openssl, to create some required *.pem
> files.  The existance of openssl on the system is not checked by the boot=
strap-configure setup, and it probably
> should be.

anything around bootstrap-configure and what we do as developers has been l=
azy dependencies. The devs should know what they are doing kind of thing.

Anyhow, feel free to propose something and we can review it. It just has to=
 be worth the trouble.

Regards

Marcel

--===============2213296330311173723==--

