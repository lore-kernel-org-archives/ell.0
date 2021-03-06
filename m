Content-Type: multipart/mixed; boundary="===============7452899617337179954=="
MIME-Version: 1.0
From: Phil <philip.hodges@bluewin.ch>
Subject: Re: [PATCH] util: Add L_AUTO_FREE_OBJ and l_steal_ptr macros
Date: Sat, 06 Mar 2021 10:02:40 +0100
Message-ID: <E9B4641B-2180-4500-B152-E2AFDFCBA877@bluewin.ch>
In-Reply-To: <CAOq732LPcHBhqXb+TQv4Af2p+m5b3J1UHbe+__v17jYjDZgAYA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7452899617337179954==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

It might be good to avoid any possible confusion with the C++03 auto_ptr, w=
hich is deprecated in C++11 favour of unique_ptr.

> I see one of the following forms as most usable:
> =

> l_settings_auto_ptr settings;
> l_settings_auto_ptr *settings;
> l_auto_ptr(l_settings) settings;
> l_auto_ptr(l_settings) *settings;
> =

> The l_auto_ptr() macro would rely on settings.h defining a cleanup
> function whose name can be derived by preppending and/or appending
> something to "l_settings".

--===============7452899617337179954==--

