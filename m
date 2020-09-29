Content-Type: multipart/mixed; boundary="===============3873200962888715002=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp6: change option code to uint16_t
Date: Tue, 29 Sep 2020 12:59:00 -0500
Message-ID: <d626c7d4-4895-a427-3e83-11dd97a07cf5@gmail.com>
In-Reply-To: <20200928173656.194761-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3873200962888715002==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 9/28/20 12:36 PM, James Prestwood wrote:
> GCC-10 appears to have gotten "smarter" (or pickier) and passing
> unnamed enums as an argument expecting a named enum results in
> an error. The internal APIs in dhcp6 have been changed to take a
> uint16_t instead of enum l_dhcp6_option. This allows both public
> and internal DHCP options to be passed to these builder APIs.
> ---
>   ell/dhcp6.c | 10 ++++------
>   1 file changed, 4 insertions(+), 6 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============3873200962888715002==--

