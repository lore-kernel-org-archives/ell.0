Content-Type: multipart/mixed; boundary="===============6161127633110277325=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 0/9] hashmap fixes
Date: Tue, 10 Feb 2015 16:42:15 +0200
Message-ID: <1423579344-10933-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6161127633110277325==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

noticed some issues in hashmap while implementing
an applicantion on top of ell.

Cheers,
Jukka

Jukka Rissanen (9):
  hashmap: Add value free function
  hashmap: Call user supplied value free function in destroy
  hashmap: Call user supplied value free function in insert
  unit: hashmap: Add value free hash entry test
  unit: hashmap: Add replace entry test
  hashmap: Add re-entrancy support to foreach function
  unit: hashmap: Re-entrancy tests added
  hashmap: Add support to finding an element from hash
  unit: hashmap: Add unit test for l_hashmap_find

 ell/hashmap.c       | 176 ++++++++++++++++++++++++++++++++++++++++++++++++=
+++-
 ell/hashmap.h       |  11 ++++
 unit/test-hashmap.c | 142 ++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 326 insertions(+), 3 deletions(-)

-- =

1.8.3.1


--===============6161127633110277325==--

