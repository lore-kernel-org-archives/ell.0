Content-Type: multipart/mixed; boundary="===============7202072308107579328=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 3/3] unit: Add Diffie-Hellman tests
Date: Tue, 12 Apr 2016 12:41:52 -0700
Message-ID: <alpine.OSX.2.20.1604121234420.4549@mjmartin-mac01.local>
In-Reply-To: <1460479364-14478-3-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7202072308107579328==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


The "KEYS: Add KEYCTL_DH_COMPUTE command" kernel commit (ddbb4114) is =

required to use the DH feature in ELL. It's currently available in the =

keys-next branch:

https://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/

CONFIG_KEY_DH_OPERATIONS must be enabled.

--
Mat Martineau
Intel OTC

--===============7202072308107579328==--

