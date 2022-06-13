Content-Type: multipart/mixed; boundary="===============5389143070786928482=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/3] acd: Emit event as the last statement in handler
Date: Mon, 13 Jun 2022 11:33:39 -0500
Message-ID: <e67cd416-ae14-c44e-7006-d13d0421ec7c@gmail.com>
In-Reply-To: 20220611014545.1466270-1-andrew.zaborowski@intel.com

--===============5389143070786928482==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 6/10/22 20:45, Andrew Zaborowski wrote:
> Move l_acd_stop() to before the call to the event handler for
> L_ACD_EVENT_LOST to allow the handler to free the l_acd instance if
> needed.
> ---
>   ell/acd.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
> =


All applied, thanks.

Regards,
-Denis

--===============5389143070786928482==--

