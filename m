Content-Type: multipart/mixed; boundary="===============1112810674694022145=="
MIME-Version: 1.0
From: Thomas Petazzoni <thomas.petazzoni@bootlin.com>
Subject: ell 0.31 fails to build with pre-4.12 kernel headers
Date: Sun, 07 Jun 2020 10:51:07 +0200
Message-ID: <20200607105107.3e4158de@windsurf>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1112810674694022145==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hello,

Since commit fa950995a48bbcd8f0d3dfbbe9a7f768aba5c50f ("genl: enable
extended error messages"), ell makes use of the extended ACK reporting
mechanism added by Linux commit
2d4bc93368f5a0ddb57c8c885cdad9c9b7a10ed5.

Due to this, the build of ell 0.31 fails when the toolchain uses kernel
headers older than Linux 4.12, as NLM_F_ACK_TLVS and NETLINK_EXT_ACK
are not defined.

See an example build failure:

  http://autobuild.buildroot.net/results/baf/bafc0ee2a3bcb2418a3612da38eb9d=
cd586b57d4/build-end.log

It would probably be good to make this feature optional in ell, based
on some configure.ac checks of the availability of extended ACK
reporting.

Thanks!

Thomas
-- =

Thomas Petazzoni, CTO, Bootlin
Embedded Linux and Kernel engineering
https://bootlin.com
--===============1112810674694022145==--

