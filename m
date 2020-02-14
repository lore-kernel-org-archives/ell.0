Content-Type: multipart/mixed; boundary="===============4251029385798202964=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/2] Import rntlutil from iwd
Date: Fri, 14 Feb 2020 11:53:29 -0600
Message-ID: <2a22f7b3-6dd3-a011-28ce-d43dce31d762@gmail.com>
In-Reply-To: <20200214163328.17647-1-wagi@monom.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4251029385798202964==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Daniel,

On 2/14/20 10:33 AM, Daniel Wagner wrote:
> This just copies over the code from iwd. No changes there except the
> prefix of the functions name.
> =

> Unfortunatly, the unit test can only test the get/dump function
> because the setters need root permissions. For this we need some sort
> of sandbox. Does anyone have any ideas for this?
> =

> While writing the test case I noticed some inconsistency in the naming
> sceme:
> =

> The IPv6 functions are consistent in the naming sceme, always
> append ipv6 after the first name:
> =

>    rtnl_ifaddr_ipv6_extract
>    rtnl_ifaddr_ipv6_get
>    rtnl_ifaddr_ipv6_add
>    rtnl_ifaddr_ipv6_delete
> =

>    rtnl_route_ipv6_add_gateway
>    rtnl_route_ipv6_delete_gateway
> =

> =

> For the IPv4 functions it's either a plain 'ifaddr' infix or somewhere ip=
v4
> in the name:
> =

> =

>    rtnl_ifaddr_extract
>    rtnl_ifaddr_get
>    rtnl_ifaddr_add
>    rtnl_ifaddr_delete
> =

>    rtnl_route_extract_ipv4
>    rtnl_route_dump_ipv4
> =

>    -> drop ipv4?
> =

>    rtnl_route_ipv4_add_connected
>    rtnl_route_ipv4_add_gateway
> =

>    -> drop ipv4?
> =

> =

> And there are the setters:
> =

>    rtnl_set_linkmode_and_operstate
>    rtnl_set_mac
>    rtnl_set_powered
> =

> =

> Is this the standard naming sceme?
> =


Both applied.  Now lets fix these up as discussed on IRC.

Regards,
-Denis
--===============4251029385798202964==--

