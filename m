Content-Type: multipart/mixed; boundary="===============8198288336395216808=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [RFC 0/2] Random infrastructure
Date: Fri, 06 Feb 2015 13:37:13 +0200
Message-ID: <1423222635-6053-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8198288336395216808==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

I am sending this as an RFC since I cannot get the stdrng working yet.
The bind fails, so it's probably an issue around type/name.

Tomasz Bursztyka (2):
  random: Add a basic infrastructure for kernel based rng
  unit: Add a unit test for the random infrastructure

 Makefile.am        |  11 ++-
 ell/ell.h          |   1 +
 ell/random.c       | 222 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++
 ell/random.h       |  50 ++++++++++++
 unit/test-random.c |  91 ++++++++++++++++++++++
 5 files changed, 372 insertions(+), 3 deletions(-)
 create mode 100644 ell/random.c
 create mode 100644 ell/random.h
 create mode 100644 unit/test-random.c

-- =

2.0.5


--===============8198288336395216808==--

