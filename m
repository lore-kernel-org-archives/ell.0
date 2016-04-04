Content-Type: multipart/mixed; boundary="===============3280985040172853882=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Fix _dbus_kernel_calculate_bloom for multiple
 arguments
Date: Mon, 04 Apr 2016 14:22:46 -0500
Message-ID: <5702BF06.1090601@gmail.com>
In-Reply-To: <1459478466-6299-4-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3280985040172853882==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/31/2016 09:41 PM, Andrew Zaborowski wrote:
> l_dbus_message_iter_get_type can't be used to get the value of a
> single argument and be called repeatedly, might crash if the number
> and types of call arguments don't match the message arguments.
> Add a comment explaining why arguments after first non-string argument
> are not considered.
> ---
>   ell/dbus-message.c | 32 ++++++++++++++++++++++++++------
>   1 file changed, 26 insertions(+), 6 deletions(-)

Applied, thanks.

Regards,
-Denis


--===============3280985040172853882==--

