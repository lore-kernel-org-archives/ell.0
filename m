Content-Type: multipart/mixed; boundary="===============1442790255187847630=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: ell-key-crypto kernel branch updated
Date: Fri, 24 Jun 2016 15:55:03 -0700
Message-ID: <alpine.OSX.2.20.1606241540040.31011@mjmartin-mac01.wa.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1442790255187847630==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Hello -

I've updated the ell-key-crypto kernel branch at =

https://git.kernel.org/cgit/linux/kernel/git/martineau/linux.git/

This branch is based on v4.7rc2 and consists of:

  * linux-fs/keys-next (for keyctl crypto ops)
  * AF_ALG akcipher v8 patch set
  * My keyctl restricted keyring patch set (v3)

For more background, see =

https://lists.01.org/pipermail/ell/2016-May/000668.html

CONFIG_PKCS8_PRIVATE_KEY_PARSER is also required, so update the =

configuration instructions to:

$ cp /boot/config-<recent kernel-version> .config
$ make olddefconfig
$ scripts/config --enable CONFIG_KEY_DH_OPERATIONS
$ scripts/config --enable CONFIG_CRYPTO_USER_API_AKCIPHER
$ scripts/config --enable CONFIG_PKCS8_PRIVATE_KEY_PARSER
$ make olddefconfig

--
Mat Martineau
Intel OTC

--===============1442790255187847630==--

