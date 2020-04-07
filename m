Content-Type: multipart/mixed; boundary="===============5886109068252347328=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] ell/ecc.h: fix build with uclibc
Date: Tue, 07 Apr 2020 16:02:07 +0000
Message-ID: <bd38cabc-0ee8-5906-6792-718f4740c0fc@gmail.com>
In-Reply-To: <20200328114041.1084249-1-fontaine.fabrice@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5886109068252347328==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Fabrice,

On 3/28/20 6:40 AM, Fabrice Fontaine wrote:
> ssize_t is defined in sys/types.h
> =

> Fixes:
>   - http://autobuild.buildroot.org/results/444c9deb728fb041e560d940145f96=
cc4f455080
> =

> Signed-off-by: Fabrice Fontaine <fontaine.fabrice@gmail.com>

Dropped the SoB (ell doesn't use these) and applied, thanks.

Regards,
-Denis
--===============5886109068252347328==--

