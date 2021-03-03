Content-Type: multipart/mixed; boundary="===============6498800014134062511=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] netlink: Allow command handler to use l_netlink_cancel
Date: Tue, 02 Mar 2021 18:03:11 -0600
Message-ID: <fd75120e-5ce2-cef5-8b01-da92d456678f@gmail.com>
In-Reply-To: <CAOq732KUpYrSaSpOfHnUYJ+gf-QccFmi4_jqxDOayJBYntNrBQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6498800014134062511==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>>> Would it not be better to simply remove the command from the command_lo=
okup
>>> hashmap prior to dispatch, and have l_netlink_cancel simply fail?
>>
>> Yes, that would work.
> =

> On a second thought, I think it's better the other way.  The
> l_netlink_cancel() call can be used as a request to forget the
> callbacks.  The user may be tearing down the object they passed as
> user_data for example.  IIRC we did take that use case into
> consideration in some of the other APIs, what do you think?

Which other way?  Ahhh, I think I get it... You want to unset the destroy =

callback or prevent it from being called subsequently when inside the handl=
er by =

issuing l_netlink_cancel?

I actually don't think any ell APIs work this way.  l_dbus for example simp=
ly =

removes the pending request prior to dispatch (which is what I suggested =

earlier).  Hence l_dbus_cancel wouldn't work on it inside the l_dbus_send c=
allback.

Even APIs that use the watchlist pattern don't do it this way.  You may be =

thinking of the scan API inside iwd, which did it for a different reason.

Regards,
-Denis
--===============6498800014134062511==--

