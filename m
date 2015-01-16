Content-Type: multipart/mixed; boundary="===============1325346756742396446=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] hashmap: Entry pointers were not freed when map was
 destroyed
Date: Thu, 15 Jan 2015 23:43:21 -0600
Message-ID: <54B8A4F9.7090500@gmail.com>
In-Reply-To: <1421153775-30398-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1325346756742396446==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 01/13/2015 06:56 AM, Jukka Rissanen wrote:
> The l_hashmap_destroy() did not free the left over entry pointers
> that were allocated in l_hashmap_insert(). If user did not remove
> them by calling the l_hashmap_remove(), then the entries were left
> in the hash which caused a memory leak.
> ---
>   ell/hashmap.c | 11 ++++++++---
>   1 file changed, 8 insertions(+), 3 deletions(-)
>

Patch has been applied, thanks.

Regards,
-Denis



--===============1325346756742396446==--

