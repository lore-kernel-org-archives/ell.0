Content-Type: multipart/mixed; boundary="===============2523193639240235648=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/20] dbus: Classic dbus filter_ops implementation.
Date: Tue, 15 Mar 2016 11:32:06 -0500
Message-ID: <56E83906.3060907@gmail.com>
In-Reply-To: <CAOq732JyhYnKjs8SSu9mtSpRiNm2RhaBaPEX997zkPYWt+5dpw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2523193639240235648==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 >>> +       _dbus_filter_add_rule(dbus->filter, rule, L_ARRAY_SIZE(rule),
>>> +                               name_owner_changed_cb, dbus);
>>> +
>>
>>
>> Do we need to treat DBUS_SERVICE_DBUS conditions specially since this on=
e is
>> not subject to unique name resolution?
>
> Good point, we don't *need* to, but we can save a GetNameOwner call if
> we do that.  Possibly we can just return "org.freedesktop.Dbus"
> immediately from classic_get_name_owner.
>

That could work, or alternatively notify the filtering code that name =

resolution should not be performed.  Saves us the alternative =

computation and comparison.

Regards,
-Denis


--===============2523193639240235648==--

