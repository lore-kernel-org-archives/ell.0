Content-Type: multipart/mixed; boundary="===============5092821790729278257=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/5] pem: add _from_data variants to pem APIs
Date: Fri, 27 Sep 2019 15:24:11 -0500
Message-ID: <88144ddd-c15a-e6c8-c337-08eedf6b5b32@gmail.com>
In-Reply-To: <20190927193009.30262-2-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5092821790729278257==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 9/27/19 2:30 PM, James Prestwood wrote:
> Loading cert chains/lists, and private keys was only possible to
> do from a file, or as a raw buffer (e.g. from the network). This
> patch adds 3 new APIs:
> =

> l_pem_load_certificate_chain_from_data
> l_pem_load_certificate_list_from_data
> l_pem_load_private_key_from_data
> =

> These expect the input data just as if it was read in from a PEM
> file (BEGIN/END included).
> ---
>   ell/ell.sym |   3 ++
>   ell/pem.c   | 141 +++++++++++++++++++++++++++++++++++++---------------
>   ell/pem.h   |   7 +++
>   3 files changed, 111 insertions(+), 40 deletions(-)
> =


Patches 1 & 2 applied, thanks.

Regards,
-Denis


--===============5092821790729278257==--

