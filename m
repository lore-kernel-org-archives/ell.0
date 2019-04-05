Content-Type: multipart/mixed; boundary="===============3532534688771592291=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] genl: Be more careful with termination of genl names
Date: Fri, 05 Apr 2019 17:06:07 -0500
Message-ID: <a449f427-2260-5cfa-b515-37da9faedffe@gmail.com>
In-Reply-To: <20190404221303.2452-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3532534688771592291==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 04/04/2019 05:13 PM, Mat Martineau wrote:
> GCC 9 adds "-Werror=3Dstringop-truncation" that warns (and therefore
> triggers a compile error) when strncpy has a size limit that's the same
> as the destination size, which can allow string termination
> problems. Instead, reduce the limit passed to strncpy by 1 and make sure
> the destination is terminated. This appears to be consistent with the
> handling of GENL_NAMSIZ strings in the kernel.
> =

> The fixed-length struct genl_mcast name is also used in a string
> comparison, where the known size limit is now applied.
> ---
>   ell/genl.c | 12 ++++++++----
>   1 file changed, 8 insertions(+), 4 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============3532534688771592291==--

