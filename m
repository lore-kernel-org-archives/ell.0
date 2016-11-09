Content-Type: multipart/mixed; boundary="===============6441843236386532629=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Don't send replies to messages with no reply flag
Date: Wed, 09 Nov 2016 14:16:09 -0600
Message-ID: <58238409.4060507@gmail.com>
In-Reply-To: <1478686966-15117-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6441843236386532629==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/09/2016 04:22 AM, Andrew Zaborowski wrote:
> Kdbus doesn't store the cookies for messages that have the no reply flag
> and throws error when a reply is sent with reply_cookie that it doesn't
> know.  It's not fatal, but we save some cycles by not sending the message
> with both dbus versions.
>
> We mark those replies with reply_serial =3D=3D 0, rather than setting a
> "discard" flag on the message, because the method call's serial is
> effectively an invalid reply_serial value.
> ---
>   ell/dbus-message.c | 10 +++++++---
>   ell/dbus.c         | 10 ++++++++++
>   2 files changed, 17 insertions(+), 3 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============6441843236386532629==--

