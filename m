Content-Type: multipart/mixed; boundary="===============2107314686842915149=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH v2 1/3] dhcp: Add priority to logging
Date: Tue, 17 May 2022 12:02:58 -0500
Message-ID: <b8567e94-89b2-8954-4063-c31484993a43@gmail.com>
In-Reply-To: 20220517165638.139029-1-mjohnson459@gmail.com

--===============2107314686842915149==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Michael,

On 5/17/22 11:56, Michael Johnson wrote:
> Most dhcp clients have some logging to show what state the lease is in
> so this just makes iwd more in line with them. The logging won't be
> enabled by default but requires a max logging level to be passed in when
> logging is set up.
> ---
>   ell/dhcp.c | 48 +++++++++++++++++++++++++++++-------------------
>   ell/dhcp.h |  2 +-
>   2 files changed, 30 insertions(+), 20 deletions(-)

All applied, thanks!  I did amend patch 1 & 3 slightly to break up lines th=
at =

were > 80 chars.

Regards,
-Denis
--===============2107314686842915149==--

