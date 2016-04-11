Content-Type: multipart/mixed; boundary="===============3072999564452970846=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 01/12] dbus: Kdbus message timeout_ns is absolute time
Date: Mon, 11 Apr 2016 14:42:10 -0500
Message-ID: <570BFE12.4010602@gmail.com>
In-Reply-To: <1460260961-9183-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3072999564452970846==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/09/2016 11:02 PM, Andrew Zaborowski wrote:
> It is even documented in systemd, although not very clearly, that
> timeout_ns is a CLOCK_MONOTONIC_COARSE-based absolute value.
> ---
>   ell/dbus-kernel.c | 13 +++++++++++--
>   1 file changed, 11 insertions(+), 2 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============3072999564452970846==--

