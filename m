Content-Type: multipart/mixed; boundary="===============5352682853578352979=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: ell-key-crypto kernel branch updated for v4.8
Date: Fri, 23 Sep 2016 16:14:46 -0700
Message-ID: <alpine.OSX.2.20.1609231603510.50308@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5352682853578352979==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Hello -

To go along with today's ELL patch set, there's an updated ell-key-crypto =

branch on git.kernel.org:

https://git.kernel.org/cgit/linux/kernel/git/martineau/linux.git/

This is based on v4.8-rc1 of the kernel and includes:

   * linux-fs/keys-next (for keyctl crypto ops)
   * My keyctl restricted keyring patch set
   * Denis' nl80211 patches

Note that the branch no longer includes the AF_ALG akcipher patch set, as =

it did for v4.7 and earlier. The previous v4.7 key crypto kernel is tagged =

as ell-key-crypto-47.

Relative to my Fedora 24 kernel 4.7 config, the following commands will =

enable the required config options:

$ cp /boot/config-<recent kernel-version> .config
$ scripts/config --enable CONFIG_KEY_DH_OPERATIONS
$ scripts/config --enable CONFIG_PKCS8_PRIVATE_KEY_PARSER
$ make olddefconfig

--
Mat Martineau
Intel OTC

--===============5352682853578352979==--

