Content-Type: multipart/mixed; boundary="===============5497333223647314526=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 02/17] checksum: Add l_checksum_clone API.
Date: Fri, 24 Jul 2015 10:55:58 -0500
Message-ID: <55B2600E.7070706@gmail.com>
In-Reply-To: <1437708410-28075-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5497333223647314526==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 07/23/2015 10:26 PM, Andrew Zaborowski wrote:
> In the kernel API we use and also in GLib's API the l_checksum_get_digest=
()
> equivalents can only be called once on each object meaning that in a
> situation when multiple digest values at different points of a
> running stream are needed the API becomes impractical.  The new _clone()
> call returns a clone of the checksum's state at the current time, on
> which get_digest() can be called.
> ---
>   ell/checksum.c | 24 ++++++++++++++++++++++++
>   ell/checksum.h |  1 +
>   2 files changed, 25 insertions(+)
>

<snip>

> +LIB_EXPORT struct l_checksum *l_checksum_clone(struct l_checksum *checks=
um)
> +{
> +	struct l_checksum *clone;
> +

Patch has been applied, but I also added a tiny sanity check here to =

make sure that checksum !=3D NULL in a follow-on commit.

Regards,
-Denis

--===============5497333223647314526==--

