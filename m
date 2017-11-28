Content-Type: multipart/mixed; boundary="===============5689123316324127450=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] build: Fix parallel build
Date: Tue, 28 Nov 2017 09:48:33 -0600
Message-ID: <1478df51-46f9-74e4-ecd2-b795fc1f29a1@gmail.com>
In-Reply-To: <20171128132918.28219-1-szymon.janc@codecoup.pl>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5689123316324127450==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Szymon,

On 11/28/2017 07:29 AM, Szymon Janc wrote:
>    GEN      unit/cert-intca.pem
>    GEN      unit/cert-server.pem
>    GEN      unit/cert-chain.pem
>    GEN      unit/cert-entity-int.pem
>    CCLD     unit/test-pem
>    CCLD     unit/test-tls
>    CCLD     unit/test-key
> libtool:   error: cannot find the library 'ell/libell-private.la' or
>      unhandled argument 'ell/libell-private.la'
> make[1]: *** [Makefile:1392: unit/test-tls] Error 1
> make[1]: *** Waiting for unfinished jobs....
> libtool:   error: cannot find the library 'ell/libell-private.la' or
>       unhandled argument 'ell/libell-private.la'
> make[1]: *** [Makefile:1344: unit/test-pem] Error 1
> make: *** [Makefile:1000: all] Error 2
> ---
>   Makefile.am | 6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============5689123316324127450==--

