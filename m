Content-Type: multipart/mixed; boundary="===============2451740730169548376=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 05/11] dbus: Check the FD array size in
 l_dbus_message_builder_append_from_iter
Date: Fri, 29 Apr 2016 10:51:05 -0500
Message-ID: <572382E9.7000201@gmail.com>
In-Reply-To: <1461900728-20662-10-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2451740730169548376==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/28/2016 10:32 PM, Andrew Zaborowski wrote:
> Also make sure an invalid FD in the input message is reflected as an
> invalid FD in the output message and non-fatal.
> ---
>   ell/dbus-message.c | 20 ++++++++++++--------
>   1 file changed, 12 insertions(+), 8 deletions(-)
>

Applied, thanks.

Regards,
-Denis


--===============2451740730169548376==--

