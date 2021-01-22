Content-Type: multipart/mixed; boundary="===============4556111012069440945=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/3] buf: Add a generic extensible buffer struct
Date: Fri, 22 Jan 2021 12:10:06 +0100
Message-ID: <CAOq732LiqbP0nnnSM-Gio=qpvpKdnU66MCzhsYFFPAzBipA0Wg@mail.gmail.com>
In-Reply-To: <dcddb89c-de46-2870-cb3f-ee647e8e3d5f@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4556111012069440945==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis and Mat,

On Fri, 22 Jan 2021 at 03:44, Denis Kenzior <denkenz@gmail.com> wrote:
> > Thanks for the additional background, and for letting me know it's stil=
l RFC-stage.
> >
> > I think what it comes down to for me is that exposing the struct intern=
als locks
> > those in as part of the "public API" that would be harder to change in =
the
> > future, and that it's less clear how to best use l_buf.
> >
>
> I pretty much concur here, I don't like this part either.  I'm not quite =
sure
> whether we should even support buffers allocated on the stack.  That seem=
s weird
> to me due to memory ownership issues and things potentially going out of =
scope.

Right, it's a little tricky but I think I came up with semantics (and
implementation) that work.  In any case I'm fine dropping the static
l_bufs thing and not exposing the struct declaration.

Best regards
--===============4556111012069440945==--

