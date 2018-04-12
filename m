Content-Type: multipart/mixed; boundary="===============3884430935750815542=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] net: fix include error
Date: Thu, 12 Apr 2018 14:34:51 -0500
Message-ID: <c3ff3bcd-55ce-8aa9-4536-f0332a9abd10@gmail.com>
In-Reply-To: <1523554136-9237-1-git-send-email-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3884430935750815542==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 04/12/2018 12:28 PM, James Prestwood wrote:
> sys/socket.h needed to be included before linux/if_arp.h
> to fix a build error.
> ---
>   ell/net.c | 1 +
>   1 file changed, 1 insertion(+)
> =


Applied, thanks.

Regards,
-Denis


--===============3884430935750815542==--

