Content-Type: multipart/mixed; boundary="===============2755015927878326444=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] netlink: Allow command handler to use l_netlink_cancel
Date: Tue, 02 Mar 2021 18:18:35 -0600
Message-ID: <2c751c0a-e44e-81ae-64e8-29062ef3f52f@gmail.com>
In-Reply-To: <CAOq732+BnL-cS8zGz2890wVe2uHMegi0gDxvCTK2CYTRmrQ4xw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2755015927878326444==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>> Are you trying to stop callbacks mid-dump or ?
> =

> Yes, in the dump case the use case is pretty obvious -- once you've
> received the fragment you were interested in (in my case, I dump IPv4
> addresses and I'm interested in one specific ifindex), if you can
> cancel the command you don't have to keep a flag that tells you to
> ignore further callbacks.  And if you need to destroy the object (e.g.
> stop the AP) based on the data you received, you're also free to do
> this.

Ok, gotcha.  I have to ponder whether using l_foo_cancel is a good idea for =

this, or a more explicit API should be used.  Also, we'd have to make this =

behavior consistent everywhere.

> =

> In the non-dump case I see the utility of this change mainly in the
> situation where, within the callback, you decide you want to tear-down
> the object (e.g. stop the AP), like I said already.  If you're not
> allowed to cancel the command at that point, you basically need
> reference counting so that you can avoid crashing in your destroy
> handler.  And in that case I'd say we should have at least a warning
> about this limitation somewhere.

You might be the first one to need this actually.  There's always the =

l_idle_oneshot get-out-of-jail card ;)

Regards,
-Denis
--===============2755015927878326444==--

