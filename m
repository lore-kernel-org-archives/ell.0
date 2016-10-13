Content-Type: multipart/mixed; boundary="===============4139700717477963621=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] key: Fix Valgrind warnings
Date: Wed, 12 Oct 2016 20:18:32 -0500
Message-ID: <57FEE0E8.6030801@gmail.com>
In-Reply-To: <20161012205118.9152-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4139700717477963621==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/12/2016 03:51 PM, Mat Martineau wrote:
> Valgrind doesn't understand all of the keyctl syscalls and how they
> set memory, so clear the encrypt/decrypt/sign output buffer to prevent
> false positives.
>
> ---
>   ell/key.c | 2 ++
>   1 file changed, 2 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============4139700717477963621==--

