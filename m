Content-Type: multipart/mixed; boundary="===============7063167229445740601=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: RFC: DBus send_with_reply wrapper doesn't time out
Date: Sat, 11 Apr 2020 16:00:29 +0000
Message-ID: <93b7f2b0-3c61-ae78-daff-22505557b159@gmail.com>
In-Reply-To: <9a3292457b6d53eff29cf8ad4c87f808014a10ab.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7063167229445740601==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

> Is timing out reply required methods the dbus daemon responsibility?  Is =
it the l_dbus_send_with_reply()
> responsibility?  The mesh daemon responsibility?  Ideally, the App just r=
esponds, but we have no control over
> how Apps respond to method calls.
> =


Timeouts do not exist at the protocol level, their implementation is =

purely a higher level feature.

dbus-daemon can be configured to limit the maximum time an application =

can take to respond, but the default reply_timeout is set to -1 (infinite).

ell does not enable or enforce any timeouts for dbus method calls. =

Starting a timer for each dbus call is quite expensive, so for now we =

have left this up to the application to manage.

Regards,
-Denis
--===============7063167229445740601==--

