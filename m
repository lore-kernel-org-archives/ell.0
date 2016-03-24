Content-Type: multipart/mixed; boundary="===============5181528446026102900=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 04/15] dbus: Support 2+ arguments in
 l_dbus_message_get_error
Date: Thu, 24 Mar 2016 09:36:07 -0500
Message-ID: <56F3FB57.3080204@gmail.com>
In-Reply-To: <1458598224-29325-4-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5181528446026102900==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
> Error messages may have any number of arguments, the first one is still
> the error string if it's a string.
> ---
>   ell/dbus-message.c | 13 +++----------
>   1 file changed, 3 insertions(+), 10 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============5181528446026102900==--

