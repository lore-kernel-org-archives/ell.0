Content-Type: multipart/mixed; boundary="===============8293260520248572141=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] key: Add l_key_validate_dh_payload
Date: Wed, 09 Jan 2019 08:54:25 -0600
Message-ID: <9887235f-9914-0e36-a2d1-eac1f25b81c6@gmail.com>
In-Reply-To: <nycvar.YFH.7.76.1901091440200.7590@n3.vanv.qr>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8293260520248572141==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

hi Jan,

> =

> Excuse my ignorance, but isn't this something a library like
> openssl/libressl/etc. should be doing instead?

We do not use openssl/libressl and do not want to.  Instead we utilize =

the Linux Kernel for most crypto primitives and just implement the bare =

minimum TLS protocol needed for our main projects.

This allows us to have a rather functional TLS stack in about ~5kloc, =

compared to depending on something like OpenSSL 540+ kloc.

Regards,
-Denis

--===============8293260520248572141==--

