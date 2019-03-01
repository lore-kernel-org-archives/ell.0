Content-Type: multipart/mixed; boundary="===============1016404787309690433=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/2] uintset: NULL-check before use
Date: Thu, 28 Feb 2019 19:55:08 -0600
Message-ID: <ef490646-6751-2306-a63f-79d15c3bb28a@gmail.com>
In-Reply-To: <20190301010118.32494-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1016404787309690433==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 02/28/2019 07:01 PM, Tim Kourt wrote:
> Postpone the variable usage until after the set is NULL-checked.
> ---
>   ell/uintset.c | 10 +++++++---
>   1 file changed, 7 insertions(+), 3 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis


--===============1016404787309690433==--

