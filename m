Content-Type: multipart/mixed; boundary="===============7768434664191885950=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: New kernel TLS code
Date: Thu, 15 Jun 2017 17:05:10 -0700
Message-ID: <alpine.OSX.2.21.1706151646420.33450@jrhamric-mobl03.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7768434664191885950==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


The kernel TLS patches were merged to net-next today, which puts them on =

track for v4.13:

https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git/commit/?=
id=3D108ea51412a7fddcd0a39efe564dffd47a033e6c

So far only outgoing encryption is handled in the kernel. The handshake =

must still be handled by userspace code. Since ELL's tls implementation =

can be used separately from TCP (as iwd does), ELL can't rely on kernel =

TLS entirely. However, using kernel TLS for TCP sockets would eliminate =

the extra system calls to handle encryption using AF_ALG.

I think it's early to build support in to ELL, but we should keep this on =

our radar.

--
Mat Martineau
Intel OTC

--===============7768434664191885950==--

