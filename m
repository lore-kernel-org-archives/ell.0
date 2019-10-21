Content-Type: multipart/mixed; boundary="===============8527275093979551603=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp: Add domain name option handler
Date: Mon, 21 Oct 2019 10:50:55 -0500
Message-ID: <fe3ac0de-38d4-e9bd-691a-d2b3d7202c62@gmail.com>
In-Reply-To: <20191018222919.11454-1-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8527275093979551603==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 10/18/19 5:29 PM, Tim Kourt wrote:
> Add parser and accessor for domain name lease option.
> ---
>   ell/dhcp-lease.c   | 16 +++++++++++++++-
>   ell/dhcp-private.h |  1 +
>   ell/dhcp.h         |  1 +
>   3 files changed, 17 insertions(+), 1 deletion(-)
> =

> diff --git a/ell/dhcp-lease.c b/ell/dhcp-lease.c
> index a48cfa4..ba57322 100644
> --- a/ell/dhcp-lease.c
> +++ b/ell/dhcp-lease.c
> @@ -45,6 +45,8 @@ void _dhcp_lease_free(struct l_dhcp_lease *lease)
>   		return;
>   =

>   	l_free(lease->dns);
> +	l_free(lease->domain_name);
> +
>   	l_free(lease);
>   }
>   =

> @@ -99,6 +101,10 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct=
 dhcp_message_iter *iter)
>   				}
>   			}
>   			break;
> +		case L_DHCP_OPTION_DOMAIN_NAME:
> +			if (l >=3D 1)
> +				lease->domain_name =3D l_strdup(v);
> +			break;

No. You cannot assume that v is null terminated.  Nobody will guarantee =

that the packets coming from the 'dhcp server' aren't fuzzed or are not =

from dhcp server at all.

>   		default:
>   			break;
>   		}
> @@ -124,7 +130,7 @@ struct l_dhcp_lease *_dhcp_lease_parse_options(struct=
 dhcp_message_iter *iter)
>   =

>   	return lease;
>   error:
> -	l_free(lease);
> +	_dhcp_lease_free(lease);
>   	return NULL;
>   }
>   =

> @@ -201,6 +207,14 @@ LIB_EXPORT char **l_dhcp_lease_get_dns(const struct =
l_dhcp_lease *lease)
>   	return dns_list;
>   }
>   =

> +LIB_EXPORT char *l_dhcp_lease_get_domain_name(const struct l_dhcp_lease =
*lease)
> +{
> +	if (unlikely(!lease))
> +		return NULL;
> +
> +	return l_strdup(lease->domain_name);

Strictly speaking this can be const char *, but okay.

> +}
> +
>   LIB_EXPORT uint32_t l_dhcp_lease_get_t1(const struct l_dhcp_lease *leas=
e)
>   {
>   	if (unlikely(!lease))
> diff --git a/ell/dhcp-private.h b/ell/dhcp-private.h
> index 6554fc6..a75bb8b 100644
> --- a/ell/dhcp-private.h
> +++ b/ell/dhcp-private.h
> @@ -120,6 +120,7 @@ struct l_dhcp_lease {
>   	uint32_t t2;
>   	uint32_t router;
>   	uint32_t *dns;
> +	char *domain_name;
>   };
>   =

>   struct l_dhcp_lease *_dhcp_lease_new(void);
> diff --git a/ell/dhcp.h b/ell/dhcp.h
> index c3a4988..b8a5b41 100644
> --- a/ell/dhcp.h
> +++ b/ell/dhcp.h
> @@ -95,6 +95,7 @@ char *l_dhcp_lease_get_netmask(const struct l_dhcp_leas=
e *lease);
>   char *l_dhcp_lease_get_broadcast(const struct l_dhcp_lease *lease);
>   char *l_dhcp_lease_get_server_id(const struct l_dhcp_lease *lease);
>   char **l_dhcp_lease_get_dns(const struct l_dhcp_lease *lease);
> +char *l_dhcp_lease_get_domain_name(const struct l_dhcp_lease *lease);
>   =

>   uint32_t l_dhcp_lease_get_t1(const struct l_dhcp_lease *lease);
>   uint32_t l_dhcp_lease_get_t2(const struct l_dhcp_lease *lease);
> =


Regards,
-Denis
--===============8527275093979551603==--

