Content-Type: multipart/mixed; boundary="===============5443237936354507106=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] key: Add placeholder arg to Diffie-Hellman syscall
Date: Fri, 24 Jun 2016 17:36:33 -0500
Message-ID: <576DB5F1.7080807@gmail.com>
In-Reply-To: <20160624222225.12042-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5443237936354507106==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/24/2016 05:22 PM, Mat Martineau wrote:
> The final version of the KEYCTL_DH_COMPUTE syscall that went in to
> kernel 4.7 added a reserved arg. In the future, this arg will be used
> to optionally specify a key derivation function. For now, it's needed
> so the system call doesn't return -1 (errno =3D=3D EINVAL) every time.
> ---
>   ell/key.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>

Applied, thanks.

Regards,
-Denis


--===============5443237936354507106==--

