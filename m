Content-Type: multipart/mixed; boundary="===============3571602907964102766=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Check message->sealed before get_header_field()
Date: Mon, 18 Apr 2016 21:39:24 -0500
Message-ID: <57159A5C.40500@gmail.com>
In-Reply-To: <1460989877-20113-3-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3571602907964102766==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/18/2016 09:31 AM, Andrew Zaborowski wrote:
> Also make sure _dbus_message_get_reply_serial on kdbus doesn't overwrite
> message->reply_serial with uninitialised value.
> ---
>   ell/dbus-message.c | 14 +++++++-------
>   1 file changed, 7 insertions(+), 7 deletions(-)

Applied, thanks.

Regards,
-Denis


--===============3571602907964102766==--

