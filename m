Content-Type: multipart/mixed; boundary="===============4039098746356516653=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] dhcp-server: Fix double free in
 l_dhcp_server_expire_by_mac
Date: Thu, 12 Aug 2021 20:27:34 -0500
Message-ID: <69337569-fa53-f3be-90df-63962b2c00b5@gmail.com>
In-Reply-To: <20210806235259.304436-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4039098746356516653==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/6/21 6:52 PM, Andrew Zaborowski wrote:
> When using l_queue_foreach_remove() on lease_list we can't call
> lease_release() because that will try to do l_queue_remove() on the same
> queue, in addition to all the things we need it to do.
> ---
>   ell/dhcp-server.c | 21 +++++++++++++++++++--
>   1 file changed, 19 insertions(+), 2 deletions(-)
> =


All applied, thanks.

Regards,
-Denis

--===============4039098746356516653==--

