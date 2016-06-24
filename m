Content-Type: multipart/mixed; boundary="===============6518360118193674347=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] genl: Add unicast listener
Date: Fri, 24 Jun 2016 15:36:05 -0500
Message-ID: <576D99B5.4030407@gmail.com>
In-Reply-To: <1466799183-55537-1-git-send-email-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6518360118193674347==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 06/24/2016 03:13 PM, Tim Kourt wrote:
> ---
>   ell/genl.c | 113 ++++++++++++++++++++++++++++++++++++++----------------=
-------
>   ell/genl.h |  10 ++++--
>   2 files changed, 78 insertions(+), 45 deletions(-)
>
> diff --git a/ell/genl.c b/ell/genl.c
> index 15f4782..767bd2f 100644
> --- a/ell/genl.c
> +++ b/ell/genl.c
> @@ -25,7 +25,6 @@
>   #endif
>
>   #include <errno.h>
> -#include <unistd.h>
>   #include <sys/socket.h>
>   #include <linux/genetlink.h>
>
> @@ -172,7 +171,9 @@ static void mcast_free(void *data, void *user_data)
>   	if (genl && mcast->users > 0) {
>   		int group =3D mcast->id;
>
> -		setsockopt(genl->fd, SOL_NETLINK, NETLINK_DROP_MEMBERSHIP,
> +		if (group)
> +			setsockopt(genl->fd, SOL_NETLINK,
> +							NETLINK_DROP_MEMBERSHIP,
>   							&group, sizeof(group));
>   	}
>
> @@ -227,7 +228,7 @@ static void family_add_mcast(struct l_genl_family *fa=
mily, const char *name,
>
>   	strncpy(mcast->name, name, GENL_NAMSIZ);
>   	mcast->id =3D id;
> -	mcast->users =3D 0;
> +	mcast->users =3D id ? 0 : 1; /* id =3D 0 --> unicast */
>
>   	l_queue_push_tail(family->mcast_list, mcast);
>   }
> @@ -356,44 +357,6 @@ static bool match_request_seq(const void *a, const v=
oid *b)
>   	return request->seq =3D=3D seq;
>   }
>
> -static void process_request(struct l_genl *genl, const struct nlmsghdr *=
nlmsg)
> -{
> -	struct l_genl_msg *msg;
> -	struct genl_request *request;
> -
> -	if (nlmsg->nlmsg_type =3D=3D NLMSG_NOOP ||
> -					nlmsg->nlmsg_type =3D=3D NLMSG_OVERRUN)
> -		return;
> -
> -	request =3D l_queue_remove_if(genl->pending_list, match_request_seq,
> -					L_UINT_TO_PTR(nlmsg->nlmsg_seq));
> -	if (!request)
> -		return;
> -
> -	msg =3D _genl_msg_create(nlmsg);
> -	if (!msg) {
> -		destroy_request(request);
> -		wakeup_writer(genl);
> -		return;
> -	}
> -
> -	if (request->callback && nlmsg->nlmsg_type !=3D NLMSG_DONE)
> -		request->callback(msg, request->user_data);
> -
> -	if (nlmsg->nlmsg_flags & NLM_F_MULTI) {
> -		if (nlmsg->nlmsg_type =3D=3D NLMSG_DONE) {
> -			destroy_request(request);
> -			wakeup_writer(genl);
> -		} else
> -			l_queue_push_head(genl->pending_list, request);
> -	} else {
> -		destroy_request(request);
> -		wakeup_writer(genl);
> -	}
> -
> -	l_genl_msg_unref(msg);
> -}
> -
>   struct notify_type_group {
>   	struct l_genl_msg *msg;
>   	uint16_t type;
> @@ -432,6 +395,46 @@ static void process_notify(struct l_genl *genl, uint=
32_t group,
>   	l_genl_msg_unref(match.msg);
>   }
>
> +static void process_request(struct l_genl *genl, const struct nlmsghdr *=
nlmsg)
> +{
> +	struct l_genl_msg *msg;
> +	struct genl_request *request;
> +
> +	if (nlmsg->nlmsg_type =3D=3D NLMSG_NOOP ||
> +					nlmsg->nlmsg_type =3D=3D NLMSG_OVERRUN)
> +		return;
> +
> +	request =3D l_queue_remove_if(genl->pending_list, match_request_seq,
> +					L_UINT_TO_PTR(nlmsg->nlmsg_seq));
> +	if (!request) {
> +		process_notify(genl, 0, nlmsg);
> +		return;

So inside received_data we do:

if (group > 0)
	process_notify
else
	process_request

And here we call process_notify().  This is weird.  Is there another =

selector besides group we can use to identify the message as a request =

from the kernel?

> +	}
> +
> +	msg =3D _genl_msg_create(nlmsg);
> +	if (!msg) {
> +		destroy_request(request);
> +		wakeup_writer(genl);
> +		return;
> +	}
> +
> +	if (request->callback && nlmsg->nlmsg_type !=3D NLMSG_DONE)
> +		request->callback(msg, request->user_data);
> +
> +	if (nlmsg->nlmsg_flags & NLM_F_MULTI) {
> +		if (nlmsg->nlmsg_type =3D=3D NLMSG_DONE) {
> +			destroy_request(request);
> +			wakeup_writer(genl);
> +		} else
> +			l_queue_push_head(genl->pending_list, request);
> +	} else {
> +		destroy_request(request);
> +		wakeup_writer(genl);
> +	}
> +
> +	l_genl_msg_unref(msg);
> +}
> +
>   static void read_watch_destroy(void *user_data)
>   {
>   }
> @@ -528,7 +531,7 @@ LIB_EXPORT struct l_genl *l_genl_new(int fd)
>   	return l_genl_ref(genl);
>   }
>
> -LIB_EXPORT struct l_genl *l_genl_new_default(void)
> +LIB_EXPORT struct l_genl *l_genl_new_default_for_pid(pid_t pid)
>   {
>   	struct l_genl *genl;
>   	struct sockaddr_nl addr;
> @@ -542,7 +545,7 @@ LIB_EXPORT struct l_genl *l_genl_new_default(void)
>
>   	memset(&addr, 0, sizeof(addr));
>   	addr.nl_family =3D AF_NETLINK;
> -	addr.nl_pid =3D 0;
> +	addr.nl_pid =3D pid;
>
>   	if (bind(fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
>   		close(fd);
> @@ -569,6 +572,11 @@ LIB_EXPORT struct l_genl *l_genl_new_default(void)
>   	return genl;
>   }
>
> +LIB_EXPORT struct l_genl *l_genl_new_default(void)
> +{
> +	return l_genl_new_default_for_pid(0);
> +}
> +
>   LIB_EXPORT struct l_genl *l_genl_ref(struct l_genl *genl)
>   {
>   	if (unlikely(!genl))
> @@ -1232,6 +1240,9 @@ static void add_membership(struct l_genl *genl, str=
uct genl_mcast *mcast)
>   {
>   	int group =3D mcast->id;
>
> +	if (!group)
> +		return;
> +
>   	if (mcast->users > 0)
>   		return;
>
> @@ -1301,6 +1312,22 @@ LIB_EXPORT unsigned int l_genl_family_register(str=
uct l_genl_family *family,
>   	return notify->id;
>   }
>
> +
> +LIB_EXPORT unsigned int
> +l_genl_family_register_ucast_listener(struct l_genl_family *family,
> +					l_genl_msg_func_t ucast_listener,
> +					void *user_data,
> +					l_genl_destroy_func_t destroy)
> +{
> +	const char *unicast_group =3D "unicast";
> +
> +	if (!l_genl_family_has_group(family, unicast_group))
> +		family_add_mcast(family, unicast_group, 0);

So you're adding a multicast family for unicast.  This just doesn't =

compute ;)

> +
> +	return l_genl_family_register(family, unicast_group, ucast_listener,
> +							user_data, destroy);

Funamentally, l_genl is used to send commands and receive responses. =

What you're trying to do is receive commands and send responses.

Whats your plan on how to handle l_genl_msg objects?

How many receivers to you expect?  You can take the easy way out and =

register a single receiver for unicast messages.  Then that receiver =

would be responsible for de-multiplexing the various types of messages =

being received.

Alternatively, the library can handle the de-multiplexing and =

registration/invocation/deregistration of the handlers.

Think l_dbus_send vs l_dbus_interface...

> +}
> +
>   static bool match_notify_id(const void *a, const void *b)
>   {
>   	const struct genl_notify *notify =3D a;
> diff --git a/ell/genl.h b/ell/genl.h
> index 8f5fd52..650f383 100644
> --- a/ell/genl.h
> +++ b/ell/genl.h
> @@ -25,6 +25,7 @@
>
>   #include <stdbool.h>
>   #include <stdint.h>
> +#include <unistd.h>
>
>   #ifdef __cplusplus
>   extern "C" {
> @@ -37,6 +38,7 @@ struct l_genl;
>
>   struct l_genl *l_genl_new(int fd);
>   struct l_genl *l_genl_new_default(void);
> +struct l_genl *l_genl_new_default_for_pid(pid_t pid);
>
>   struct l_genl *l_genl_ref(struct l_genl *genl);
>   void l_genl_unref(struct l_genl *genl);
> @@ -82,6 +84,8 @@ bool l_genl_attr_recurse(struct l_genl_attr *attr, stru=
ct l_genl_attr *nested);
>
>   struct l_genl_family;
>
> +typedef void (*l_genl_msg_func_t)(struct l_genl_msg *msg, void *user_dat=
a);
> +
>   struct l_genl_family *l_genl_family_new(struct l_genl *genl, const char=
 *name);
>
>   struct l_genl_family *l_genl_family_ref(struct l_genl_family *family);
> @@ -94,8 +98,6 @@ bool l_genl_family_set_watches(struct l_genl_family *fa=
mily,
>   				l_genl_watch_func_t vanished,
>   				void *user_data, l_genl_destroy_func_t destroy);
>
> -typedef void (*l_genl_msg_func_t)(struct l_genl_msg *msg, void *user_dat=
a);
> -
>   uint32_t l_genl_family_get_version(struct l_genl_family *family);
>
>   bool l_genl_family_can_send(struct l_genl_family *family, uint8_t cmd);
> @@ -112,6 +114,10 @@ bool l_genl_family_has_group(struct l_genl_family *f=
amily, const char *group);
>   unsigned int l_genl_family_register(struct l_genl_family *family,
>   				const char *group, l_genl_msg_func_t callback,
>   				void *user_data, l_genl_destroy_func_t destroy);
> +unsigned int l_genl_family_register_ucast_listener(struct l_genl_family =
*family,
> +					l_genl_msg_func_t ucast_listener,
> +					void *user_data,
> +					l_genl_destroy_func_t destroy);
>   bool l_genl_family_unregister(struct l_genl_family *family, unsigned in=
t id);
>
>   #ifdef __cplusplus
>

Regards,
-Denis


--===============6518360118193674347==--

