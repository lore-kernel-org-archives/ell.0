Content-Type: multipart/mixed; boundary="===============1326853027943342569=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/5] dbus: Remove memcpy and fix setting of FD_CLOEXEC on
 FDs
Date: Fri, 29 Apr 2016 18:20:35 -0500
Message-ID: <5723EC43.9020900@gmail.com>
In-Reply-To: <1461969842-11704-2-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1326853027943342569==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/29/2016 05:43 PM, Andrew Zaborowski wrote:
> Make sure the size of the FD buffer passed to recvmsg is properly
> aligned, etc. and remove the memcpy which seems unneeded.  Also it looks
> like the fcntl() calls operated on one dbus socket FD instead of the
> message FDs.
> ---
>   ell/dbus.c | 17 ++++++++++-------
>   1 file changed, 10 insertions(+), 7 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============1326853027943342569==--

