Content-Type: multipart/mixed; boundary="===============3302421656357737138=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] key: Auto-free the signature hash in l_key_verify
Date: Wed, 12 Oct 2016 14:06:39 -0500
Message-ID: <57FE89BF.3040600@gmail.com>
In-Reply-To: <20161012190016.8186-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3302421656357737138==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/12/2016 02:00 PM, Mat Martineau wrote:
> This streamlines the existing code by using direct returns rather than a
> goto and gets rid of an extra variable. While it does possibly free some
> memory immediately after allocation when an invalid checksum type is
> requested, this is an uncommon case.
> ---
>   ell/key.c | 29 ++++++++++-------------------
>   1 file changed, 10 insertions(+), 19 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============3302421656357737138==--

