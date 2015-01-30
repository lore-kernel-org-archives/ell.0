Content-Type: multipart/mixed; boundary="===============5081457511858178675=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [RFC 0/2] Cipher infrastructure
Date: Fri, 30 Jan 2015 12:57:42 +0200
Message-ID: <1422615464-21435-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5081457511858178675==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

Went quickly through the cipher proposal, to get a somehow working implemen=
tation.
Seems to work with aes, but not with arc4.

And now I wonder if we should not provide an initialization vector for some=
 ciphers? (like arc4).

I thought I could set one IV per socket once, but it does not seems so. (th=
us there is
nothing related to IV in this RFC).

So, should I set iv elements in struct l_cipher, so I could set one one enc=
rypting/decrypting?
It's just a bit annoying with cmsg handling, but I got nice example with li=
bkapi (though this
one mandate the user to provide the iv. I tought we could handle randomly g=
enerated ones?)

libkapi is kind of nice as it uses vmsplice and so on. It's just a lot of c=
ode, I don't
think we want something that complex.

Tomasz Bursztyka (2):
  cipher: Add a basic infrastructure for kernel based cipher operations
  unit: Add unit test for the cipher infrastructure

 Makefile.am        |  11 ++-
 ell/cipher.c       | 215 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/cipher.h       |  51 +++++++++++++
 ell/ell.h          |   1 +
 unit/test-cipher.c | 109 +++++++++++++++++++++++++++
 5 files changed, 384 insertions(+), 3 deletions(-)
 create mode 100644 ell/cipher.c
 create mode 100644 ell/cipher.h
 create mode 100644 unit/test-cipher.c

-- =

2.0.5


--===============5081457511858178675==--

