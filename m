Content-Type: multipart/mixed; boundary="===============4945127278910137596=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 06/17] netconfig: Avoid returning internal l_queues
Date: Wed, 18 May 2022 13:54:21 -0500
Message-ID: <4e3ca16b-4e2d-4873-6271-9055ef6a73b5@gmail.com>
In-Reply-To: 20220513224713.1447773-6-andrew.zaborowski@intel.com

--===============4945127278910137596==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/13/22 17:47, Andrew Zaborowski wrote:
> Return const struct l_queue_entry pointers instead.
> ---
>   ell/netconfig.c | 35 ++++++++++++++++++-----------------
>   ell/netconfig.h | 20 +++++++++++---------
>   2 files changed, 29 insertions(+), 26 deletions(-)
> =


No objections to this, but I wish examples/ changes were right after this p=
atch :)

Regards,
-Denis

--===============4945127278910137596==--

