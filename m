Content-Type: multipart/mixed; boundary="===============0261366564278592503=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] dhcp-server: Fix debug messages in send_offer
Date: Fri, 09 Jul 2021 10:38:01 -0500
Message-ID: <64738215-9ebf-9b50-32be-2ea9717b64a4@gmail.com>
In-Reply-To: <cf9fb7fb-8c93-49ec-d167-c7a66e0d9131@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0261366564278592503==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 7/9/21 10:12 AM, Denis Kenzior wrote:
> Hi Andrew,
> =

> On 7/9/21 6:47 AM, Andrew Zaborowski wrote:
>> find_free_or_expired_ip() or check_requested_ip() should fail if no
>> addresses are left in the pool, rather than lease_add() so emit that
>> error message there.=C2=A0 The only thing lease_add() validates that has=
 not
>> been validated before might be the origin MAC, treat the lease_add()
>> failure more as an internal error.
>> ---
>> =C2=A0 ell/dhcp-server.c | 4 ++--
>> =C2=A0 1 file changed, 2 insertions(+), 2 deletions(-)
>>
> =


Actually, I pulled patch 3 back.  It doesn't compile:

   CC       ell/dhcp-server.lo
ell/dhcp-server.c: In function =E2=80=98l_dhcp_server_new_lease=E2=80=99:
ell/dhcp-server.c:1071:39: error: implicit declaration of function =E2=80=
=98IP_STR=E2=80=99; did =

you mean =E2=80=98IP_TTL=E2=80=99? [-Werror=3Dimplicit-function-declaration]
  1071 |  SERVER_DEBUG("Allocated %s to " MAC, IP_STR(ip), MAC_STR(mac));
       |                                       ^~~~~~
ell/dhcp-server.c:103:41: note: in definition of macro =E2=80=98SERVER_DEBU=
G=E2=80=99
   103 |    "%s:%i " fmt, __func__, __LINE__, ## args)
       |                                         ^~~~
ell/dhcp-server.c:103:4: error: format =E2=80=98%s=E2=80=99 expects argumen=
t of type =E2=80=98char *=E2=80=99, =

but argument 6 has type =E2=80=98int=E2=80=99 [-Werror=3Dformat=3D]
   103 |    "%s:%i " fmt, __func__, __LINE__, ## args)
       |    ^~~~~~~~
......
  1071 |  SERVER_DEBUG("Allocated %s to " MAC, IP_STR(ip), MAC_STR(mac));
       |                                       ~~~~~~~~~~
       |                                       |
       |                                       int
ell/dhcp-server.c:1071:2: note: in expansion of macro =E2=80=98SERVER_DEBUG=
=E2=80=99
  1071 |  SERVER_DEBUG("Allocated %s to " MAC, IP_STR(ip), MAC_STR(mac));
       |  ^~~~~~~~~~~~

Regards,
-Denis
--===============0261366564278592503==--

