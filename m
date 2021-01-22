Content-Type: multipart/mixed; boundary="===============0430735417050155169=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] buf: Add a generic extensible buffer struct
Date: Thu, 21 Jan 2021 20:44:53 -0600
Message-ID: <dcddb89c-de46-2870-cb3f-ee647e8e3d5f@gmail.com>
In-Reply-To: <7180e754-1654-b3ea-5c79-60d68c8a14e@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0430735417050155169==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> Thanks for the additional background, and for letting me know it's still =
RFC-stage.
> =

> I think what it comes down to for me is that exposing the struct internal=
s locks =

> those in as part of the "public API" that would be harder to change in th=
e =

> future, and that it's less clear how to best use l_buf.
> =


I pretty much concur here, I don't like this part either.  I'm not quite su=
re =

whether we should even support buffers allocated on the stack.  That seems =
weird =

to me due to memory ownership issues and things potentially going out of sc=
ope. =

Something that is on the heap and reference counted would seem to be a safe=
r =

approach.

But I'm still trying to organize my thoughts on this RFC, so I don't have =

anything I can express eloquently.

Regards,
-Denis
--===============0430735417050155169==--

