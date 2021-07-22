Content-Type: multipart/mixed; boundary="===============0641576577183408678=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dhcp-server: Add API for manipulating leases
Date: Thu, 22 Jul 2021 11:36:53 -0500
Message-ID: <9acc1abc-10a3-32e6-f4ed-c0b7220bb076@gmail.com>
In-Reply-To: <20210719140020.555503-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0641576577183408678==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 7/19/21 9:00 AM, Andrew Zaborowski wrote:
> Add methods for obtaining and releasing DHCP leases.  There are four
> methods that correspond to the DISCOVER, REQUEST, DECLINE and RELEASE
> messages and two shortcut methods for releasing the leases.  This API is
> useful for implementing mechanisms like the optional P2P IP Allocation
> in the 802.11 4-Way Handshake and FILS IP Address Allocation in 802.11
> Associate frames (both reduces the number of roundtrips in connection
> setup).  Since there are multiple such mechanisms I decided to include
> discover and request as separate methods to allow more flexibility.
> ---
>   ell/dhcp-server.c | 106 +++++++++++++++++++++++++++++++++++++++++++++-
>   ell/dhcp.h        |  15 +++++++
>   ell/ell.sym       |   6 +++
>   3 files changed, 125 insertions(+), 2 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis

--===============0641576577183408678==--

