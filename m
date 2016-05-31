Content-Type: multipart/mixed; boundary="===============3297603852616470146=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Updated kernel tree for ELL development
Date: Tue, 31 May 2016 15:44:05 -0700
Message-ID: <alpine.OSX.2.20.1605311517180.4028@mjmartin-mac01.local>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3297603852616470146==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Hello -

I have a kernel.org repo set up now:

https://git.kernel.org/cgit/linux/kernel/git/martineau/linux.git/

The "ell-key-crypto" branch has the patches to enable Diffie-Hellman and =

AF_ALG akcipher operations. I will force-push to this branch as the =

various patch sets are updated, so if you use this branch as a basis for =

your own development you will have to rebase periodically.

To build for your environment, copy your system's current kernel config in =

to your kernel working directory and update the kernel configuration:

$ cp /boot/config-<recent kernel-version> .config
$ make olddefconfig
$ scripts/config --enable CONFIG_KEY_DH_OPERATIONS
$ scripts/config --enable CONFIG_CRYPTO_USER_API_AKCIPHER
$ make olddefconfig

The second "make olddefconfig" gives the Kbuild system a chance to check =

dependencies.

$ make -j$(nproc) bzImage
$ make -j$(nproc) modules
$ sudo make modules_install
$ sudo make install

I've used this approach with the 4.5 kernel and Fedora 23. I'd expect =

things to work smoothly with configs from kernel 4.2/4.3 or newer, but as =

you go older than that we'll have to see how things go.

ELL knows how to use the Diffie-Hellman functionality in the above kernel. =

I'm working on keyring patches that include certificate validation, and =

updating the ELL cipher functions to use the above kernel.

--
Mat Martineau
Intel OTC

--===============3297603852616470146==--

