Content-Type: multipart/mixed; boundary="===============7451088316436325785=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: free previous sender string in
 _dbus_message_set_sender
Date: Mon, 14 Mar 2016 10:41:14 -0500
Message-ID: <56E6DB9A.30007@gmail.com>
In-Reply-To: <1457966979-3259-1-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7451088316436325785==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 03/14/2016 09:49 AM, Andrew Zaborowski wrote:
> Allow _dbus_message_set_sender and _dbus_message_set_destination to be
> called multiple times.
> ---
>   ell/dbus-message.c | 4 ++++
>   1 file changed, 4 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============7451088316436325785==--

