Content-Type: multipart/mixed; boundary="===============4208879141453528020=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@gmail.com>
Subject: [PATCH 0/2] Fix "NLA_F_NESTED is missing" error
Date: Mon, 30 Nov 2020 10:57:34 -0800
Message-ID: <20201130185736.30474-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4208879141453528020==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This set of patches addresses a "NLA_F_NESTED is missing" error under
strict nested netlink attribute validation by the kernel.  Users can
work around the error by explicitly setting the NLA_F_NESTED bit in
the type passed to l_genl_msg_enter_nested(), but having ELL
transparently set the bit seems more appropriate.

Ossama Othman (2):
  genl: Add missing NLA_F_NESTED bit
  unit: Update expected nested netlink attr data

 ell/genl.c           | 2 +-
 unit/test-genl-msg.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

-- =

2.25.1

--===============4208879141453528020==--

