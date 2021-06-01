Content-Type: multipart/mixed; boundary="===============5548280507787228044=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/4] dhcp-server: Expire the lease from the right list
Date: Tue, 01 Jun 2021 09:44:34 -0500
Message-ID: <ee914f53-24db-b06e-a648-9aadb4a27c53@gmail.com>
In-Reply-To: <20210601020346.35502-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5548280507787228044==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/31/21 9:03 PM, Andrew Zaborowski wrote:
> We were trying to expire the oldest lease from server->expired_list but
> we should be expiring the oldest lease in server->lease_list.  We were
> never adding any new entries to server->expired_list and it would be
> always empty.
> ---
>   ell/dhcp-server.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Patch 2-4 applied, thanks.

Regards,
-Denis

--===============5548280507787228044==--

