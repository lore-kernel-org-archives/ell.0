Content-Type: multipart/mixed; boundary="===============7489218552411199755=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] rtnl: Make IPv4 and IPv6 naming scheme consistent
Date: Fri, 14 Feb 2020 12:58:50 -0600
Message-ID: <e30cac8e-d66a-e614-350e-46a07fbf2f5e@gmail.com>
In-Reply-To: <20200214182337.11132-2-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7489218552411199755==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Daniel,

On 2/14/20 12:23 PM, Daniel Wagner wrote:
> Add the protocol version into into the function names and drop the
> infix 'ipv6' string. This makes it more consistent with the existing
> APIs.
> ---
>   ell/rtnl.c       | 52 ++++++++++++++++++++++++------------------------
>   ell/rtnl.h       | 28 +++++++++++++-------------
>   unit/test-rtnl.c | 42 +++++++++++++++++++-------------------
>   3 files changed, 61 insertions(+), 61 deletions(-)
> =


Applied after splitting this patch in two.  One for rtnl.[ch] changes =

and one for unit/ directory changes.

Regards,
-Denis

--===============7489218552411199755==--

