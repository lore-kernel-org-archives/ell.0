Content-Type: multipart/mixed; boundary="===============2111474124971380397=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: [PATCH 0/2] Hashmap fix
Date: Fri, 13 Feb 2015 12:57:59 +0200
Message-ID: <1423825081-4137-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2111474124971380397==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

First patch's commit message details the fix.

Tomasz Bursztyka (2):
  hashmap: Ensure one unique key ever exists in all entries
  unit: Slightly change hash duplicity test to verify key unitiy
    behavior

 ell/hashmap.c       | 26 ++++++++++++++------------
 unit/test-hashmap.c |  4 ++--
 2 files changed, 16 insertions(+), 14 deletions(-)

-- =

2.0.5


--===============2111474124971380397==--

