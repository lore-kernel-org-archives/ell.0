Content-Type: multipart/mixed; boundary="===============6231040984278111640=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] ell: avoid using inet_ntoa()
Date: Fri, 18 Jun 2021 09:54:13 -0500
Message-ID: <1bc16daf-f783-201c-802f-600721d2f8d2@gmail.com>
In-Reply-To: <144affac0389b92896ae152643610b6ec497a398.1623871292.git.davide.caratti@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6231040984278111640==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Davide,

On 6/16/21 2:22 PM, Davide Caratti wrote:
> static checkers (like rpminspect) complain about use of inet_ntoa(), as
> it relies on a static buffer. Fix this as follows:
> =

>   - use inet_ntop() with a buffer of size INET_ADDRSTRLEN allocated in
>     the stack, similarly to what it is already done for IPv6 addresses
>   - convert IP_STR() to use NIPQUAD() / NIPQUAD_FMT, similarly to what
>     is done with MAC addresses
> ---
>   ell/acd.c         | 28 +++++++++++++---------------
>   ell/dhcp-lease.c  |  3 ++-
>   ell/dhcp-server.c | 37 ++++++++++++++++++-------------------
>   ell/dhcp.c        |  6 ++++--
>   ell/rtnl.c        |  7 +++++--
>   5 files changed, 42 insertions(+), 39 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis

--===============6231040984278111640==--

