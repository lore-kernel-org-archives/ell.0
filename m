Content-Type: multipart/mixed; boundary="===============6255068550525496546=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp-server: Fill in DNS info in lease objects
Date: Tue, 31 Aug 2021 08:26:28 -0500
Message-ID: <4d4e975f-133a-360c-4f0d-b23f47530c6c@gmail.com>
In-Reply-To: <20210828030632.28287-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6255068550525496546==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/27/21 10:06 PM, Andrew Zaborowski wrote:
> Copy the DNS info that we send to the client also to the lease object
> that we keep on our side for our own tracking, same as we copy the IP,
> the gateway, the netmask etc.
> ---
>   ell/dhcp-server.c | 7 +++++++
>   1 file changed, 7 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============6255068550525496546==--

