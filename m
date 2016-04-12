Content-Type: multipart/mixed; boundary="===============2521857942667007302=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Tue, 12 Apr 2016 18:42:34 -0500
Message-ID: <570D87EA.7080907@gmail.com>
In-Reply-To: <CAOq732JMGVZ2MV=araQ=zxU2YcrQKhGKZm_5CDDUa3Z5=1OpCw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2521857942667007302==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 >>  From what I understood, the current setup will result in
>> l_dbus_message_get_signature() returning different results, depending on
>> transport.
>
> Could you give an example?  For a GetProperties reply
> l_dbus_message_get_signature() should return "a{sv}" on both kdbus and
> dbus1.  On kdbus the we'll have a (yyyyuta{tv}v) gvariant where the
> variant contians a (a{sv}) gvariant, but the API should completely
> hide that unless I screwed it up.

Let me look at this again later, I might not have understood correctly. =

  If you say this works, then I'm okay with this.

>> And this whole thing is a great example of how not to design a marshaling
>> format.
>
> Well, for one it gets rid of the split between the header and body in
> Dbus1 which was unneeded and while doing that is saves bytes because
> the variant adds fewer extra bytes than the
> DBUS_MESSAGE_FIELD_SIGNATURE field in Dbus1 ;)
>

Uh-huh.  DBus-1 was still sane compared to this.  You could peek at the =

header and discard messages you didn't care about.  No so here.

So the major improvement to DBus-1 is that the protocol becomes a =

nightmare to implement.  You basically have to have everything =

implemented before getting to hello world.

Not to mention the cache-miss city with the =

offset-list-in-little-endian-at-the-end crap ;)

Oh well, it is what it is.

Regards,
-Denis


--===============2521857942667007302==--

