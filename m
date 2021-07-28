Content-Type: multipart/mixed; boundary="===============6304381361809377444=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/8] dhcp-lease: Check duplicate options in
 _dhcp_lease_parse_options
Date: Wed, 28 Jul 2021 10:50:34 -0500
Message-ID: <6b992653-5218-edaa-7dd4-dffb754cd4f8@gmail.com>
In-Reply-To: <20210723182331.135123-4-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6304381361809377444==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 7/23/21 1:23 PM, Andrew Zaborowski wrote:
> Guard against leaks if some of the options are duplicated in the message
> being parsed in _dhcp_lease_parse_options.
> ---
>   ell/dhcp-lease.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis

--===============6304381361809377444==--

