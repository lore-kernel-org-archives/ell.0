Content-Type: multipart/mixed; boundary="===============5594917584915925357=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] dbus: Use blocking socket for Dbus1, adapt IO calls
Date: Wed, 11 May 2016 11:07:47 -0500
Message-ID: <573358D3.6060800@gmail.com>
In-Reply-To: <1462959370-30764-4-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5594917584915925357==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 05/11/2016 04:36 AM, Andrew Zaborowski wrote:
> We need to handle partial reads and writes and FD passing with multiple
> messages in the socket's queue so we may need multiple calls to send or
> recv.  With a blocking socket we can call them in the loop and simplify
> buffering of message data.
> ---
>   ell/dbus.c | 220 +++++++++++++++++++++++++++++++++++++++++++-----------=
-------
>   1 file changed, 157 insertions(+), 63 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============5594917584915925357==--

