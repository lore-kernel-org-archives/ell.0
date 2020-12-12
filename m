Content-Type: multipart/mixed; boundary="===============8921675890890526404=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dhcp: add ACD to DHCP client
Date: Sat, 12 Dec 2020 03:07:41 +0000
Message-ID: <e8c75936-a002-868e-b976-edc0d6d9d852@gmail.com>
In-Reply-To: <20201210173958.873756-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8921675890890526404==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 12/10/20 11:39 AM, James Prestwood wrote:
> This starts the ACD client once DHCP binds to an address.
> The ACD client is (for now) configured to defend its address
> infinitely. This maintains existing behavior except that
> ACD announcements are now sent if conflicts are detected.
> ---
>   ell/dhcp.c | 43 +++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 43 insertions(+)
> =


Both applied, thanks

Regards,
-Denis

--===============8921675890890526404==--

