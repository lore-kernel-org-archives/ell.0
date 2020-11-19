Content-Type: multipart/mixed; boundary="===============3127730853132232910=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/6] dhcp-server: print actual lifetime for new lease
Date: Thu, 19 Nov 2020 14:40:32 -0600
Message-ID: <e6a80bd9-cedb-b9f3-0706-97821499b995@gmail.com>
In-Reply-To: <20201118190056.3584080-6-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3127730853132232910==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 11/18/20 1:00 PM, James Prestwood wrote:
> The leases expiration time was being printed, which is an
> offset off the current time rather than the actual lease
> time.
> ---
>   ell/dhcp-server.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis

--===============3127730853132232910==--

