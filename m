Content-Type: multipart/mixed; boundary="===============4920769524590008403=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 01/15] dbus: Add _dbus1_message_iter_skip_entry.
Date: Thu, 24 Mar 2016 09:35:19 -0500
Message-ID: <56F3FB27.70005@gmail.com>
In-Reply-To: <1458598224-29325-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4920769524590008403==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
> This will be used for the get_nth_string_argument function in
> dbus-message.c.  There seems to be no other way to skip over an iterator
> entry without knowing the data type.
> ---
>   ell/dbus-private.h |  1 +
>   ell/dbus-util.c    | 16 ++++++++++++++++
>   2 files changed, 17 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============4920769524590008403==--

