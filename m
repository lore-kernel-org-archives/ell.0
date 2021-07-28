Content-Type: multipart/mixed; boundary="===============1142661541708878617=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 3/8] dhcp-server: Respect client's broadcast flag
Date: Wed, 28 Jul 2021 19:57:52 +0200
Message-ID: <CAOq732KRiRO1KR-NYYMzwFMtnR14-hMBDyfwakVz8Ek5T7KDWg@mail.gmail.com>
In-Reply-To: <30283874-160a-eb89-cf8a-008e06288bcc@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1142661541708878617==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, 28 Jul 2021 at 18:06, Denis Kenzior <denkenz@gmail.com> wrote:
> On 7/23/21 1:23 PM, Andrew Zaborowski wrote:
> >   static void send_inform(struct l_dhcp_server *server,
> > @@ -515,11 +576,7 @@ static void send_inform(struct l_dhcp_server *serv=
er,
> >
> >       _dhcp_message_builder_finalize(&builder, &len);
> >
> > -     if (server->transport->l2_send(server->transport, server->address,
> > -                                     DHCP_PORT_SERVER, reply->ciaddr,
> > -                                     DHCP_PORT_CLIENT, reply->chaddr,
> > -                                     reply, len) < 0)
> > -             SERVER_DEBUG("Failed to send INFORM");
> > +     server_message_send(server, reply, len, DHCP_MESSAGE_TYPE_ACK);
>
> Inform?

Yep, right.

Best regards
--===============1142661541708878617==--

