Content-Type: multipart/mixed; boundary="===============6621824452741281213=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp: Add domain name option handler
Date: Mon, 09 Dec 2019 09:20:11 -0600
Message-ID: <55d6b0de-f096-450c-0592-a5cd3afbfd74@gmail.com>
In-Reply-To: <20191206232144.3331-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6621824452741281213==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 12/6/19 5:21 PM, Tim Kourt wrote:
> Add parser and accessor for the domain name lease option.
> ---
>   ell/dhcp-lease.c   | 24 +++++++++++++++++++++++-
>   ell/dhcp-private.h |  1 +
>   ell/dhcp.h         |  1 +
>   3 files changed, 25 insertions(+), 1 deletion(-)
> =


<snip>

> @@ -99,6 +101,18 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct=
 dhcp_message_iter *iter)
>   				}
>   			}
>   			break;
> +		case L_DHCP_OPTION_DOMAIN_NAME:
> +			if (l < 1)
> +				break;
> +
> +			lease->domain_name =3D l_new(char, l + 1);
> +
> +			memcpy(lease->domain_name, v, l);
> +
> +			if (lease->domain_name[l - 1] !=3D '\0')
> +				lease->domain_name[l] =3D '\0';

So strictly speaking this if is not necessary as you already use l_new =

which memsets returned memory to 0.  However, you might want to be much =

more strict about accepting NULs at the end.  One is okay, multiple is =

likely not ok.  Embedded NULs are probably not okay either.

Also, it might be a good idea to more strictly check the domain name =

here.  Fail if we get an empty string, a dot or localhost.  I believe =

hostnames has a max length as well.  And we should maybe limit these to =

ascii or at least valid utf8 for now.

> +
> +			break;
>   		default:
>   			break;
>   		}

Regards,
-Denis
--===============6621824452741281213==--

