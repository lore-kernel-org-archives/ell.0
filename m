Content-Type: multipart/mixed; boundary="===============1357930649392921185=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] Add logging if bind function fails
Date: Thu, 01 Jul 2021 10:31:18 -0500
Message-ID: <43e12a7d-2fc6-452d-27a3-9af9f686634b@gmail.com>
In-Reply-To: <20210630135112.47106-1-mjohnson459@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1357930649392921185==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Michael,

On 6/30/21 8:51 AM, Michael Johnson wrote:
> The bind function returns any errors it encounters but they were
> silently being discarded in this method. This at least logs this if
> debug messages are enabled.
> =

> In the future it would be nice to have this log even if the debug output
> isn't enabled as DHCP will not be working correctly.
> ---
>   ell/dhcp.c | 11 ++++++++---
>   1 file changed, 8 insertions(+), 3 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============1357930649392921185==--

