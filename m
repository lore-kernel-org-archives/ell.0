Content-Type: multipart/mixed; boundary="===============7404077904431697796=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz at gmail.com>
To: ell at lists.01.org
Subject: Re: [PATCH 1/3] dhcp: Add priority to logging
Date: Tue, 17 May 2022 11:40:14 -0500
Message-ID: <e1a8c1c0-b206-ee69-130a-a13aff9e290a@gmail.com>
In-Reply-To: 20220517161831.126597-1-mjohnson459@gmail.com

--===============7404077904431697796==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Michael,

On 5/17/22 11:18, Michael Johnson wrote:
> Most dhcp clients have some logging to show what state the lease is in
> so this just makes iwd more in line with them. The logging won't be
> enabled by default but requires a max logging level to be passed in when
> logging is set up.
> ---
>   ell/dhcp.c | 64 +++++++++++++++++++++++++++++-------------------------
>   ell/dhcp.h |  2 +-
>   2 files changed, 35 insertions(+), 31 deletions(-)
> =


<snip>

Looks good to me.  I have a few nits below, which I can probably fix myself=
 if =

you feel lazy :)

Do you want to send a patch for iwd as well?

>   =

> -#define CLIENT_DEBUG(fmt, args...)					\
> -	l_util_debug(client->debug_handler, client->debug_data,		\
> -			"%s:%i " fmt, __func__, __LINE__, ## args)
> +#define CLIENT_DEBUG(priority, fmt, args...)					\
> +	if (priority <=3D client->debug_level)		\
> +		l_util_debug(client->debug_handler, client->debug_data,		\
> +				"%s:%i " fmt, __func__, __LINE__, ## args)

Looks like there's one tab too many before all the '\'.

>   #define CLIENT_ENTER_STATE(s)						\
>   	l_util_debug(client->debug_handler, client->debug_data,		\
>   			"%s:%i Entering state: " #s,			\

<snip>

> @@ -425,14 +428,14 @@ static int dhcp_client_send_request(struct l_dhcp_c=
lient *client)
>   		if (!_dhcp_message_builder_append(&builder,
>   					L_DHCP_OPTION_SERVER_IDENTIFIER,
>   					4, &client->lease->server_address)) {
> -			CLIENT_DEBUG("Failed to append server ID");
> +			CLIENT_DEBUG(L_LOG_WARNING, "Failed to append server ID");

Can we split this to multiple lines to avoid lines that are >80 chars? =

Something like
	CLIENT_DEBUG(L_LOG_WARNING,\n
			"<Message to print>",
			arg1, .. argn);

See doc/coding-style.txt item M4.

For strings that don't fit on a single line, it is fine to go over 80 chars.

Alternatively we could add CLIENT_WARN, CLIENT_INFO, etc

>   			return -EINVAL;
>   		}
>   =


Regards,
-Denis
--===============7404077904431697796==--

