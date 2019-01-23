Content-Type: multipart/mixed; boundary="===============3900397839910503310=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] key: Work around keyctl_dh_params breakage in certain
 stable kernels
Date: Wed, 23 Jan 2019 17:21:05 -0600
Message-ID: <0f2e5486-c23a-60d2-0615-b87953f01d7a@gmail.com>
In-Reply-To: <20190123224323.18586-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3900397839910503310==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 01/23/2019 04:43 PM, Mat Martineau wrote:
> These stable kernels had a change which renamed one of the members of
> struct keyctl_dh_params and broke the ELL build:
> =

> v4.14.70, v4.14.71, v4.14.72
> v4.18.8, v4.18.9, v4.18.10
> =

> Later stable releases in the v4.14.x and v4.18.x series reverted to the
> previous member name.
> =

> This change allows ELL to build using the kernel declaration of the
> struct for v4.20 and later, and provides a correct structure declaration
> for older kernels.
> ---
>   ell/key.c | 26 +++++++++++++++++---------
>   1 file changed, 17 insertions(+), 9 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============3900397839910503310==--

