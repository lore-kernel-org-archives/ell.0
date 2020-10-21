Content-Type: multipart/mixed; boundary="===============1713162417433810464=="
MIME-Version: 1.0
From: Natanael Copa <ncopa@alpinelinux.org>
Subject: ell 0.33 test suite fails on big endian machines
Date: Wed, 21 Oct 2020 09:30:00 +0200
Message-ID: <20201021093000.4e6aa340@ncopa-desktop.lan>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1713162417433810464==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi!

On alpine linux edge on s390x:

ncopa-edge-s390x:~/aports/main/ell/src/ell-0.33$ cat test-suite.log =

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
   ell 0.33: ./test-suite.log
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D

# TOTAL: 31
# PASS:  30
# SKIP:  0
# XFAIL: 0
# FAIL:  1
# XPASS: 0
# ERROR: 0

.. contents:: :depth: 2

FAIL: unit/test-dhcp6
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

TEST: option parsing
Assertion failed: dhcp6_message_compare(solicit_data_1, sizeof(solicit_data=
_1), client_packet, client_packet_len) (unit/test-dhcp6.c: test_obtain_leas=
e: 238)
TEST: lease parsing
TEST: obtain lease - no rapid commit
Aborted
FAIL unit/test-dhcp6 (exit status: 134)


Samme seems to happen on mips64.


Test passes on all little endian architectures (x86, x86_64, ppc64le, armv7=
, aarch64)

-nc
--===============1713162417433810464==--

