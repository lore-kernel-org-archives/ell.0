Content-Type: multipart/mixed; boundary="===============7472705866195248934=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 0/2] Improve genl with a message builder 
Date: Wed, 04 Mar 2015 15:05:53 +0200
Message-ID: <1425474355-30536-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7472705866195248934==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

I could not test yet the whole patch set so it's sent here for a quick revi=
ew.

First patch is there since I realized genl lacked of those LIB_EXPORT and u=
nlikely().
Minor stuff so.

Second patch is the interesting one.

I am currently building a unit test for it. Getting some reliable nested ba=
sed messages
to compare with is the annoyingly time consuming part here.

Tomasz Bursztyka (2):
  genl: Normilize functions exports and parameters check as it should
  genl: Add a message builder API to help creating complex nl messages

 ell/genl.c | 275 ++++++++++++++++++++++++++++++++++++++++++++++-----------=
----
 ell/genl.h |  18 ++++
 2 files changed, 226 insertions(+), 67 deletions(-)

-- =

2.0.5


--===============7472705866195248934==--

