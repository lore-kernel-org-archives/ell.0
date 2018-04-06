Content-Type: multipart/mixed; boundary="===============5771233762374978452=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] ell: fix build with musl libc
Date: Fri, 06 Apr 2018 10:29:25 -0500
Message-ID: <1745a1a7-1549-de42-cfa5-88c768d14834@gmail.com>
In-Reply-To: <1522940090-16702-1-git-send-email-maxin.john@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5771233762374978452==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Maxin,

On 04/05/2018 09:54 AM, maxin.john(a)gmail.com wrote:
> From: "Maxin B. John" <maxin.john@intel.com>
> =

> musl libc doesn't implement TEMP_FAILURE_RETRY. Use the
> TEMP_FAILURE_RETRY from glibc to fix build.
> ---
>   ell/dbus.h | 10 ++++++++++
>   1 file changed, 10 insertions(+)
> =


Applied, thanks.

Regards,
-Denis


--===============5771233762374978452==--

