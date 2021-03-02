Content-Type: multipart/mixed; boundary="===============4504431480795149945=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] netlink: Allow command handler to use l_netlink_cancel
Date: Tue, 02 Mar 2021 16:34:43 +0100
Message-ID: <CAOq732Ja+nFiHSSngd7B27Xt+7vx=CpS4fpMtUrsaaaX-brVEQ@mail.gmail.com>
In-Reply-To: <b09370df-03f0-58c4-ab95-f8ef51e8b128@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4504431480795149945==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 2 Mar 2021 at 16:10, Denis Kenzior <denkenz@gmail.com> wrote:
> On 3/2/21 5:14 AM, Andrew Zaborowski wrote:
> > ---
> >   ell/netlink.c | 8 +++++---
> >   1 file changed, 5 insertions(+), 3 deletions(-)
> >
>
> You may want to write something about why this would be wanted.

Ok.

>
> > diff --git a/ell/netlink.c b/ell/netlink.c
> > index 33d0e5b..4664762 100644
> > --- a/ell/netlink.c
> > +++ b/ell/netlink.c
> > @@ -162,12 +162,15 @@ static void process_message(struct l_netlink *net=
link, struct nlmsghdr *nlmsg)
> >   {
> >       const void *data =3D nlmsg;
> >       struct command *command;
> > +     uint32_t id;
> >
> >       command =3D l_hashmap_remove(netlink->command_pending,
> >                                       L_UINT_TO_PTR(nlmsg->nlmsg_seq));
> >       if (!command)
> >               return;
> >
> > +     id =3D command->id;
> > +
> >       if (!command->handler)
> >               goto done;
> >
> > @@ -189,9 +192,8 @@ static void process_message(struct l_netlink *netli=
nk, struct nlmsghdr *nlmsg)
> >       }
> >
> >   done:
> > -     l_hashmap_remove(netlink->command_lookup, L_UINT_TO_PTR(command->=
id));
> > -
> > -     destroy_command(command);
> > +     if (l_hashmap_remove(netlink->command_lookup, L_UINT_TO_PTR(id)))
> > +             destroy_command(command);
>
> Would it not be better to simply remove the command from the command_look=
up
> hashmap prior to dispatch, and have l_netlink_cancel simply fail?

Yes, that would work.

>
> I do wonder why you'd cancel the command from the handler?

In the IWD AP case I want to cancel a dump command which I think is
already handled correctly, but if the API can be made more robust then
I think it's an improvement.  There can be complicated code paths
where you destroy an object that owns the netlink command as a result
of the command response.

Best regards
--===============4504431480795149945==--

