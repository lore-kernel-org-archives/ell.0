Content-Type: multipart/mixed; boundary="===============3011731277478553850=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v4] unit: Added generic netlink family unit test
Date: Tue, 21 Mar 2017 16:58:39 -0500
Message-ID: <82399873-850a-e1b6-850b-01cda2af820d@gmail.com>
In-Reply-To: <1490130945-15382-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3011731277478553850==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 03/21/2017 04:15 PM, Ossama Othman wrote:
> ---
>  unit/test-genl.c | 43 ++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 40 insertions(+), 3 deletions(-)
>

< snip>

> +	l_genl_family_set_watches(family,
> +				  NULL,
> +				  family_vanished,
> +				  &vanished_called,
> +				  NULL);
> +

We don't use mixed tabs & spaces for indentation, so I fixed this up to =

only use tabs and applied this patch.

Thanks!

Regards,
-Denis


--===============3011731277478553850==--

