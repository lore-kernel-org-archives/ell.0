Content-Type: multipart/mixed; boundary="===============5159929780214136127=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] netlink: Allow command handler to use l_netlink_cancel
Date: Tue, 02 Mar 2021 22:36:17 +0100
Message-ID: <CAOq732KUpYrSaSpOfHnUYJ+gf-QccFmi4_jqxDOayJBYntNrBQ@mail.gmail.com>
In-Reply-To: <CAOq732Ja+nFiHSSngd7B27Xt+7vx=CpS4fpMtUrsaaaX-brVEQ@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5159929780214136127==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Tue, 2 Mar 2021 at 16:34, Andrew Zaborowski
<andrew.zaborowski@intel.com> wrote:
> On Tue, 2 Mar 2021 at 16:10, Denis Kenzior <denkenz@gmail.com> wrote:
> > >   done:
> > > -     l_hashmap_remove(netlink->command_lookup, L_UINT_TO_PTR(command=
->id));
> > > -
> > > -     destroy_command(command);
> > > +     if (l_hashmap_remove(netlink->command_lookup, L_UINT_TO_PTR(id)=
))
> > > +             destroy_command(command);
> >
> > Would it not be better to simply remove the command from the command_lo=
okup
> > hashmap prior to dispatch, and have l_netlink_cancel simply fail?
>
> Yes, that would work.

On a second thought, I think it's better the other way.  The
l_netlink_cancel() call can be used as a request to forget the
callbacks.  The user may be tearing down the object they passed as
user_data for example.  IIRC we did take that use case into
consideration in some of the other APIs, what do you think?

>
> >
> > I do wonder why you'd cancel the command from the handler?
>
> In the IWD AP case I want to cancel a dump command which I think is
> already handled correctly, but if the API can be made more robust then
> I think it's an improvement.  There can be complicated code paths
> where you destroy an object that owns the netlink command as a result
> of the command response.
>
> Best regards
--===============5159929780214136127==--

