Content-Type: multipart/mixed; boundary="===============3282827442572860930=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 03/15] dbus: Add _dbus_message_get_nth_string_argument
Date: Thu, 24 Mar 2016 09:35:49 -0500
Message-ID: <56F3FB45.4080402@gmail.com>
In-Reply-To: <1458598224-29325-3-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3282827442572860930==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/21/2016 05:10 PM, Andrew Zaborowski wrote:
> We happen to need to access n-th argument specifically only if it is
> of a string type in at least three places, so add this shortcut.
> ---
>   ell/dbus-message.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
>   ell/dbus-private.h |  2 ++
>   2 files changed, 47 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============3282827442572860930==--

