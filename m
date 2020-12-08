Content-Type: multipart/mixed; boundary="===============0371883664590178607=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] acd: store IP in network order
Date: Tue, 08 Dec 2020 21:48:16 +0000
Message-ID: <1c222d93-9496-96bf-d32d-9eac3a59be91@gmail.com>
In-Reply-To: <20201208184228.751111-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0371883664590178607==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 12/8/20 12:42 PM, James Prestwood wrote:
> The IP target was being converted into host order during
> l_acd_start, which required converting back to network order
> many times throughout the ACD process. Instead just leave
> the IP in network order and use directly. This avoids the
> need for conversions and additional temporary variables.
> ---
>   ell/acd.c | 24 +++++++++---------------
>   1 file changed, 9 insertions(+), 15 deletions(-)

All applied, thanks.

Regards,
-Denis

--===============0371883664590178607==--

