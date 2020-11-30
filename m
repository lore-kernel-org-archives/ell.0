Content-Type: multipart/mixed; boundary="===============8433238550185100144=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [BUG] ELL doesn't have a fallback for rawmemchr
Date: Mon, 30 Nov 2020 13:05:07 -0600
Message-ID: <3ebc8c31-27ab-eaed-e6bf-4648bf5e6990@gmail.com>
In-Reply-To: <C7GR3VAGOXZZ.37PH59CQ2TJO2@mussels>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8433238550185100144==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi =C3=89rico,

On 11/30/20 10:49 AM, =C3=89rico Nogueira wrote:
> Hi!
> =

> Building ELL 0.35 on a musl system fails, due to ell/pem.c using
> rawmemchr(), which is a glibc extension. Building IWD with internal
> ELL fails for the same reason.

Thanks for reporting this.

> =

> I see that IWD itself has src/missing.h with a fallback, but ELL lacks
> that.

I ported the rawmemchr bits in missing.h from iwd to ell in commit =

3916c1cc32be205e185a8a56de5cde1b9ec60e81.

Regards,
-Denis
--===============8433238550185100144==--

