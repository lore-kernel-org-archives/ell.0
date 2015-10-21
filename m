Content-Type: multipart/mixed; boundary="===============9005841850059879844=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] uintset: Fix memory leak in l_uintset_new_from_range
Date: Wed, 21 Oct 2015 18:25:52 -0500
Message-ID: <56281F00.2020101@gmail.com>
In-Reply-To: <1445461995-22036-1-git-send-email-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9005841850059879844==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Szymon,

On 10/21/2015 04:13 PM, Szymon Janc wrote:
> Allocate ret only after checking size parameter.
> ---
>   ell/uintset.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>

All four applied.  Some of the mistakes fixed were embarassing :(

Thanks!

Regards,
-Denis


--===============9005841850059879844==--

