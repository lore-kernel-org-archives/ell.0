Content-Type: multipart/mixed; boundary="===============6046390601542268542=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 09/11] netconfig: Exit on errors in
 netconfig_dhcp_event_handler
Date: Mon, 18 Apr 2022 16:12:15 -0500
Message-ID: <ec299bb7-d0a9-32bb-b597-9ea261da1831@gmail.com>
In-Reply-To: 20220411142056.817784-9-andrew.zaborowski@intel.com

--===============6046390601542268542==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/11/22 09:20, Andrew Zaborowski wrote:
> Don't just warn on errors that could cause a crash later in the function
> even though in theory they can't happen.
> ---
>   ell/netconfig.c | 18 ++++++++++++------
>   1 file changed, 12 insertions(+), 6 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============6046390601542268542==--

