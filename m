Content-Type: multipart/mixed; boundary="===============4888754909781062284=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] avoid using inet_aton()
Date: Fri, 04 Jun 2021 10:41:38 -0500
Message-ID: <231f352b-41c5-d989-0a6d-cd13ecfd423f@gmail.com>
In-Reply-To: <febf75f8dd0a4a97e4d650a8655752aef0aa685e.1622713571.git.davide.caratti@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4888754909781062284==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Davide,

On 6/3/21 4:50 AM, Davide Caratti wrote:
> use inet_pton(AF_INET,...), like it's done elsewhere for IPv6.
> =

> Signed-off-by: Davide Caratti <davide.caratti@gmail.com>

We do not use Signed-off-by here, so I dropped this.

> ---
>   ell/dhcp-server.c | 14 +++++++-------
>   1 file changed, 7 insertions(+), 7 deletions(-)
> =


Applied, thanks.

Regards,
-Denis
--===============4888754909781062284==--

