Content-Type: multipart/mixed; boundary="===============4181779329284809063=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] hashmap: Fix removing last entry in
 l_hashmap_foreach_remove
Date: Sat, 20 Oct 2018 11:02:02 -0500
Message-ID: <a0d4a425-bd4a-daf3-f813-e0595ba40c06@gmail.com>
In-Reply-To: <20181020023347.29555-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4181779329284809063==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 10/19/2018 09:33 PM, Andrew Zaborowski wrote:
> When the last entry in a bucket with 2 or more entries was removed
> the loop would roll over and iterate over the remaining entries for a
> second time (then stop), add missing check.
> ---
>   ell/hashmap.c | 2 ++
>   1 file changed, 2 insertions(+)
> =


Hah, good catch.  Applied, thanks.

Regards,
-Denis


--===============4181779329284809063==--

