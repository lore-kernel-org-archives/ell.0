Content-Type: multipart/mixed; boundary="===============6170724017848718688=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] tls: Flush rx buffer on failure
Date: Wed, 09 May 2018 08:55:40 -0500
Message-ID: <d9822195-71d0-c3bf-5b71-89441c8a5b1f@gmail.com>
In-Reply-To: <20180509111303.7543-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6170724017848718688==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 05/09/2018 06:13 AM, Andrew Zaborowski wrote:
> When we send an Alert message to the peer (and our alerts are always
> fatal) ignore any buffered messages we've received.  When the
> certificate chain verification fails on a client we are usually
> processing the third message in a sequence of five received from the
> server.  We would then send an Alert and forget the negotiated state,
> then process the two remaining messages which would result in two more
> Alerts being sent, with the default TLS 1.0 version header.  There is
> no need to process those remaining messages.
> ---
>   ell/tls-private.h |  1 +
>   ell/tls-record.c  | 10 ++++++++++
>   2 files changed, 11 insertions(+)
> =


Applied, thanks.

Regards,
-Denis


--===============6170724017848718688==--

