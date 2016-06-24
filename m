Content-Type: multipart/mixed; boundary="===============3886578752295626203=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH] key: Add placeholder arg to Diffie-Hellman syscall
Date: Fri, 24 Jun 2016 15:20:05 -0700
Message-ID: <alpine.OSX.2.20.1606241518380.31011@mjmartin-mac01.wa.intel.com>
In-Reply-To: <20160624221634.5711-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3886578752295626203==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Fri, 24 Jun 2016, Mat Martineau wrote:

> The final version of the syscall that went in to kernel 4.7 added a
> reserved arg to the KEYCTL_DH_COMPUTE syscall. In the future, this arg
> will be used to optionally specify a key derivation function. For now,
> it's needed so the system call doesn't return -1 (errno =3D=3D EINVAL)
> every time.

Let me tweak this commit message, v2 coming up.

--
Mat Martineau
Intel OTC

--===============3886578752295626203==--

