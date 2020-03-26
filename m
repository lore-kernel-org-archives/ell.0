Content-Type: multipart/mixed; boundary="===============3287305537234892441=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] settings: Parse non-base-10 integer settings
Date: Thu, 26 Mar 2020 18:15:35 +0000
Message-ID: <542cc3f3-f212-91e4-6baa-0d65bc26fb50@gmail.com>
In-Reply-To: <20200325201805.4801-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3287305537234892441==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

hi Andrew,

On 3/25/20 3:18 PM, Andrew Zaborowski wrote:
> Change the stro{,u}{l,ll} base parameter to 0 to not disallow hex or
> octal numbers, useful for bitmasks.
> ---
>   ell/settings.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)

Applied, thanks.

Regards,
-Denis

--===============3287305537234892441==--

