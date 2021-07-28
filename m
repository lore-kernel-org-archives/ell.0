Content-Type: multipart/mixed; boundary="===============7481106626827017530=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/8] dhcp-server: Add "authoritative" mode
Date: Wed, 28 Jul 2021 19:51:19 +0200
Message-ID: <CAOq732+QWBKdY9V=vNiWgeOHXi_-SGaKvg4YZjjb_s7gkBcO7w@mail.gmail.com>
In-Reply-To: <fc2fc4b7-8892-81fb-1658-33fa79ab33dc@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7481106626827017530==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Wed, 28 Jul 2021 at 18:01, Denis Kenzior <denkenz@gmail.com> wrote:
> On 7/23/21 1:23 PM, Andrew Zaborowski wrote:
> > An authoritative DHCP server basically assumes that there are no other
> > DHCP servers on the network and replies to DHCPREQUEST messages
> > requesting IPs from outside of its subnet or with a wrong server ID
> > value.  This speeds up connections from clients who try to use IP
> > leases they have cached from other networks and who start their IP
> > configuration by trying DHCPREQUESTs for those leases.
> >
> > The term is not defined in the DHCP standard but is used by various
> > implementations.  Default to authoritative being true.  When set to
> > false, handle a DHCPREQUEST message directed at other servers by taking
> > it as meaning the client is declining our own lease offer as mandated
> > by RFC 2131 on page 16.
> >
> > Refactor the checks in DHCPREQUEST handling quoting parts of the RFC.
> > The new checks are stricter and I'm not preserving some of the checks
> > that didn't seem justified, for example in the
> > "if (server_id_opt || !lease) ... send_nak()" block it didn't seem to
> > make sense to only reply to clients who have no lease (offered or
> > active) and ignore those who do have a lease with a different IP
> > address, the opposite would make more sense.
>
> It seems like this is supposed to be handling the init-reboot, bound, ren=
ewing,
> rebinding states where server_id isn't present...?

We were checking the opposite, i.e. we were sending a NAK if it *was* prese=
nt.

However I was referring to the "!lease" part which seemed to be the
opposite of what was desired because we were supposed to remain silent
if we had no previous knowledge of the client.

>
> > ---
> >   ell/dhcp-server.c | 109 ++++++++++++++++++++++++++++++++++++++++------
> >   ell/dhcp.h        |   2 +
> >   ell/ell.sym       |   1 +
> >   3 files changed, 98 insertions(+), 14 deletions(-)
> >
> > diff --git a/ell/dhcp-server.c b/ell/dhcp-server.c
> > index bae0f10..6415872 100644
> > --- a/ell/dhcp-server.c
> > +++ b/ell/dhcp-server.c
> > @@ -87,6 +87,8 @@ struct l_dhcp_server {
> >       struct dhcp_transport *transport;
> >
> >       struct l_acd *acd;
> > +
> > +     bool authoritative : 1;
> >   };
> >
> >   #define MAC "%02x:%02x:%02x:%02x:%02x:%02x"
> > @@ -615,9 +617,6 @@ static void listener_event(const void *data, size_t=
 len, void *user_data)
> >                       if (l =3D=3D 4)
> >                               server_id_opt =3D l_get_u32(v);
> >
> > -                     if (server->address !=3D server_id_opt)
> > -                             return;
> > -
> >                       break;
> >               case L_DHCP_OPTION_REQUESTED_IP_ADDRESS:
> >                       if (l =3D=3D 4)
> > @@ -640,6 +639,9 @@ static void listener_event(const void *data, size_t=
 len, void *user_data)
> >               SERVER_DEBUG("Received DISCOVER, requested IP "NIPQUAD_FM=
T,
> >                                       NIPQUAD(requested_ip_opt));
> >
> > +             if (server_id_opt && server_id_opt !=3D server->address)
> > +                     break;
> > +
>
> So strictly speaking, according to DHCPDISCOVER from the client shouldn't=
 even
> have this option...

Ok, I can make this check stricter here.  I preserved the original
logic where we would ignore the whole message if (erver_id_opt !=3D
server->address) but otherwise we weren't checking whether the
server_id was correct or absent.

>
> >               send_offer(server, message, lease, requested_ip_opt);
> >
> >               break;
> > @@ -647,27 +649,92 @@ static void listener_event(const void *data, size=
_t len, void *user_data)
> >               SERVER_DEBUG("Received REQUEST, requested IP "NIPQUAD_FMT,
> >                               NIPQUAD(requested_ip_opt));
> >
> > -             if (requested_ip_opt =3D=3D 0) {
> > -                     requested_ip_opt =3D message->ciaddr;
> > -                     if (requested_ip_opt =3D=3D 0)
> > +             /*
> > +              * RFC2131 Section 3.5: "Those servers not selected by the
> > +              * DHCPREQUEST message use the message as notification th=
at
> > +              * the client has declined that server's offer."
> > +              */
> > +             if (server_id_opt && server_id_opt !=3D server->address) {
> > +                     if (server->authoritative) {
> > +                             send_nak(server, message);
> >                               break;
>
> So you send a NAK here if server_id_opt is provided and doesn't match...
>
> > -             }
> > +                     }
> >
> > -             if (lease && requested_ip_opt =3D=3D lease->address) {
> > -                     send_ack(server, message, lease->address);
> > +                     if (!lease || !lease->offering)
> > +                             break;
> > +
> > +                     remove_lease(server, lease);
> >                       break;
> >               }
> >
> > -             if (server_id_opt || !lease) {
> > -                     send_nak(server, message);
> > +             /*
> > +              * RFC2131 Section 3.5: "If the selected server is unable=
 to
> > +              * satisfy the DHCPREQUEST message (...), the server SHOU=
LD
> > +              * respond with a DHCPNAK message."
> > +              *
> > +              * But:
> > +              * 4.3.2: "If the DHCP server has no record of this clien=
t,
> > +              * then it MUST remain silent (...)"
> > +              */
> > +             if (!lease) {
> > +                     if (server_id_opt =3D=3D server->address ||
> > +                                     server->authoritative)
>
> So why check server->authoritative here?  It seems like you can only get =
to this
> point if the server_id_opt is provided and matches, or not provided at al=
l.

Right, I guess I could have simply written (server_id_opt ||
server->authoritative) beause as you noted, we've already checked that
if server_id was present, it was correct.

The server->authoritative part is so that we send a NAK if no
server_id was provided and we know we're the only server on the
network.

> The
> 'server_id_opt =3D=3D' part also seems unsafe for those cases where serve=
r_id isn't
> provided at all...?

server_id_opt would be 0 in that case, so if (server_id_opt =3D=3D
server->address) we know that it was present in the message and
correct, i.e. addressed at us.

>
> > +                             send_nak(server, message);
> > +
> >                       break;
> >               }
> > +
> > +             /*
> > +              * 4.3.2: "If the DHCPREQUEST message contains a 'server
> > +              * identifier' option, the message is in response to a
> > +              * DHCPOFFER message.  Otherwise, the message is a request
> > +              * to verify or extend an existing lease."
> > +              */
> > +             if (server_id_opt =3D=3D server->address) {
>
> Same here, checking server_id_opt seems unsafe?

Same comment as above.

>
> > +                     /*
> > +                      * Allow either no 'requested IP address' option =
or
> > +                      * a value identical with the one we offered beca=
use
> > +                      * the spec is unclear on whether it is to be
> > +                      * included:
> > +                      *
> > +                      * Section 4.3.2: "DHCPREQUEST generated during
> > +                      * SELECTING state: (...) 'requested IP address' =
MUST
> > +                      * be filled in with the yiaddr value from the ch=
osen
> > +                      * DHCPOFFER."
> > +                      *
> > +                      * but section 3.5 suggests only in the INIT-REBO=
OT
> > +                      * state: "The 'requested IP address' option is t=
o be
> > +                      * filled in only in a DHCPREQUEST message when t=
he
> > +                      * client is verifying network parameters obtained
> > +                      * previously."
> > +                      */
> > +                     if (!lease->offering ||
> > +                                     (requested_ip_opt &&
> > +                                      requested_ip_opt !=3D lease->add=
ress)) {
> > +                             send_nak(server, message);
> > +                             break;
> > +                     }
> > +             } else {
> > +                     /*
> > +                      * 3.5: "If a server receives a DHCPREQUEST messa=
ge
> > +                      * with an invalid 'requested IP address', the se=
rver
> > +                      * SHOULD respond to the client with a DHCPNAK me=
ssage"
> > +                      */
> > +                     if (lease->offering ||
> > +                                     (requested_ip_opt &&
> > +                                      requested_ip_opt !=3D lease->add=
ress)) {
> > +                             send_nak(server, message);
> > +                             break;
> > +                     }
> > +             }
> > +
> > +             send_ack(server, message, lease->address);
> >               break;
> >       case DHCP_MESSAGE_TYPE_DECLINE:
> >               SERVER_DEBUG("Received DECLINE");
> >
> > -             if (!server_id_opt || !requested_ip_opt || !lease ||
> > -                             !lease->offering)
> > +             if (server_id_opt !=3D server->address || !requested_ip_o=
pt ||
> > +                             !lease || !lease->offering)
>
> This also seems unsafe? server_id must be present, but you're not checkin=
g this
> here?

Here we bail out if the server_id was absent (server_id_opt =3D=3D 0) or
incorrect (server_id_opt !=3D 0 && server_id_opt !=3D server->address),
i.e. preserving the old logic.

>
> >                       break;
> >
> >               if (requested_ip_opt =3D=3D lease->address)
> > @@ -677,7 +744,8 @@ static void listener_event(const void *data, size_t=
 len, void *user_data)
> >       case DHCP_MESSAGE_TYPE_RELEASE:
> >               SERVER_DEBUG("Received RELEASE");
> >
> > -             if (!server_id_opt || !lease || lease->offering)
> > +             if (server_id_opt !=3D server->address || !lease ||
> > +                             lease->offering)
>
> Or here?

Same as above.

Best regards
--===============7481106626827017530==--

