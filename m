Content-Type: multipart/mixed; boundary="===============0488946694066295513=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] netlink: Automatically request ACKs when a callback
 function is given
Date: Thu, 28 Aug 2014 09:46:09 -0700
Message-ID: <E4188512-1068-45BD-828A-073D9B9D559B@holtmann.org>
In-Reply-To: <1409136550-7780-1-git-send-email-patrik.flykt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0488946694066295513==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Patrik,

> Supplying a callback function without setting NLM_F_ACK results in no
> ACKs to be sent by the kernel and thus the callback will never be called.
> ---
> ell/netlink.c | 3 +++
> 1 file changed, 3 insertions(+)

patch has been applied.

Regards

Marcel


--===============0488946694066295513==--

