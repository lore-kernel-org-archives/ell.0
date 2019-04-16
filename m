Content-Type: multipart/mixed; boundary="===============2088121487730483840=="
MIME-Version: 1.0
From: Ramon Ribeiro <rhpr@cesar.org.br>
Subject: [PATCH v2 0/2] Allow connection to a tcp dbus address
Date: Tue, 16 Apr 2019 10:05:36 -0300
Message-ID: <1555419938-28430-1-git-send-email-rhpr@cesar.org.br>
In-Reply-To: <1555331007-26977-1-git-send-email-rhpr@cesar.org.br>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2088121487730483840==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Changes from v1 to v2:
 - Use l_io instead of select, to avoid blocking main loop.

Indeed this approach of using select is not the best. Thanks for the review.

Ramon Ribeiro (2):
  dbus: Add support to tcp address
  unit: dbus: Add unit test to dbus tcp address

 .gitignore           |   1 +
 Makefile.am          |   3 +
 ell/dbus.c           | 125 +++++++++++++++++++++++-
 unit/dbus.conf       |   2 +
 unit/test-dbus-tcp.c | 261 +++++++++++++++++++++++++++++++++++++++++++++++=
++++
 5 files changed, 387 insertions(+), 5 deletions(-)
 create mode 100644 unit/test-dbus-tcp.c

-- =

2.7.4


--===============2088121487730483840==--

