Content-Type: multipart/mixed; boundary="===============4676829650790382726=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: ell-key-crypto kernel branch updated for v4.9
Date: Wed, 16 Nov 2016 15:11:24 -0800
Message-ID: <alpine.OSX.2.20.1611161458340.67352@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4676829650790382726==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Hello -

There's an updated ell-key-crypto branch on git.kernel.org:

https://git.kernel.org/cgit/linux/kernel/git/martineau/linux.git/

This is based on v4.9-rc5 of the kernel and includes:

    * My keyctl restricted keyring patch set
    * linux-fs/keys-blacklist (as a basis for upstreaming)
    * linux-fs/keys-next (for keyctl crypto ops)
    * A revert commit for an AF_ALG hash commit that caused a kernel crash =

when ELL's unit/test-checksum was run

The nl80211 patches I had been carrying for iwd are part of v4.9.

The previous v4.8 key crypto kernel is tagged as ell-key-crypto-48

Relative to my Fedora 24 kernel 4.8 config, the following commands will
enable the required config options:

$ cp /boot/config-<recent kernel-version> .config
$ scripts/config --enable CONFIG_PKCS8_PRIVATE_KEY_PARSER
$ make olddefconfig

--
Mat Martineau
Intel OTC

--===============4676829650790382726==--

