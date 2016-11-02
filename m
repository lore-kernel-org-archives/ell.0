Content-Type: multipart/mixed; boundary="===============1266401662780423249=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/5] timeout: Add millisecond timeout functions,
 remove nanosecond functions
Date: Wed, 02 Nov 2016 17:23:58 -0500
Message-ID: <581A677E.5050008@gmail.com>
In-Reply-To: <20161102215048.19166-3-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1266401662780423249==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 11/02/2016 04:50 PM, Mat Martineau wrote:
> Nanosecond resolution was overkill, but there are still common use cases
> for millisecond timer resolution.
> ---
>   ell/timeout.c | 109 +++++++++++++++++++++++++++++++++++++++++----------=
-------
>   ell/timeout.h |   8 ++---
>   2 files changed, 82 insertions(+), 35 deletions(-)
>

Patches 3-5 applied, thanks.

Regards,
-Denis


--===============1266401662780423249==--

