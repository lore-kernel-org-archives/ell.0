Content-Type: multipart/mixed; boundary="===============5714594203349340848=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/3] rtnl: add missing APIs
Date: Fri, 14 Feb 2020 13:05:15 -0600
Message-ID: <d0019dfc-2df9-6d22-c8d3-c594e77f02c2@gmail.com>
In-Reply-To: <20200214185253.32658-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5714594203349340848==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Daniel,

On 2/14/20 12:52 PM, Daniel Wagner wrote:
> The first two patches make the API for both protocol version
> complete. The last patch adds the table, priority and preference to
> the extract functions, which is a very uselful information.
> =

> This series is based on the cleanup series send before.
> =

> Daniel Wagner (3):
>    rtnl: Add l_rtnl_route6_dump() and l_rtnl_route6_extract()
>    unit: Add unit test for l_rtnl_route6_{dump|extract}
>    rtnl: Extract table, priority and pref
> =

>   ell/rtnl.c       | 130 ++++++++++++++++++++++++++++++++---------------
>   ell/rtnl.h       |  10 +++-
>   unit/test-rtnl.c |  42 +++++++++++++--
>   3 files changed, 137 insertions(+), 45 deletions(-)
> =


All applied.  I did split the last patch into two.

Regards,
-Denis
--===============5714594203349340848==--

