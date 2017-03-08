Content-Type: multipart/mixed; boundary="===============7310631032847227089=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH 0/2] Make some ELL headers completely self-contained.
Date: Wed, 08 Mar 2017 12:29:23 -0800
Message-ID: <1489004965-19931-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7310631032847227089==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

These patches address some compile-time errors encountered when
attempting to use functions and macros declared in installed ELL
headers.  The headers in question were not completely self-contained.

Ossama Othman (2):
  main: Fixed missing uint32_t typedef error
  log: Fixed missing L_STRINGIFY macro definition

 ell/log.c  | 1 -
 ell/log.h  | 2 ++
 ell/main.h | 1 +
 3 files changed, 3 insertions(+), 1 deletion(-)

-- =

2.7.4


--===============7310631032847227089==--

