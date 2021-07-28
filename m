Content-Type: multipart/mixed; boundary="===============1442258956385807500=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/8] dhcp-server: Add "authoritative" mode
Date: Wed, 28 Jul 2021 13:39:21 -0500
Message-ID: <0672c4d6-c78e-9f32-5aa5-ee5e5d24007c@gmail.com>
In-Reply-To: <CAOq732+QWBKdY9V=vNiWgeOHXi_-SGaKvg4YZjjb_s7gkBcO7w@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1442258956385807500==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> We were checking the opposite, i.e. we were sending a NAK if it *was* pre=
sent.
> =

> However I was referring to the "!lease" part which seemed to be the
> opposite of what was desired because we were supposed to remain silent
> if we had no previous knowledge of the client.

Okay, yep, it looks like the original logic got this wrong.

>>> @@ -640,6 +639,9 @@ static void listener_event(const void *data, size_t=
 len, void *user_data)
>>>                SERVER_DEBUG("Received DISCOVER, requested IP "NIPQUAD_F=
MT,
>>>                                        NIPQUAD(requested_ip_opt));
>>>
>>> +             if (server_id_opt && server_id_opt !=3D server->address)
>>> +                     break;
>>> +
>>
>> So strictly speaking, according to DHCPDISCOVER from the client shouldn'=
t even
>> have this option...
> =

> Ok, I can make this check stricter here.  I preserved the original
> logic where we would ignore the whole message if (erver_id_opt !=3D
> server->address) but otherwise we weren't checking whether the
> server_id was correct or absent.
> =


Well, the thing is that you've introduced a small ambiguity.  Maybe it does=
n't =

matter... but...

The prior logic looked at the server_id option if present and compared to o=
ur =

own server id.  So the only way you get past the pre-check is if the server=
_id =

matched or was omitted entirely.

But now, you can have server_id option from the client that is equal to '0'=
, and =

we treat both the same.  So ideally this should be tightened up a bit.

>>
>>>                send_offer(server, message, lease, requested_ip_opt);
>>>
>>>                break;
>>> @@ -647,27 +649,92 @@ static void listener_event(const void *data, size=
_t len, void *user_data)
>>>                SERVER_DEBUG("Received REQUEST, requested IP "NIPQUAD_FM=
T,
>>>                                NIPQUAD(requested_ip_opt));
>>>
>>> -             if (requested_ip_opt =3D=3D 0) {
>>> -                     requested_ip_opt =3D message->ciaddr;
>>> -                     if (requested_ip_opt =3D=3D 0)
>>> +             /*
>>> +              * RFC2131 Section 3.5: "Those servers not selected by the
>>> +              * DHCPREQUEST message use the message as notification th=
at
>>> +              * the client has declined that server's offer."
>>> +              */
>>> +             if (server_id_opt && server_id_opt !=3D server->address) {

This is inconsistent with how you do the server_id_opt checks later on.  I =

should have checked the original and not just the diff, but from the diff i=
t =

seemed like server_id_opt was meant to be a pointer.  Not sure why my brain =

didn't register that there was no dereference.  So you can ignore some of m=
y =

comments based on the above.

>>> +                     if (server->authoritative) {
>>> +                             send_nak(server, message);
>>>                                break;
>>
>> So you send a NAK here if server_id_opt is provided and doesn't match...
>>
>>> -             }
>>> +                     }
>>>
>>> -             if (lease && requested_ip_opt =3D=3D lease->address) {
>>> -                     send_ack(server, message, lease->address);
>>> +                     if (!lease || !lease->offering)
>>> +                             break;
>>> +
>>> +                     remove_lease(server, lease);
>>>                        break;
>>>                }
>>>
>>> -             if (server_id_opt || !lease) {
>>> -                     send_nak(server, message);
>>> +             /*
>>> +              * RFC2131 Section 3.5: "If the selected server is unable=
 to
>>> +              * satisfy the DHCPREQUEST message (...), the server SHOU=
LD
>>> +              * respond with a DHCPNAK message."
>>> +              *
>>> +              * But:
>>> +              * 4.3.2: "If the DHCP server has no record of this clien=
t,
>>> +              * then it MUST remain silent (...)"
>>> +              */
>>> +             if (!lease) {
>>> +                     if (server_id_opt =3D=3D server->address ||
>>> +                                     server->authoritative)
>>
>> So why check server->authoritative here?  It seems like you can only get=
 to this
>> point if the server_id_opt is provided and matches, or not provided at a=
ll.
> =

> Right, I guess I could have simply written (server_id_opt ||
> server->authoritative) beause as you noted, we've already checked that
> if server_id was present, it was correct.
> =

> The server->authoritative part is so that we send a NAK if no
> server_id was provided and we know we're the only server on the
> network.

Okay, makes sense.

Regards,
-Denis
--===============1442258956385807500==--

