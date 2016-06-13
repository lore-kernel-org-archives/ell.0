Content-Type: multipart/mixed; boundary="===============3906593894347746295=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v3 3/5] cipher: Return result length from asymmetric cipher
Date: Mon, 13 Jun 2016 13:59:43 -0700
Message-ID: <alpine.OSX.2.20.1606131357120.6829@mjmartin-mac01.local>
In-Reply-To: <20160610170910.20259-3-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3906593894347746295==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Fri, 10 Jun 2016, Mat Martineau wrote:

> Short reads from AF_ALG akcipher sockets can return an error rather
> than a partial buffer so it's important to provide both an output
> buffer length (which is typically longer than the expected data), and
> to find out how many bytes were read.
> ---
> ell/cipher.c      | 31 +++++++++-----------
> ell/cipher.h      | 16 +++++------
> ell/tls-private.h |  2 +-
> ell/tls.c         | 86 ++++++++++++++++++++++++++++++++++++--------------=
-----
> 4 files changed, 80 insertions(+), 55 deletions(-)
>
> diff --git a/ell/cipher.c b/ell/cipher.c
> index f23bdda..e370a0e 100644
> --- a/ell/cipher.c
> +++ b/ell/cipher.c
> @@ -222,10 +222,7 @@ static bool operate_cipher(int sk, __u32 operation,
> 	if (sendmsg(sk, &msg, 0) < 0)
> 		return false;

'return false' won't look like an error to the caller, I'll change it to =

return an informative error number.

>
> -	if (read(sk, out, len_out) < 0)
> -		return false;
> -
> -	return true;
> +	return read(sk, out, len_out);
> }
>
> LIB_EXPORT bool l_cipher_encrypt(struct l_cipher *cipher,

--
Mat Martineau
Intel OTC

--===============3906593894347746295==--

