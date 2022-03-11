Content-Type: multipart/mixed; boundary="===============1119164645463257856=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 12/12] examples: Add a netconfig API example/test utility
Date: Fri, 11 Mar 2022 10:25:06 -0600
Message-ID: <5dee9a96-14be-5a62-f021-fbae0cab2e78@gmail.com>
In-Reply-To: 20220307145543.1558788-12-andrew.zaborowski@intel.com

--===============1119164645463257856==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/7/22 08:55, Andrew Zaborowski wrote:
> A test utility that simply starts netconfig on a given interface and
> prints events that occur.  DNS/mdns changes aren't committed to the
> system.
> ---
>   Makefile.am               |   4 +-
>   examples/netconfig-test.c | 208 ++++++++++++++++++++++++++++++++++++++
>   2 files changed, 211 insertions(+), 1 deletion(-)
>   create mode 100644 examples/netconfig-test.c
> =


Applied with a minor amend to get rid of a >80 char line.

Regards,
-Denis

--===============1119164645463257856==--

