Content-Type: multipart/mixed; boundary="===============2587663538971270788=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH] dhcp-transport: Do not leak fds during bind
Date: Wed, 18 May 2022 11:22:32 -0500
Message-ID: <ec5e1008-0298-e17c-7aa7-1a9ca69face1@gmail.com>
In-Reply-To: 20220516195533.31106-1-denkenz@gmail.com

--===============2587663538971270788==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 5/16/22 14:55, Denis Kenzior wrote:
> When a lease is renewed, the transport bind operation is called.  This
> can be done multiple times by dhcp_client, whenever a lease has been
> obtained or renewed.  This can result in fds being leaked.
> =

> If bind operation has previously succeeded, simply return and reuse the
> already created fd.
> ---
>   ell/dhcp-transport.c | 4 ++++
>   1 file changed, 4 insertions(+)
> =


Applied.

--===============2587663538971270788==--

