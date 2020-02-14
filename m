Content-Type: multipart/mixed; boundary="===============5856612288623759640=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] rtnl: Rename l_rtnl_ifaddr{4|6|}_get to
 l_rntl_ifaddr{4|6}_dump
Date: Fri, 14 Feb 2020 13:00:38 -0600
Message-ID: <4257e305-c251-fcb4-0d7c-ea0dbf13e5be@gmail.com>
In-Reply-To: <20200214182337.11132-3-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5856612288623759640==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Daniel,

On 2/14/20 12:23 PM, Daniel Wagner wrote:
> These functions use NLM_F_DUMP so rename them accordingly.
> ---
>   ell/rtnl.c       |  4 ++--
>   ell/rtnl.h       |  4 ++--
>   unit/test-rtnl.c | 24 ++++++++++++------------
>   3 files changed, 16 insertions(+), 16 deletions(-)
> =


Applied, also after splitting this into two.

Regards,
-Denis

--===============5856612288623759640==--

