Content-Type: multipart/mixed; boundary="===============0025028142932787155=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp: Decrease re-try delay after initial discovery
 message
Date: Thu, 01 Aug 2019 15:27:03 -0500
Message-ID: <0ba676c9-29c7-df94-ae3f-0a07fbeb3ef0@gmail.com>
In-Reply-To: <20190731233800.18467-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0025028142932787155==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 7/31/19 6:38 PM, Tim Kourt wrote:
> Some of the routers require =E2=80=98setup=E2=80=99 time between the mome=
nt when
> connection is established and before they are ready to respond to
> the DHCP discovery messages. This used to cause the DHCP clients
> to wait a full delay of +-4 seconds for the next attempt to
> rediscover DHCP servers. To address this issue, the time delay
> between the initial discovery message and its retransmission is
> shorten to milliseconds to give enough time to the routers to get
> ready and minimize the delay for the clients.
> ---
>   ell/dhcp.c | 19 ++++++++++++++++++-
>   1 file changed, 18 insertions(+), 1 deletion(-)
> =


Applied, thanks.

Regards,
-Denis


--===============0025028142932787155==--

