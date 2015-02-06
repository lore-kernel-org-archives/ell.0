Content-Type: multipart/mixed; boundary="===============6992770555495857427=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH v2 0/2] Cipher infrastructure
Date: Fri, 06 Feb 2015 14:39:21 +0200
Message-ID: <1423226363-5025-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6992770555495857427==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

Looks like we need to re-inject the keys to the master socket (the one which
is binded so the selected crypto) once before an operation type, so first e=
ncrypt
and/or first decrypt.
Now it seems to work. Should it handle an initialization vector?

Tomasz Bursztyka (2):
  cipher: Add a basic infrastructure for kernel based cipher operations
  unit: Add unit test for the cipher infrastructure

 Makefile.am        |  11 ++-
 ell/cipher.c       | 221 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/cipher.h       |  52 +++++++++++++
 ell/ell.h          |   1 +
 unit/test-cipher.c | 107 ++++++++++++++++++++++++++
 5 files changed, 389 insertions(+), 3 deletions(-)
 create mode 100644 ell/cipher.c
 create mode 100644 ell/cipher.h
 create mode 100644 unit/test-cipher.c

-- =

2.0.5


--===============6992770555495857427==--

