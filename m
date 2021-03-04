Content-Type: multipart/mixed; boundary="===============7513974445152662067=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] dhcp-server: Stricter start_ip/end_ip checks
Date: Wed, 03 Mar 2021 20:17:09 -0600
Message-ID: <ae34214f-5243-27d3-468f-933961a8116c@gmail.com>
In-Reply-To: <0fd4ffee-4b69-ecdd-bb5c-845598efc9ff@disroot.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7513974445152662067==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi =C3=89rico,

>> -=C2=A0=C2=A0=C2=A0 if (htonl(requested_nip) > server->end_ip)
>> +=C2=A0=C2=A0=C2=A0 if (ntohl(requested_nip) > server->end_ip)
> =

> The commit message didn't mention anything about fixing wrong htonl usage=
, so is =

> this change correct?
> =


Eagle eyes ;)

But yes, the change is correct.  In the end both ntohl and htonl resolve to=
 a =

no_op or bswap32.  So the end result is the same.

Not sure why it was originally written as htonl, but ntohl is more logicall=
y =

correct since requested_nip is is network order and end_ip is in host order.

Ideally there should have been a separate fixup commit for this...

Regards,
-Denis
--===============7513974445152662067==--

