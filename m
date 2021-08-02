Content-Type: multipart/mixed; boundary="===============0869701302211503316=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 01/15] dhcp-server: Add "authoritative" mode
Date: Mon, 02 Aug 2021 13:15:17 -0500
Message-ID: <536c4a41-b0dd-6ba7-8097-a93e8164a398@gmail.com>
In-Reply-To: <20210802140424.170150-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0869701302211503316==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/2/21 9:04 AM, Andrew Zaborowski wrote:
> An authoritative DHCP server basically assumes that there are no other
> DHCP servers on the network and replies to DHCPREQUEST messages
> requesting IPs from outside of its subnet or with a wrong server ID
> value.  This speeds up connections from clients who try to use IP
> leases they have cached from other networks and who start their IP
> configuration by trying DHCPREQUESTs for those leases.
> =

> The term is not defined in the DHCP standard but is used by various
> implementations.  Default to authoritative being true.  When set to
> false, handle a DHCPREQUEST message directed at other servers by taking
> it as meaning the client is declining our own lease offer as mandated
> by RFC 2131 on page 16.
> =

> Refactor the checks in DHCPREQUEST handling quoting parts of the RFC.
> The new checks are stricter and I'm not preserving some of the checks
> that didn't seem justified, for example in the
> "if (server_id_opt || !lease) ... send_nak()" block it didn't seem to
> make sense to only reply to clients who have no lease (offered or
> active) and ignore those who do have a lease with a different IP
> address, the opposite would make more sense.
> ---
>   ell/dhcp-server.c | 117 +++++++++++++++++++++++++++++++++++++++-------
>   ell/dhcp.h        |   2 +
>   ell/ell.sym       |   1 +
>   3 files changed, 103 insertions(+), 17 deletions(-)
> =


All applied, thanks.

Regards,
-Denis

--===============0869701302211503316==--

