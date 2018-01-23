Content-Type: multipart/mixed; boundary="===============6306562164438584631=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] key: Add private API for key feature detection
Date: Tue, 23 Jan 2018 16:24:22 -0600
Message-ID: <f42d9603-59eb-861b-58a4-558119f2084c@gmail.com>
In-Reply-To: <alpine.OSX.2.21.1801231339480.14612@mjmartin-mac01.sea.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6306562164438584631==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> I tested these changes out on various kernels going back to 4.2, and the =

> keyctl feature detection worked fine.

Cool, much appreciated.

> =

> I did run in to some glitches with test-pem and test-cipher on some old =

> kernels. test-pem needs L_CIPHER_DES_CBC for encrypted certs, and =


I've just pushed out an update to test-pem that hopefully takes care of =

this.

> test-cipher fails because AEAD ciphers had a bogus recv() return value =

> before v4.9 (see kernel commit 0c1e16cd1e).

Not sure what we can do about this one.

Regards,
-Denis

--===============6306562164438584631==--

