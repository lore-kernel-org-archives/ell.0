Content-Type: multipart/mixed; boundary="===============9207099249051976673=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Move generic DBus paths to header file
Date: Tue, 10 Feb 2015 13:33:12 -0600
Message-ID: <54DA5CF8.5030509@gmail.com>
In-Reply-To: <1423579970-14284-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9207099249051976673==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/10/2015 08:52 AM, Jukka Rissanen wrote:
> DBus defines moved to header file so that they can be used
> by other source files.

What other source files?  Care to give me a bit more context?

Also, I prefer we localize all the DBus Classic stuff to ell/dbus.c as =

much as possible.

> ---
>   ell/dbus.c | 5 -----
>   ell/dbus.h | 4 ++++
>   2 files changed, 4 insertions(+), 5 deletions(-)
>

Regards,
-Denis


--===============9207099249051976673==--

