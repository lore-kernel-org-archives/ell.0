Content-Type: multipart/mixed; boundary="===============3232106304095749584=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] netlink: Don't change error code signs
Date: Thu, 04 Oct 2018 20:53:41 -0500
Message-ID: <5d606172-5763-ba01-5039-c103e8d8b1ef@gmail.com>
In-Reply-To: <20181005014815.16483-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3232106304095749584==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 10/04/2018 08:48 PM, Andrew Zaborowski wrote:
> Netlink errors returned by the kernel are already negative so don't
> change the sign, this was confusing some iwd code that depends on
> negative error numbers from l_netlink.
> ---
>   ell/netlink.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis


--===============3232106304095749584==--

