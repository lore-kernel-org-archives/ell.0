Content-Type: multipart/mixed; boundary="===============1183155647472395394=="
MIME-Version: 1.0
From: ell@ongy.net
Subject: Build ell with clang
Date: Wed, 14 Dec 2016 23:51:17 +0100
Message-ID: <20161214225121.9439-1-ell@ongy.net>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1183155647472395394==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hello,

the following patchseries allows ell to be build with clang.
For clang -Wcast-align has to be removed. I asked about this on
#llvm(a)irc.oftc.net and was told, this is the best option.
They also told me that gcc only actually produces a warning, if the
compilation target does not support unaligned access at all, so for x86
the option does nothing.
It may well be, that gcc will error out as well, if such an architecture
were to be targeted.
It may be better to remove -Wcast-align completely instead of making it
gcc specific, as this patch does.

Regards,
Markus


--===============1183155647472395394==--

