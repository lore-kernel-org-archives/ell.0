Content-Type: multipart/mixed; boundary="===============1490635538390374639=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 0/2] cipher infrastructure
Date: Tue, 03 Feb 2015 10:50:11 +0200
Message-ID: <1422953413-27902-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1490635538390374639==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

I applied the comments on the RFC. Now ARV4 works.
I introduced as well the iv/iv_length parameters to l_cipher_new(), however
it's not implemented yet. There will be time to support it as well as other
ciphers (twofish, blowfish... )

Tomasz Bursztyka (2):
  cipher: Add a basic infrastructure for kernel based cipher operations
  unit: Add unit test for the cipher infrastructure

 Makefile.am        |  11 ++-
 ell/cipher.c       | 238 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/cipher.h       |  53 ++++++++++++
 ell/ell.h          |   1 +
 unit/test-cipher.c | 109 ++++++++++++++++++++++++
 5 files changed, 409 insertions(+), 3 deletions(-)
 create mode 100644 ell/cipher.c
 create mode 100644 ell/cipher.h
 create mode 100644 unit/test-cipher.c

-- =

2.0.5


--===============1490635538390374639==--

