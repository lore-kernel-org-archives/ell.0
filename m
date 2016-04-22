Content-Type: multipart/mixed; boundary="===============8806122660167507736=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v4] dbus: Remove signature field from gvariant header
Date: Thu, 21 Apr 2016 21:22:07 -0500
Message-ID: <57198ACF.40404@gmail.com>
In-Reply-To: <1461286637-30810-3-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8806122660167507736==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/21/2016 07:57 PM, Andrew Zaborowski wrote:
> The main reason to do that is that systemd thinks it's an error and will
> ignore received messages with a dbus1-like signature field in the
> header.
> ---
>   ell/dbus-message.c | 15 +++++----------
>   1 file changed, 5 insertions(+), 10 deletions(-)

Applied, thanks.

Regards,
-Denis


--===============8806122660167507736==--

