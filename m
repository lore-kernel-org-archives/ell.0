Content-Type: multipart/mixed; boundary="===============4188158746359580684=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/6] dhcp-server: fix incorrect setting of lease OFFER_TIME
Date: Thu, 19 Nov 2020 14:38:25 -0600
Message-ID: <835e66bb-77df-591d-ee84-70abd90035b5@gmail.com>
In-Reply-To: <20201118190056.3584080-2-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4188158746359580684==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 11/18/20 1:00 PM, James Prestwood wrote:
> When in the offer stage the lease expiration was being set to
> OFFER_TIME, rather than the current time plus OFFER_TIME.
> ---
>   ell/dhcp-server.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============4188158746359580684==--

