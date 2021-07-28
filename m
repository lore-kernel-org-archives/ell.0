Content-Type: multipart/mixed; boundary="===============5421587723874397288=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/8] dhcp-server: Add "authoritative" mode
Date: Wed, 28 Jul 2021 21:29:48 +0200
Message-ID: <CAOq732LubVFda0Q30qR3_hRT694RmAuN9MRL8q4+d=ED5z6uow@mail.gmail.com>
In-Reply-To: <0672c4d6-c78e-9f32-5aa5-ee5e5d24007c@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5421587723874397288==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 28 Jul 2021 at 20:45, Denis Kenzior <denkenz@gmail.com> wrote:
> >>> @@ -640,6 +639,9 @@ static void listener_event(const void *data, size=
_t len, void *user_data)
> >>>                SERVER_DEBUG("Received DISCOVER, requested IP "NIPQUAD=
_FMT,
> >>>                                        NIPQUAD(requested_ip_opt));
> >>>
> >>> +             if (server_id_opt && server_id_opt !=3D server->address)
> >>> +                     break;
> >>> +
> >>
> >> So strictly speaking, according to DHCPDISCOVER from the client should=
n't even
> >> have this option...
> >
> > Ok, I can make this check stricter here.  I preserved the original
> > logic where we would ignore the whole message if (erver_id_opt !=3D
> > server->address) but otherwise we weren't checking whether the
> > server_id was correct or absent.
> >
>
> Well, the thing is that you've introduced a small ambiguity.  Maybe it do=
esn't
> matter... but...
>
> The prior logic looked at the server_id option if present and compared to=
 our
> own server id.  So the only way you get past the pre-check is if the serv=
er_id
> matched or was omitted entirely.
>
> But now, you can have server_id option from the client that is equal to '=
0', and
> we treat both the same.  So ideally this should be tightened up a bit.

True, if the client includes a 0 server_id we'd treat it as if the
option was omitted.  Let me replace uint32_t server_id_opt with a bool
server_id_opt and a bool server_id_match.

Best regards
--===============5421587723874397288==--

