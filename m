Content-Type: multipart/mixed; boundary="===============0530071050131713977=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/5] dbus: Coalesce PropertiesChanged signals
Date: Mon, 29 Feb 2016 15:26:44 -0600
Message-ID: <56D4B794.8030105@gmail.com>
In-Reply-To: <CAOq732+Ai=m+BVD6xxhip+CezQ8Um8rR5ehkAQVw-=US6bf+Aw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0530071050131713977==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

After talking to Andrew, I realized I was off-base here.

 >> This looks a bit suspicious.  Should we be also comparing the object
>> pointer, not just the instance pointer here?
>
> Assuming that only one object can have the instance it shouldn't
> matter.  When the object or the instance are removed, the property
> change record is also removed so it won't accidentally point at a
> different instance.

I for some reason was thinking we're tracking l_dbus_interface objects, =

not interface_instance.  So after being being reminded of that, the code =

is just fine.

Regards,
-Denis

--===============0530071050131713977==--

