Content-Type: multipart/mixed; boundary="===============5670442939377432824=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: cipher, tls, and keys
Date: Mon, 06 Jun 2016 16:19:45 -0700
Message-ID: <alpine.OSX.2.20.1606061551120.3958@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5670442939377432824==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


So far I've updated the asymmetric cipher code to work with the current =

version of the AF_ALG akcipher interface. This leaves the asymmetric =

cipher & tls disconnected from the new key/keyring code, which doesn't =

take advantage of the kernel's capabilities with akcipher and the keyring.

We have three options:

1. The current code works, so leave it as-is. I took this approach first =

to minimize changes while I got it working.

2. Make use of the keyctl() crypto API that's under review. This has the =

clearest upstream path because it was implemented by the keyring =

maintainer. Would simplify l_asymmetric_cipher code and involve fewer =

syscalls.

3. Continue with AF_ALG but make use of ALG_SET_KEY_ID and =

ALG_SET_PUB_KEY_ID to use keys already in a keyring. Would not be a big =

change, but the kernel patch set is a work in progress and much more =

uncertainty about upstream prospects / timing.


I like #2 because it makes for a clean API and simple userspace =

implementation. Anyone prefer other options?

--
Mat Martineau
Intel OTC

--===============5670442939377432824==--

