Content-Type: multipart/mixed; boundary="===============4251337046967288714=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Micha=C5=82?= 'Khorne' Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Subject: Re: [PATCH] dbus: Added l_dbus_signal_emit
Date: Fri, 01 Feb 2019 20:12:35 +0100
Message-ID: <20190201191235.5wtj6imwtgtpcoqc@kynes>
In-Reply-To: <5e688fdb-ed07-2aa0-b9b1-1ce4749150ef@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4251337046967288714==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 02/01, Denis Kenzior wrote:
> I'm confused why this is needed? You can emit a signal today by doing:
> =

> sig =3D l_dbus_message_new_signal();
> l_dbus_message_set_arguments(sig, "...", ...);
> l_dbus_send();

Hm. I was originally trying to do that, but if I tried to emit a signal
from a method handler, the client wasn't receiving replies... I think
I've seen mismatched serial numers on dbus-monitor, so I deferred
sending the signal until after method reply.

Seems like I must have had a bug somewhere else, the example above works
as expected. I'm going to re-test this and get back to you.

Sorry for the commotion.

-- =

Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
Silvair http://silvair.com
Jasnog=C3=B3rska 44, 31-358 Krakow, POLAND

--===============4251337046967288714==--

