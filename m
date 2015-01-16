Content-Type: multipart/mixed; boundary="===============7134742606620729565=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/2] Introduce l_memdup function
Date: Fri, 16 Jan 2015 10:50:04 -0600
Message-ID: <54B9413C.1080804@gmail.com>
In-Reply-To: <1421399632-19544-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7134742606620729565==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 01/16/2015 03:13 AM, Jukka Rissanen wrote:
> Hi,
>
> this patch introduces new l_memdup() function in patch 1.
>
> The new function is then used in patch 2. The genl.c was the only
> place in the code base where such a change could be done (at least I
> could not spot any other place having malloc+memcpy in the code after
> quick review).
>
> Cheers,
> Jukka
>

Both applied, thanks.

Regards,
-Denis

--===============7134742606620729565==--

