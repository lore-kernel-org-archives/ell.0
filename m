Content-Type: multipart/mixed; boundary="===============2159287913589793139=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: AEAD ciphers work with kernel v4.9
Date: Tue, 17 Jan 2017 16:22:20 -0800
Message-ID: <alpine.OSX.2.20.1701171614020.3252@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2159287913589793139==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


In the commit message for the AEAD cipher API, I noted that kernel v4.10 =

or later were needed. The required kernel patches made it in to v4.9, so =

test-cipher is passing. I checked using Fedora's v4.9.3 kernel which =

doesn't have any AEAD-related changes relative to v4.9.

--
Mat Martineau
Intel OTC

--===============2159287913589793139==--

