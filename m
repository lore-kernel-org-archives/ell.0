Content-Type: multipart/mixed; boundary="===============3296373142477598054=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Don't use KDBUS_ATTACH_NAMES for kdbus connection
Date: Fri, 29 Apr 2016 10:23:07 -0500
Message-ID: <57237C5B.5040300@gmail.com>
In-Reply-To: <1461900728-20662-5-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3296373142477598054==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/28/2016 10:31 PM, Andrew Zaborowski wrote:
> On the receive side we're not using the list of names being attached to
> messages because we keep a cache of the name owners we need.  On the
> send side the KDBUS_ATTACH_NAMES is implicitly granted so there's no
> need to specify it.
> ---
>   ell/dbus-kernel.c | 2 --
>   1 file changed, 2 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============3296373142477598054==--

