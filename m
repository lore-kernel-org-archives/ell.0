Content-Type: multipart/mixed; boundary="===============1101019512027454351=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 2/9] dbus: Don't rely on 1st KDBUS_ITEM_PAYLOAD_OFF
 being the header
Date: Mon, 18 Apr 2016 11:52:45 -0500
Message-ID: <571510DD.8090408@gmail.com>
In-Reply-To: <1460680442-15201-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1101019512027454351==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/14/2016 07:33 PM, Andrew Zaborowski wrote:
> The header of the GVariant message can't be split into multiple
> KDBUS_ITEM_PAYLOAD_OFF items according to the docs but it doesn't have
> to be split from the body.  We need to use dbus_message_from_blob
> because we can't know the header/body split positions without parsing
> the received contents.
> ---
>   ell/dbus-kernel.c | 75 +++++++++++++++---------------------------------=
-------
>   1 file changed, 20 insertions(+), 55 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============1101019512027454351==--

