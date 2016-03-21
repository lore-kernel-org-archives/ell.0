Content-Type: multipart/mixed; boundary="===============7093919393827325617=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: Add int64_t casts in dbus tests failing on i386.
Date: Mon, 21 Mar 2016 11:44:59 -0500
Message-ID: <56F0250B.7020100@gmail.com>
In-Reply-To: <1458367247-14607-3-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7093919393827325617==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/19/2016 01:00 AM, Andrew Zaborowski wrote:
> Make sure the values are passed as 64-bit ones, adding LL would probably
> also work for gcc.
> ---
>   unit/test-dbus-message.c     | 2 +-
>   unit/test-gvariant-message.c | 3 ++-
>   2 files changed, 3 insertions(+), 2 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============7093919393827325617==--

