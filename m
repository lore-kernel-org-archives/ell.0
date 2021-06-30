Content-Type: multipart/mixed; boundary="===============6339090691128950049=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Unchecked dependancy on openssl
Date: Wed, 30 Jun 2021 17:05:12 +0000
Message-ID: <bb8ee0c02b06f91d67ef82a6005aa1e9e4315673.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6339090691128950049==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis and all,

Bringing up a new dev environment I noticed that ELL has a dependancy on op=
enssl, to create some required *.pem
files.  The existance of openssl on the system is not checked by the bootst=
rap-configure setup, and it probably
should be.

--Brian

--===============6339090691128950049==--

