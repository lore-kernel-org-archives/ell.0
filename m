Content-Type: multipart/mixed; boundary="===============5099504716406826199=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp: Reset lease on client stop
Date: Thu, 20 Jun 2019 16:47:54 -0500
Message-ID: <5b8dff87-5978-47f3-02e8-509a4eca50eb@gmail.com>
In-Reply-To: <20190620204814.24577-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5099504716406826199==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 06/20/2019 03:48 PM, Tim Kourt wrote:
> The un-reset lease variable used to be freed multiple times
> when the client is explicitly stopped before being destroyed.
> =

> =3D=3D12374=3D=3D Invalid read of size 8
> =3D=3D12374=3D=3D    at 0x46C889: _dhcp_lease_free (dhcp-lease.c:47)
> =3D=3D12374=3D=3D    by 0x46B5F2: l_dhcp_client_stop (dhcp.c:1220)
> =3D=3D12374=3D=3D    by 0x46B61D: l_dhcp_client_destroy (dhcp.c:1011)
> ---
>   ell/dhcp.c | 2 ++
>   1 file changed, 2 insertions(+)
> =


Applied, thanks.

Regards,
-Denis


--===============5099504716406826199==--

