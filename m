Content-Type: multipart/mixed; boundary="===============1500524073923754551=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Flush pending object manager signals in send_message
Date: Mon, 27 Mar 2017 04:23:17 -0500
Message-ID: <134ed500-6d42-b558-a73e-6ada3fd6f1f1@gmail.com>
In-Reply-To: <20170327232301.30258-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1500524073923754551==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/27/2017 06:23 PM, Andrew Zaborowski wrote:
> Make sure the PropertiesChanged and InterfacesAdded/Removed signals
> related to one object path are sent to the dbus socket in the order
> that they are generated in.
> ---
>  ell/dbus-private.h |   2 +
>  ell/dbus-service.c | 160 ++++++++++++++++++++++++++++++++++++-----------=
------
>  ell/dbus.c         |   5 ++
>  3 files changed, 117 insertions(+), 50 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============1500524073923754551==--

