Content-Type: multipart/mixed; boundary="===============8921938032477463613=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3] genl: Add unicast handler
Date: Thu, 07 Jul 2016 17:22:38 -0500
Message-ID: <577ED62E.8080500@gmail.com>
In-Reply-To: <1467846881-31623-1-git-send-email-tim.a.kourt@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8921938032477463613==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tim,

On 07/06/2016 06:14 PM, Tim Kourt wrote:
> ---
>   ell/genl.c | 162 ++++++++++++++++++++++++++++++++++++++++--------------=
-------
>   ell/genl.h |  19 +++++---
>   2 files changed, 121 insertions(+), 60 deletions(-)
>
> diff --git a/ell/genl.c b/ell/genl.c
> index 15f4782..de71a93 100644
> --- a/ell/genl.c
> +++ b/ell/genl.c
> @@ -39,6 +39,12 @@
>
>   #define MAX_NESTING_LEVEL 4
>
> +struct genl_unicast_notify {
> +	l_genl_msg_func_t handler;
> +	l_genl_destroy_func_t destroy;
> +	void *user_data;
> +};
> +
>   struct l_genl {
>   	int ref_count;
>   	int fd;
> @@ -54,6 +60,7 @@ struct l_genl {
>   	unsigned int next_notify_id;
>   	struct l_queue *family_list;
>   	struct l_genl_family *nlctrl;
> +	struct genl_unicast_notify *unicast_notify;
>   	l_genl_debug_func_t debug_callback;
>   	l_genl_destroy_func_t debug_destroy;
>   	void *debug_data;
> @@ -82,7 +89,7 @@ struct genl_request {
>   	void *user_data;
>   };
>
> -struct genl_notify {
> +struct genl_mcast_notify {
>   	unsigned int id;
>   	uint16_t type;
>   	uint32_t group;
> @@ -133,7 +140,7 @@ static void destroy_request(void *data)
>
>   static void destroy_notify(void *data)
>   {
> -	struct genl_notify *notify =3D data;
> +	struct genl_mcast_notify *notify =3D data;
>
>   	if (notify->destroy)
>   		notify->destroy(notify->user_data);
> @@ -356,10 +363,11 @@ static bool match_request_seq(const void *a, const =
void *b)
>   	return request->seq =3D=3D seq;
>   }
>
> -static void process_request(struct l_genl *genl, const struct nlmsghdr *=
nlmsg)
> +static void process_unicast(struct l_genl *genl, const struct nlmsghdr *=
nlmsg)
>   {
>   	struct l_genl_msg *msg;
>   	struct genl_request *request;
> +	struct genl_unicast_notify *notify;
>
>   	if (nlmsg->nlmsg_type =3D=3D NLMSG_NOOP ||
>   					nlmsg->nlmsg_type =3D=3D NLMSG_OVERRUN)
> @@ -367,28 +375,34 @@ static void process_request(struct l_genl *genl, co=
nst struct nlmsghdr *nlmsg)
>
>   	request =3D l_queue_remove_if(genl->pending_list, match_request_seq,
>   					L_UINT_TO_PTR(nlmsg->nlmsg_seq));
> -	if (!request)
> -		return;
>
>   	msg =3D _genl_msg_create(nlmsg);
>   	if (!msg) {
> -		destroy_request(request);
> -		wakeup_writer(genl);
> +		if (request) {
> +			destroy_request(request);
> +			wakeup_writer(genl);
> +		}
>   		return;
>   	}
>
> -	if (request->callback && nlmsg->nlmsg_type !=3D NLMSG_DONE)
> -		request->callback(msg, request->user_data);
> -
> -	if (nlmsg->nlmsg_flags & NLM_F_MULTI) {
> -		if (nlmsg->nlmsg_type =3D=3D NLMSG_DONE) {
> +	if (request) {
> +		if (request->callback && nlmsg->nlmsg_type !=3D NLMSG_DONE)
> +			request->callback(msg, request->user_data);
> +
> +		if (nlmsg->nlmsg_flags & NLM_F_MULTI) {
> +			if (nlmsg->nlmsg_type =3D=3D NLMSG_DONE) {
> +				destroy_request(request);
> +				wakeup_writer(genl);
> +			} else
> +				l_queue_push_head(genl->pending_list, request);
> +		} else {
>   			destroy_request(request);
>   			wakeup_writer(genl);
> -		} else
> -			l_queue_push_head(genl->pending_list, request);
> +		}
>   	} else {
> -		destroy_request(request);
> -		wakeup_writer(genl);
> +		notify =3D genl->unicast_notify;
> +		if (notify && notify->handler)
> +			notify->handler(msg, notify->user_data);
>   	}
>
>   	l_genl_msg_unref(msg);
> @@ -402,7 +416,7 @@ struct notify_type_group {
>
>   static void notify_handler(void *data, void *user_data)
>   {
> -	struct genl_notify *notify =3D data;
> +	struct genl_mcast_notify *notify =3D data;
>   	struct notify_type_group *match =3D user_data;
>
>   	if (notify->type !=3D match->type)
> @@ -415,7 +429,7 @@ static void notify_handler(void *data, void *user_dat=
a)
>   		notify->callback(match->msg, notify->user_data);
>   }
>
> -static void process_notify(struct l_genl *genl, uint32_t group,
> +static void process_multicast(struct l_genl *genl, uint32_t group,
>   						const struct nlmsghdr *nlmsg)
>   {
>   	struct notify_type_group match;
> @@ -487,25 +501,38 @@ static bool received_data(struct l_io *io, void *us=
er_data)
>   	for (nlmsg =3D iov.iov_base; NLMSG_OK(nlmsg, bytes_read);
>   				nlmsg =3D NLMSG_NEXT(nlmsg, bytes_read)) {
>   		if (group > 0)
> -			process_notify(genl, group, nlmsg);
> +			process_multicast(genl, group, nlmsg);
>   		else
> -			process_request(genl, nlmsg);
> +			process_unicast(genl, nlmsg);
>   	}
>
>   	return true;
>   }
>
> -LIB_EXPORT struct l_genl *l_genl_new(int fd)
> +LIB_EXPORT struct l_genl *l_genl_new(pid_t unique_id)
>   {
>   	struct l_genl *genl;
> +	struct sockaddr_nl addr;
> +	socklen_t addrlen =3D sizeof(addr);
> +	int fd, pktinfo =3D 1;
> +
> +	fd =3D socket(PF_NETLINK, SOCK_DGRAM | SOCK_CLOEXEC | SOCK_NONBLOCK,
> +							NETLINK_GENERIC);
> +	if (fd < 0)
> +		return NULL;
> +
> +	memset(&addr, 0, sizeof(addr));
> +	addr.nl_family =3D AF_NETLINK;
> +	addr.nl_pid =3D unique_id;

from man 7 netlink:

"nl_pid is the unicast address of netlink socket.  It's always 0 if
  the destination is in the kernel.  For a user-space process, nl_pid
  is usually the PID of the process owning the destination socket.
  However, nl_pid identifies a netlink socket, not a process.  If a
  process owns several netlink sockets, then nl_pid can be equal to the
  process ID only for at most one socket.  There are two ways to assign
  nl_pid to a netlink socket.  If the application sets nl_pid before
  calling bind(2), then it is up to the application to make sure that
  nl_pid is unique.  If the application sets it to 0, the kernel takes
  care of assigning it.  The kernel assigns the process ID to the first
  netlink socket the process opens and assigns a unique nl_pid to every
  netlink socket that the process subsequently creates.
"

So to me this pid argument seems unnecessary.  Also, this change is =

side-effecting l_genl_new(int fd) method which you are removing.  While =

nobody is using it at the moment, removing it in this fashion is poor =

style (since l_genl_set_close_on_unref is mostly meant for this constructor)

Can we keep the present l_genl_new, l_genl_new_default constructors as =

they are, but still 'bolt-on' unicast handler functionality?

>
> -	if (unlikely(fd < 0))
> +	if (bind(fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
> +		close(fd);
>   		return NULL;
> +	}
>
>   	genl =3D l_new(struct l_genl, 1);
>
>   	genl->fd =3D fd;
> -	genl->close_on_unref =3D false;
>
>   	genl->nlctrl =3D family_alloc(genl, "nlctrl");
>
> @@ -525,32 +552,6 @@ LIB_EXPORT struct l_genl *l_genl_new(int fd)
>   	l_io_set_read_handler(genl->io, received_data, genl,
>   						read_watch_destroy);
>
> -	return l_genl_ref(genl);
> -}
> -
> -LIB_EXPORT struct l_genl *l_genl_new_default(void)
> -{
> -	struct l_genl *genl;
> -	struct sockaddr_nl addr;
> -	socklen_t addrlen =3D sizeof(addr);
> -	int fd, pktinfo =3D 1;
> -
> -	fd =3D socket(PF_NETLINK, SOCK_DGRAM | SOCK_CLOEXEC | SOCK_NONBLOCK,
> -							NETLINK_GENERIC);
> -	if (fd < 0)
> -		return NULL;
> -
> -	memset(&addr, 0, sizeof(addr));
> -	addr.nl_family =3D AF_NETLINK;
> -	addr.nl_pid =3D 0;
> -
> -	if (bind(fd, (struct sockaddr *) &addr, sizeof(addr)) < 0) {
> -		close(fd);
> -		return NULL;
> -	}
> -
> -	genl =3D l_genl_new(fd);
> -
>   	genl->close_on_unref =3D true;
>
>   	if (getsockname(fd, (struct sockaddr *) &addr, &addrlen) < 0) {
> @@ -566,7 +567,12 @@ LIB_EXPORT struct l_genl *l_genl_new_default(void)
>   		return NULL;
>   	}
>
> -	return genl;
> +	return l_genl_ref(genl);
> +}
> +
> +LIB_EXPORT struct l_genl *l_genl_new_default(void)
> +{
> +	return l_genl_new(0);
>   }
>
>   LIB_EXPORT struct l_genl *l_genl_ref(struct l_genl *genl)
> @@ -607,6 +613,8 @@ LIB_EXPORT void l_genl_unref(struct l_genl *genl)
>   	if (genl->debug_destroy)
>   		genl->debug_destroy(genl->debug_data);
>
> +	l_genl_unset_unicast_handler(genl);
> +
>   	l_free(genl);
>   }
>
> @@ -638,6 +646,52 @@ LIB_EXPORT bool l_genl_set_close_on_unref(struct l_g=
enl *genl, bool do_close)
>   	return true;
>   }
>
> +LIB_EXPORT bool l_genl_set_unicast_handler(struct l_genl *genl,
> +						l_genl_msg_func_t handler,
> +						void *user_data,
> +						l_genl_destroy_func_t destroy)
> +{
> +	struct genl_unicast_notify *notify;
> +
> +	if (!genl)
> +		return false;
> +
> +	notify =3D genl->unicast_notify;
> +	if (notify) {
> +		if (notify->destroy)
> +			notify->destroy(notify->user_data);
> +	} else {
> +		notify =3D l_new(struct genl_unicast_notify, 1);
> +		genl->unicast_notify =3D notify;
> +	}
> +
> +	notify->handler =3D handler;
> +	notify->destroy =3D destroy;
> +	notify->user_data =3D user_data;
> +
> +	return true;
> +}
> +
> +LIB_EXPORT bool l_genl_unset_unicast_handler(struct l_genl *genl)
> +{
> +	struct genl_unicast_notify *notify;
> +
> +	if (!genl)
> +		return false;
> +
> +	notify =3D genl->unicast_notify;
> +	if (!notify)
> +		return false;
> +
> +	if (notify->destroy)
> +		notify->destroy(notify->user_data);
> +
> +	l_free(notify);
> +	genl->unicast_notify =3D NULL;
> +
> +	return true;
> +}
> +
>   const void *_genl_msg_as_bytes(struct l_genl_msg *msg, uint16_t type,
>   					uint16_t flags, uint32_t seq,
>   					uint32_t pid,
> @@ -1265,7 +1319,7 @@ LIB_EXPORT unsigned int l_genl_family_register(stru=
ct l_genl_family *family,
>   						l_genl_destroy_func_t destroy)
>   {
>   	struct l_genl *genl;
> -	struct genl_notify *notify;
> +	struct genl_mcast_notify *notify;
>   	struct genl_mcast *mcast;
>
>   	if (unlikely(!family) || unlikely(!group))
> @@ -1280,7 +1334,7 @@ LIB_EXPORT unsigned int l_genl_family_register(stru=
ct l_genl_family *family,
>   	if (!mcast)
>   		return 0;
>
> -	notify =3D l_new(struct genl_notify, 1);
> +	notify =3D l_new(struct genl_mcast_notify, 1);
>
>   	notify->type =3D family->id;
>   	notify->group =3D mcast->id;
> @@ -1303,7 +1357,7 @@ LIB_EXPORT unsigned int l_genl_family_register(stru=
ct l_genl_family *family,
>
>   static bool match_notify_id(const void *a, const void *b)
>   {
> -	const struct genl_notify *notify =3D a;
> +	const struct genl_mcast_notify *notify =3D a;
>   	unsigned int id =3D L_PTR_TO_UINT(b);
>
>   	return notify->id =3D=3D id;
> @@ -1313,7 +1367,7 @@ LIB_EXPORT bool l_genl_family_unregister(struct l_g=
enl_family *family,
>   							unsigned int id)
>   {
>   	struct l_genl *genl;
> -	struct genl_notify *notify;
> +	struct genl_mcast_notify *notify;
>
>   	if (!family || !id)
>   		return false;
> diff --git a/ell/genl.h b/ell/genl.h
> index 8f5fd52..d3cb459 100644
> --- a/ell/genl.h
> +++ b/ell/genl.h
> @@ -25,17 +25,23 @@
>
>   #include <stdbool.h>
>   #include <stdint.h>
> +#include <unistd.h>
>
>   #ifdef __cplusplus
>   extern "C" {
>   #endif
>
> +struct l_genl_msg;
> +
> +typedef void (*l_genl_msg_func_t)(struct l_genl_msg *msg, void *user_dat=
a);
> +
>   typedef void (*l_genl_destroy_func_t)(void *user_data);
>
> +struct genl_unicast_notify;

Why is this forward-declared here?  Since it isn't prefixed by l_, I =

presume this is a mistake.

>
>   struct l_genl;
>
> -struct l_genl *l_genl_new(int fd);
> +struct l_genl *l_genl_new(pid_t unique_id);
>   struct l_genl *l_genl_new_default(void);
>
>   struct l_genl *l_genl_ref(struct l_genl *genl);
> @@ -48,9 +54,6 @@ bool l_genl_set_debug(struct l_genl *genl, l_genl_debug=
_func_t callback,
>
>   bool l_genl_set_close_on_unref(struct l_genl *genl, bool do_close);
>
> -
> -struct l_genl_msg;
> -
>   struct l_genl_attr {
>   	struct l_genl_msg *msg;
>   	const void *data;
> @@ -79,6 +82,12 @@ bool l_genl_attr_next(struct l_genl_attr *attr, uint16=
_t *type,
>   					uint16_t *len, const void **data);
>   bool l_genl_attr_recurse(struct l_genl_attr *attr, struct l_genl_attr *=
nested);
>
> +bool l_genl_set_unicast_handler(struct l_genl *genl,
> +						l_genl_msg_func_t handler,
> +						void *user_data,
> +						l_genl_destroy_func_t destroy);
> +
> +bool l_genl_unset_unicast_handler(struct l_genl *genl);

I rather we simply use l_genl_set_unicast_handler with NULL handler =

argument to accomplish this.

>
>   struct l_genl_family;
>
> @@ -94,8 +103,6 @@ bool l_genl_family_set_watches(struct l_genl_family *f=
amily,
>   				l_genl_watch_func_t vanished,
>   				void *user_data, l_genl_destroy_func_t destroy);
>
> -typedef void (*l_genl_msg_func_t)(struct l_genl_msg *msg, void *user_dat=
a);
> -
>   uint32_t l_genl_family_get_version(struct l_genl_family *family);
>
>   bool l_genl_family_can_send(struct l_genl_family *family, uint8_t cmd);
>

Regards,
-Denis

--===============8921938032477463613==--

