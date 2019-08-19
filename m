Content-Type: multipart/mixed; boundary="===============0690368665996464233=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] tls: Escape characters in the peer_identity string
Date: Mon, 19 Aug 2019 15:21:07 -0500
Message-ID: <bb089e3c-b203-320f-c7eb-ed0f2bc10b52@gmail.com>
In-Reply-To: <20190817002834.15208-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0690368665996464233==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 8/16/19 7:28 PM, Andrew Zaborowski wrote:
> Escape the /, =3D and \ characters in the strings we take from the peer
> certificate's Subject DN to build the peer_identity string passed to the
> ell client's ready callback to enable it to be parsed unamiguously.
> ---
>   ell/tls.c | 21 ++++++++++++++++++++-
>   1 file changed, 20 insertions(+), 1 deletion(-)
> =


Patch 1 & 2 applied, thanks.

Regards,
-Denis


--===============0690368665996464233==--

