Content-Type: multipart/mixed; boundary="===============8537585008857135464=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] dbus: Fix use-after-free in property changed signals
Date: Thu, 13 Jul 2017 06:24:28 +0200
Message-ID: <81A25577-7C06-4163-89BD-A17E37C6A0C0@holtmann.org>
In-Reply-To: <20170712202302.6373-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8537585008857135464==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> Configuring with --enable-asan and running test-dbus-properties revealed
> that properties_set_complete() was accessing a reply message after it
> was sent, but l_dbus_send() had already unref'd and freed the message.
> =

> Grabbing a reference to the reply before sending fixes the problem.
> ---
> ell/dbus-service.c | 3 ++-
> 1 file changed, 2 insertions(+), 1 deletion(-)

patch has been applied.

Regards

Marcel


--===============8537585008857135464==--

