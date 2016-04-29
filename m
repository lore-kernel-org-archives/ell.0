Content-Type: multipart/mixed; boundary="===============3245067267226274472=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 03/11] dbus: Validate the size of fd list in
 dbus_message_build
Date: Fri, 29 Apr 2016 10:30:38 -0500
Message-ID: <57237E1E.4060209@gmail.com>
In-Reply-To: <1461900728-20662-8-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3245067267226274472==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/28/2016 10:32 PM, Andrew Zaborowski wrote:
> Trim the list of fds if too big rather than error out to be consistent
> with how we handle invalid FDs in message_iter_next_entry_valist and
> how kdbus allows messages with invalid FDs to still be delivered.
> ---
>   ell/dbus-message.c | 8 ++++++++
>   1 file changed, 8 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============3245067267226274472==--

