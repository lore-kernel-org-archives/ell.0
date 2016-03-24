Content-Type: multipart/mixed; boundary="===============2700834227020441467=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/15] dbus-filter: Name owner change tracking support.
Date: Thu, 24 Mar 2016 12:28:02 -0500
Message-ID: <56F423A2.7080800@gmail.com>
In-Reply-To: <1458598224-29325-8-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2700834227020441467==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
> This is needed because incoming message callbacks normally care what
> Well-known Bus Name the message comes from but the sender field of the
> message normally stores unique bus names in classic dbus.  The
> Well-known names may be re-assigned to different unique names while the
> rule is in place.
> ---
>   ell/dbus-filter.c  | 183 ++++++++++++++++++++++++++++++++++++++++++----=
-------
>   ell/dbus-private.h |   4 ++
>   2 files changed, 151 insertions(+), 36 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============2700834227020441467==--

