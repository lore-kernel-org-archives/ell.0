Content-Type: multipart/mixed; boundary="===============8556931452762368346=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 1/9] dbus: Update GVariant message header format
Date: Mon, 18 Apr 2016 11:52:28 -0500
Message-ID: <571510CC.6040106@gmail.com>
In-Reply-To: <1460680442-15201-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8556931452762368346==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/14/2016 07:33 PM, Andrew Zaborowski wrote:
> In the current GVariant message format since about Jan 2015 there's no
> body size field (it is reserved and must be sent as 0) or header size
> information or signature.  The message needs to be parsed as a single
> GVariant blob if we want to split it into a header and a body.
> ---
>   ell/dbus-kernel.c  |   3 -
>   ell/dbus-message.c | 167 ++++++++++++++++++++++++++++++++++++++--------=
-------
>   ell/dbus-private.h |  16 ++++-
>   ell/dbus-util.c    |   4 +-
>   ell/dbus.c         |   4 +-
>   5 files changed, 137 insertions(+), 57 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============8556931452762368346==--

