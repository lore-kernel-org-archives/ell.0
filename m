Content-Type: multipart/mixed; boundary="===============5154276981542005821=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Fix compile error for 32-bit platforms
Date: Wed, 30 Mar 2016 10:48:10 -0500
Message-ID: <56FBF53A.107@gmail.com>
In-Reply-To: <1459290966-18779-1-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5154276981542005821==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 03/29/2016 05:36 PM, Mat Martineau wrote:
> Error encountered with 32-bit gcc 5.3.1:
>
> ell/dbus-kernel.c:412:20: error: cast from pointer to integer of
> different size [-Werror=3Dpointer-to-int-cast]
>
> Casting the pointer to uintptr_t instead of uint64_t works on both
> 32-bit and 64-bit platforms.
> ---
>   ell/dbus-kernel.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>

Applied, thanks.

Regards,
-Denis


--===============5154276981542005821==--

