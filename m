Content-Type: multipart/mixed; boundary="===============5912664430185298148=="
MIME-Version: 1.0
From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 1/4] key: Add l_key_validate_dh_payload
Date: Wed, 09 Jan 2019 14:40:56 +0100
Message-ID: <nycvar.YFH.7.76.1901091440200.7590@n3.vanv.qr>
In-Reply-To: <20190109104349.11763-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5912664430185298148==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Wednesday 2019-01-09 11:43, Andrew Zaborowski wrote:

>Add a function to validate public values received from the DH peer
>against the minimum and maximum values depending on the group's
>prime modulus.  This is only necessary ~temporarily as the kernel
>*should* be validating the public value in the keyctl operation,
>however due to the shape of the syscall keyctl API it can't do that
>now so fixing it is not easy and may take a while.  We also can't
>do this easily inside l_key_compute_dh_secret because we don't have
>the prime's raw value there.  We could perhaps do that if we created
>a new "DH group" type (simliar to l_ecc_curve for ECDH) and made the
>API more like the ECDH API.

Excuse my ignorance, but isn't this something a library like
openssl/libressl/etc. should be doing instead?

--===============5912664430185298148==--

