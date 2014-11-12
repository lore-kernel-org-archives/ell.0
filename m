Content-Type: multipart/mixed; boundary="===============8800310144689751151=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] idle: Include stdbool.h by default in the header
Date: Wed, 12 Nov 2014 08:08:32 -0600
Message-ID: <546369E0.707@gmail.com>
In-Reply-To: <1415800414-1391-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8800310144689751151==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

On 11/12/2014 07:53 AM, Tomasz Bursztyka wrote:
> ---
> idlers use bool, but it's not included by their header.
> Figured that one when playing with a unit test.
>
>   ell/idle.h | 2 ++
>   1 file changed, 2 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============8800310144689751151==--

