Content-Type: multipart/mixed; boundary="===============4513900821194474520=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] dhcp-server: Fix debug messages in send_offer
Date: Fri, 09 Jul 2021 10:12:45 -0500
Message-ID: <cf9fb7fb-8c93-49ec-d167-c7a66e0d9131@gmail.com>
In-Reply-To: <20210709114743.378521-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4513900821194474520==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 7/9/21 6:47 AM, Andrew Zaborowski wrote:
> find_free_or_expired_ip() or check_requested_ip() should fail if no
> addresses are left in the pool, rather than lease_add() so emit that
> error message there.  The only thing lease_add() validates that has not
> been validated before might be the origin MAC, treat the lease_add()
> failure more as an internal error.
> ---
>   ell/dhcp-server.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> =


All applied, thanks.

Regards,
-Denis

--===============4513900821194474520==--

