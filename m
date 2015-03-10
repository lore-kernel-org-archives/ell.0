Content-Type: multipart/mixed; boundary="===============3848988805448288975=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH v2 0/4] Improve genl with a message builder
Date: Tue, 10 Mar 2015 13:14:26 +0200
Message-ID: <1425986070-8808-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3848988805448288975==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

It took a bit long as I was messing up with the wrong dump of a message
(a private vs a broadcasted one...) and of course it took a while before
I realized it.

Anyway, seems to work. I only had an issue with the nested message length
calculation when leaving it.

Tomasz Bursztyka (4):
  genl: Normilize functions exports and parameters check as it should
  genl: Add a message builder API to help creating complex nl messages
  genl: Add a function to grab the message's raw data for unit purpose
  unit: Add a message builder unit test for genl

 Makefile.am        |   1 +
 ell/genl-private.h |  25 +++++
 ell/genl.c         | 284 ++++++++++++++++++++++++++++++++++++++++---------=
----
 ell/genl.h         |  18 ++++
 unit/test-genl.c   | 136 +++++++++++++++++++++----
 5 files changed, 379 insertions(+), 85 deletions(-)
 create mode 100644 ell/genl-private.h

-- =

2.0.5


--===============3848988805448288975==--

