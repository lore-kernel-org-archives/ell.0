Content-Type: multipart/mixed; boundary="===============0783781957435445152=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 09/15] dbus: Classic dbus filter_ops implementation.
Date: Fri, 25 Mar 2016 21:37:52 -0500
Message-ID: <56F5F600.1020507@gmail.com>
In-Reply-To: <CAOq732LA00ZUQ=2rc0LDSgmLMJKOh7ivQkdFuBg7Cm=B_N26nw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0783781957435445152==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 >
> Yes, this would be possible.  This is similar to how the object tree
> in dbus-service.c could rebuild the paths from node pointers but
> instead some functions receive the path string and the node pointer to
> avoid this.  Let's keep thinking if we want to do that, but the IDs
> work well for kdbus.  If we change this, kdbus could pass a hash of
> the rule string as the cookie.

Actually we could send both.  The rules and the id to both add and =

remove match methods.  We already have the id, so no need to calculate =

any hashes.

Regards,
-Denis

--===============0783781957435445152==--

