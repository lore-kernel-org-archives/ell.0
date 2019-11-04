Content-Type: multipart/mixed; boundary="===============5537270253193841105=="
MIME-Version: 1.0
From: Brian Gix <brian.gix@intel.com>
Subject: [PATCH 0/1] Make PKCS8 dependant unit tests fail gracefully
Date: Mon, 04 Nov 2019 12:20:59 -0800
Message-ID: <20191104202100.21115-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5537270253193841105==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patch is based on the failure check in unit/test-cipher, which
gives mitigation instructions for known and easily correctable
deficiencies in Kernel space.  In the case of these three unit tests,
the pkcs8_key_parser must be loaded for the unit test to pass. If not
loaded the mitigation is given, and the test exits with an exit(1)
rather than an assert fail.


Brian Gix (1):
  unit: Add graceful fail of pem, tls and key tests

 unit/test-key.c |  9 +++++++++
 unit/test-pem.c |  9 +++++++++
 unit/test-tls.c | 12 +++++++++++-
 3 files changed, 29 insertions(+), 1 deletion(-)

-- =

2.21.0

--===============5537270253193841105==--

