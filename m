Content-Type: multipart/mixed; boundary="===============8732188185293430060=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 10/15] dbus: kdbus filter_ops implementation.
Date: Thu, 24 Mar 2016 12:51:43 -0500
Message-ID: <56F4292F.5030300@gmail.com>
In-Reply-To: <1458598224-29325-10-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8732188185293430060==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
> For the name owner tracking I decided to subscribe to all name
> owner changes instead of adding separate rules for every name because
> in some scenarios that saves us cycles/memory and we don't have
> to hold a list of IDs of every such rule so that we could remove them
> when no longer needed.
> ---
>   ell/dbus-kernel.c  | 202 ++++++++++++++++++++++++++++++++++++++++++++++=
++-----
>   ell/dbus-private.h |  17 ++++-
>   ell/dbus.c         | 151 +++++++++++++++++++++++++++++----------
>   3 files changed, 313 insertions(+), 57 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============8732188185293430060==--

