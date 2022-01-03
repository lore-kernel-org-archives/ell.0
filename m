Content-Type: multipart/mixed; boundary="===============5465687262478283002=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 3/4] icmp6: Respect lifetime values in a RA
Date: Mon, 03 Jan 2022 12:44:49 -0600
Message-ID: <13e7bc94-5030-085f-a084-4672950c568b@gmail.com>
In-Reply-To: 20220103141830.311011-3-andrew.zaborowski@intel.com

--===============5465687262478283002==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 1/3/22 08:18, Andrew Zaborowski wrote:
> If the router lifetime is 0 in a RA that router is not supposed to be
> added to the Default Router List in RFC4861:
> =

> "A value of zero indicates that the router is not to be used as a
> default router."
> =


You may want to put this into the code directly.

> "A router might want to send Router Advertisements without advertising
> itself as a default router.  For instance, a router might advertise
> prefixes for stateless address autoconfiguration while not wishing to
> forward packets.  Such a router sets the Router Lifetime field in
> outgoing advertisements to zero."
> =


But yes, this part makes sense and no objections here.

> Also set the lifetime values on the routes to those received so that the
> user of, say, l_icmp6_client_get_router(), can also determine whether
> there is a default router.

Note that we do not re-upload the routes to the kernel on every RA received=
. =

See the TODO comment in icmp6_client_handle_message().  Once lifetime expir=
es, =

the route will be removed -> internet is broke.  Please at least sanity tes=
t the =

changes you're sending out or label them as RFC if you haven't done so.

> ---
>   ell/icmp6.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
> =


Regards,
-Denis
--===============5465687262478283002==--

