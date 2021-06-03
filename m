Content-Type: multipart/mixed; boundary="===============6719410221468782191=="
MIME-Version: 1.0
From: Davide Caratti <davide.caratti@gmail.com>
Subject: [PATCH 0/2] avoid using inet_ntoa() and inet_aton()
Date: Thu, 03 Jun 2021 11:50:01 +0200
Message-ID: <cover.1622713571.git.davide.caratti@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6719410221468782191==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

some static checkers, like rpminspect, complain about use of "forbidden"
functions inet_aton() and inet_ntoa(). Use inet_pton() and inet_ntop()
instead.


Davide Caratti (2):
  avoid using inet_ntoa()
  avoid using inet_aton()

 ell/acd.c                    |  5 +++--
 ell/dhcp-lease.c             |  3 ++-
 ell/dhcp-server.c            | 25 ++++++++++++++-----------
 ell/dhcp.c                   | 17 +++++++++++++++--
 ell/rtnl.c                   |  7 +++++--
 examples/https-server-test.c |  4 +++-
 6 files changed, 42 insertions(+), 19 deletions(-)

-- =

2.31.1

--===============6719410221468782191==--

