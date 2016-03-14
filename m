Content-Type: multipart/mixed; boundary="===============0733261940420308054=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH] dbus: Change type for pointer / integer cast to fix
 32-bit break
Date: Mon, 14 Mar 2016 08:18:11 -0700
Message-ID: <alpine.OSX.2.20.1603140817480.1463@mjmartin-mac01.local>
In-Reply-To: <1457968551-14118-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0733261940420308054==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable



On Mon, 14 Mar 2016, Mat Martineau wrote:

> Casting void* to uint64_t on 32-bit x86 causes a build error with gcc
> 5.9.1, so cast to uintptr_t instead.

Wrong compiler version - stand by for v2 of this patch.

--
Mat Martineau
Intel OTC



--===============0733261940420308054==--

