Content-Type: multipart/mixed; boundary="===============6626880088639003879=="
MIME-Version: 1.0
From: James Prestwood <prestwoj@gmail.com>
Subject: [PATCH 0/5] Extended group format
Date: Fri, 27 Sep 2019 12:30:04 -0700
Message-ID: <20190927193009.30262-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6626880088639003879==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Most of the details are explained in the patch notes, but the main
reasoning for this is to allow embedding PEMs inside an l_settings
file. We have found that some systems are provisioned with certificates
in /home/<user>/.cert/. System services are not really intended to have
access to /home (though this is not always the case), and for IWD
we do not want to allow that. For this reason it makes a lot of sense
to include the certs in the provisioning file. This also makes
provisioning much easier from both an admin and user perspective as you
just need to supply a single file rather than the network config plus
certificates/keys.

James Prestwood (5):
  pem: add _from_data variants to pem APIs
  unit/test-pem: add tests for new _from_data APIs
  pem: expose is_{start,end}_boundary
  settings: introduce extended groups concept
  unit/test-settings: add pem extended type tests

 ell/ell.sym          |   5 +
 ell/pem.c            | 152 ++++++++++++++++++++--------
 ell/pem.h            |   7 ++
 ell/settings.c       | 231 +++++++++++++++++++++++++++++++++++++++++-
 ell/settings.h       |   5 +
 pem-private.h        |  33 ++++++
 unit/settings.test   |  28 ++++++
 unit/test-pem.c      | 163 ++++++++++++++++++++++++++++++
 unit/test-settings.c | 234 ++++++++++++++++++++++++++++++++++++++++++-
 9 files changed, 806 insertions(+), 52 deletions(-)
 create mode 100644 pem-private.h

-- =

2.17.1


--===============6626880088639003879==--

