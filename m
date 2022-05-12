Content-Type: multipart/mixed; boundary="===============2486686211411731938=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 01/13] net: Add l_net_clear_host_bits utility
Date: Thu, 12 May 2022 11:02:34 -0500
Message-ID: <9ebeb857-4ac0-9d3f-e47f-182b1758ebf9@gmail.com>
In-Reply-To: 20220505231539.888792-1-andrew.zaborowski@intel.com

--===============2486686211411731938==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 5/5/22 18:15, Andrew Zaborowski wrote:
> Add function that zeros bits after prefix_len'th bit in an address.  Put
> it in net.h so it can be use by both netconfig.c and icmp6.c,
> potentially others.
> ---
>   ell/net.h | 13 +++++++++++++
>   1 file changed, 13 insertions(+)
> =

> diff --git a/ell/net.h b/ell/net.h
> index 0521d75..e193eef 100644
> --- a/ell/net.h
> +++ b/ell/net.h
> @@ -61,6 +61,19 @@ static inline bool l_net_prefix_matches(const void *a,=
 const void *b,
>   	return !bits || ((left ^ right) & (0xff00u >> bits)) =3D=3D 0;
>   }
>   =

> +static inline void l_net_clear_host_bits(uint8_t *address, uint8_t prefi=
x_len,
> +						uint8_t bytes)

I'm not super excited about the naming.  What about l_net_prefix_from_addre=
ss()? =

  Alternatively, we do have net-private.h where we can stuff this for now a=
nd =

not expose it to public API.

> +{
> +	uint8_t last_byte =3D prefix_len / 8;
> +
> +	if (prefix_len & 7) {
> +		address[last_byte] &=3D 0xff00 >> (prefix_len & 7);
> +		last_byte++;
> +	}
> +
> +	memset(address + last_byte, 0, bytes - last_byte);
> +}
> +
>   #ifdef __cplusplus
>   }
>   #endif
> =


Regards,
-Denis
--===============2486686211411731938==--

