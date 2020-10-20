Content-Type: multipart/mixed; boundary="===============3978906632932183182=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v7 3/6] dhcp-server: handle DECLINE messages
Date: Tue, 20 Oct 2020 11:33:39 -0500
Message-ID: <2c578f3d-6067-3858-7c37-a538b851aae3@gmail.com>
In-Reply-To: <20201020155249.1603105-3-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3978906632932183182==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/20/20 10:52 AM, James Prestwood wrote:
> Process DECLINE messages from clients and remove any pending
> leases that were created during DISCOVER.
> ---
>   ell/dhcp-server.c | 18 ++++++++++++++++++
>   1 file changed, 18 insertions(+)
> =

> v7:
>   * Removed event from remove_lease since this is only called due to
>     a DECLINE message and no NEW_LEASE event would have been called.
> =


Patch 3-5 applied, thanks.  Rest were applied from v6.

Regards,
-Denis

--===============3978906632932183182==--

