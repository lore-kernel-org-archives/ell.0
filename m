Content-Type: multipart/mixed; boundary="===============9092966662306573865=="
MIME-Version: 1.0
From: James Prestwood <james.prestwood@linux.intel.com>
Subject: [PATCH 0/3] Implement P384 curve
Date: Tue, 11 Dec 2018 16:28:57 -0800
Message-ID: <20181212002900.11739-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9092966662306573865==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Now that ECC has been merged into ELL we can add the P384 curve definition.
TLS will eventually use this for some ECDSA cipher suites.

James Prestwood (3):
  ecc: implement P384 fast modulus
  ecc: added P384 curve definition
  unit: added P384 unit tests

 ell/ecc-external.c | 129 +++++++++++++++++++++++++++++++++++++++++++++
 ell/ecc.c          |  30 +++++++++++
 ell/ecc.h          |   2 +-
 unit/test-ecdh.c   |  66 +++++++++++++++++++++++
 4 files changed, 226 insertions(+), 1 deletion(-)

-- =

2.17.1


--===============9092966662306573865==--

