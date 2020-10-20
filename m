Content-Type: multipart/mixed; boundary="===============7734975586137361234=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] build: pass -no-undefined properly
Date: Tue, 20 Oct 2020 10:02:43 -0500
Message-ID: <a6b2cde8-094e-84c2-3273-91cc1fe7dfb4@gmail.com>
In-Reply-To: <20201014104643.3993077-1-ross@burtonini.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7734975586137361234==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ross,

On 10/14/20 5:46 AM, Ross Burton wrote:
> From: Ross Burton <ross.burton@arm.com>
> =

> -no-undefined was added to the libell.la LDFLAGS in commit 8391d72d,
> back in 2012, as part of adding versioning. I believe there was some
> confusion here as passing -no-undefined to libtool is different to
> passing -no-undefined to the linker.  The former changes libtool's
> behaviour on Windows hosts related to static libraries, the latter will
> warn if symbols are used but not defined.
> ---
>   Makefile.am | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Both applied, thanks.

Regards,
-Denis
--===============7734975586137361234==--

