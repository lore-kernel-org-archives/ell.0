Content-Type: multipart/mixed; boundary="===============0968649800397350836=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp-server: Simplify timeout handling
Date: Fri, 11 Jun 2021 09:42:19 -0500
Message-ID: <4b703293-8b07-2443-2f93-41a15e5dd21f@gmail.com>
In-Reply-To: <20210610212033.338502-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0968649800397350836==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 6/10/21 4:20 PM, Andrew Zaborowski wrote:
> Remove max timeout interval checks no longer useful after
> the l_timeout_modify_ms() parameter type change.
> ---
>   ell/dhcp-server.c | 15 ++-------------
>   1 file changed, 2 insertions(+), 13 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============0968649800397350836==--

