Content-Type: multipart/mixed; boundary="===============6247500254367299724=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 1/9] dhcp: release lease when client stops
Date: Mon, 23 Nov 2020 13:50:17 -0600
Message-ID: <a64643ee-d8fd-5f53-8ea1-05e7066f6f03@gmail.com>
In-Reply-To: <20201123184740.4023017-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6247500254367299724==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 11/23/20 12:47 PM, James Prestwood wrote:
> RFC 2131 does not explicitly require this but clients MAY
> release their IP address when they are done using it, e.g.
> when shutting down. This is also described as a "graceful shutdown"
> so its probably best the DHCP client does this.
> ---
>   ell/dhcp.c | 74 +++++++++++++++++++++++++++++++++++++++++++++++-------
>   1 file changed, 65 insertions(+), 9 deletions(-)
> =

> v2:
>   * Send release in BOUND, RENEW, and REBINDING states
> =


Patch 1-2, 4-5 applied, thanks.

Regards,
-Denis

--===============6247500254367299724==--

