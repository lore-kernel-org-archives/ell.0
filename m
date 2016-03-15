Content-Type: multipart/mixed; boundary="===============3944163117199184442=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 18/20] dbus: Classic dbus driver->name_acquire and public
 API.
Date: Tue, 15 Mar 2016 11:38:16 -0500
Message-ID: <56E83A78.10501@gmail.com>
In-Reply-To: <CAOq732Jg1p77Ac28irVTxxtNjaE2xtph=Q=3bd2zLH4om7j=uw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3944163117199184442==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 >>>
>>> +uint32_t l_dbus_name_acquire(struct l_dbus *dbus, const char *name,
>>> +                               bool allow_replacement, bool
>>> replace_existing,
>>> +                               bool queue, l_dbus_name_acquire_func_t
>>> callback,
>>> +                               void *user_data);
>>> +
>>
>>
>> What's the uint32_t return for?
>
> So that the call can be cancelled with l_dbus_cancel if the user no
> longer needs the name and it is still waiting for the callback (should
> be rare).
>

The semantics are a bit weird here though.  You have kdbus version that =

simply returns 0.  dbus1 version returns a uint32 or 0 depending on =

success / failure.

How does the client application know what is what?  Perhaps a straight =

true/false might be better here?

Regards,
-Denis


--===============3944163117199184442==--

