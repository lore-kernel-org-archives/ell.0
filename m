Content-Type: multipart/mixed; boundary="===============3386670274051111174=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski at intel.com>
To: ell at lists.01.org
Subject: Re: [PATCH 4/5] icmp6: Track routers and prefix routes from multiple
 RAs
Date: Fri, 07 Jan 2022 22:55:36 +0100
Message-ID: <CAOq732+tRb=o8aiKXGGXgWUk0D8qbcQ-m38HxKE7TzjRMdiQog@mail.gmail.com>
In-Reply-To: d9934b52-f4a6-3049-f25f-0d5d6d9d5cad@gmail.com

--===============3386670274051111174==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 7 Jan 2022 at 22:26, Denis Kenzior <denkenz(a)gmail.com> wrote:
> > (But, didn't we talk on the IWD list about how we need to pass those
> > events to a "netconfig-committer" entity and let it apply the
> > settings?)
> >
>
> That's why I'm asking.  It seems there is an implicit assumption that we =
want to
> pass all the information from l_icmp6_client up to iwd and have it commit=
 the
> routes.   But given the complexity of doing this, I'm actually not entire=
ly sure
> it is worth the effort.

There's also going to be complexity in receiving this information on
the NM side and passing it further on, but I'm not sure what is the
alternative.

Once we have a D-Bus backend for this, the cost of doing the other
(non-DBus) backend in netconfig-committer.c is small.

>
> >>
> >> In case of 2, the client just wants a snapshot of what the settings sh=
ould be,
> >> not get notified that each individual route has changed.
> >
> > Right, but we do need most of the events in this case.  If we're not
>
> I'm still not following.  Wouldn't l_icmp6_client_get_full_info() be what=
 you
> want?  And have the client call it after every L_ICMP6_CLIENT_EVENT_ROUTE=
R_FOUND?

We will need something like l_icmp6_client_get_full_info(), but we
still need to react to all the other events: a new prefix being added
or removed, a router MTU changing, a router declaring that it no
longer wants to be a default router, etc.

>
> >> Yes, we could do that since you're not passing lifetimes in the propos=
ed iwd
> >> API.  But is that intended or an oversight?
> >
> > To be honest I didn't realise that finite lifetimes are actually
> > popular (judging from the docs I read so far...), in fact only the
> > prefix options support infinite lifetimes, default router info
> > doesn't.  So wrt the D-Bus API it seems that not passing the lifetimes
> > and lifetime updates will be much more efficient.  As for applying
>
> Question is, are you sure that this is what NM guys would be ok with?

I still need an answer on this, but it shouldn't affect ell as long as
it has a complete-ish icmp6 API.

Best regards
--===============3386670274051111174==--

