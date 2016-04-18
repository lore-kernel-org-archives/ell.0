Content-Type: multipart/mixed; boundary="===============2089008583519386730=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 6/9] dbus: Fix the kdbus message encoding
Date: Mon, 18 Apr 2016 14:25:59 -0500
Message-ID: <571534C7.5030200@gmail.com>
In-Reply-To: <1460680442-15201-6-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2089008583519386730==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/14/2016 07:33 PM, Andrew Zaborowski wrote:
> Keep sending the message header+padding as a separate
> KDBUS_ITEM_PAYLOAD_OFF buffer like in DBus-1, systemd also seems to do
> that.  But fix the structure of the message body.
>
> The term footer is used in systemd, probably there's a better name.
> ---
>   ell/dbus-kernel.c  | 19 +++++++++----------
>   ell/dbus-message.c | 19 +++++++++++++++++++
>   ell/dbus-private.h |  1 +
>   3 files changed, 29 insertions(+), 10 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============2089008583519386730==--

