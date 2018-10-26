Content-Type: multipart/mixed; boundary="===============7709652926949143647=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] genl: rework l_genl_family to avoid extra lookups
Date: Fri, 26 Oct 2018 16:50:30 -0500
Message-ID: <ba4da532-d53f-d46a-3155-46adb3757dfc@gmail.com>
In-Reply-To: <20181024205214.8376-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7709652926949143647==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 10/24/2018 03:52 PM, James Prestwood wrote:
> Instead of looking up and re-allocating an entirely new l_genl_family
> with each call to l_genl_family_new, we can use a previous lookup that
> matches our family name.
> =

> A new internal structure was introduced, genl_parent, which holds all
> the lookup information for a given family name. Now, when
> l_genl_famil_new is called, we allocate a smaller child structure
> (l_genl_family) which holds a pointer back to the parent object in order
> to send and receive messages. This child structure only holds callback
> information and the (new) group ID (gid).

So while I kind of understand why you picked 'genl_parent', I really =

wonder if that naming is confusing.  Netlink Family is an actual term =

used by the Kernel.  E.g. NETLINK_ROUTE is a netlink 'family'.  Think =

socket families.  NETLINK_GENERIC (what l_genl is) is also a netlink =

family, and it itself has families (l_genl_family).

So perhaps we should stick with some internal naming for this.  E.g. =

just family or genl_family or __genl_family or genl_family_internal, etc.

> =

> Messages are now tagged with child group ID which allows for cancelling
> all requets on a given child object without affecting other children of
> the same parent. Cancelling all requets on a child object is as simple
> as destroying the l_genl_family object (l_genl_family_unref).
> ---
>   ell/genl.c | 369 +++++++++++++++++++++++++++++++++++------------------
>   1 file changed, 245 insertions(+), 124 deletions(-)
> =

> diff --git a/ell/genl.c b/ell/genl.c
> index 3a0281a..1dfdf1f 100644
> --- a/ell/genl.c
> +++ b/ell/genl.c
> @@ -63,8 +63,9 @@ struct l_genl {
>   	struct l_queue *notify_list;
>   	unsigned int next_request_id;
>   	unsigned int next_notify_id;
> +	unsigned int next_gid;
>   	struct l_queue *family_list;
> -	struct l_genl_family *nlctrl;
> +	struct genl_parent *nlctrl;
>   	struct genl_unicast_notify *unicast_notify;
>   	l_genl_debug_func_t debug_callback;
>   	l_genl_destroy_func_t debug_destroy;
> @@ -85,6 +86,7 @@ struct l_genl_msg {
>   =

>   struct genl_request {
>   	unsigned int id;
> +	unsigned int gid;
>   	uint16_t type;
>   	uint16_t flags;
>   	uint32_t seq;
> @@ -114,8 +116,7 @@ struct genl_mcast {
>   	unsigned int users;
>   };
>   =

> -struct l_genl_family {
> -	int ref_count;
> +struct genl_parent {
>   	struct l_genl *genl;
>   	char name[GENL_NAMSIZ];
>   	uint16_t id;
> @@ -124,11 +125,19 @@ struct l_genl_family {
>   	uint32_t maxattr;
>   	struct l_queue *op_list;
>   	struct l_queue *mcast_list;
> +	unsigned int nlctrl_cmd;
> +	struct l_queue *children;

So I wonder why you need this?

> +	bool live;
> +};
> +
> +struct l_genl_family {
> +	struct genl_parent *parent;
> +	int ref_count;
> +	unsigned int gid;
>   	l_genl_watch_func_t watch_appeared;
>   	l_genl_watch_func_t watch_vanished;
>   	l_genl_destroy_func_t watch_destroy;
>   	void *watch_data;

I wonder if these should just be kept on the parent object ?  Perhaps we =

should move watchlist from iwd to ell?

> -	unsigned int nlctrl_cmd;
>   };
>   =

>   static void destroy_request(void *data)
> @@ -153,20 +162,31 @@ static void destroy_notify(void *data)
>   	l_free(notify);
>   }
>   =

> -static struct l_genl_family *family_alloc(struct l_genl *genl,
> -							const char *name)
> +static struct l_genl_family *family_alloc_child(struct genl_parent *pare=
nt)
>   {
> -	struct l_genl_family *family;
> +	struct l_genl_family *family =3D l_new(struct l_genl_family, 1);
>   =

> -	family =3D l_new(struct l_genl_family, 1);
> +	family->parent =3D parent;
> +	family->gid =3D parent->genl->next_gid++;
>   =

> -	family->genl =3D genl;
> -	strncpy(family->name, name, GENL_NAMSIZ);
> +	l_queue_push_tail(parent->children, family);
>   =

> -	family->op_list =3D l_queue_new();
> -	family->mcast_list =3D l_queue_new();
> +	return family;
> +}
>   =

> -	return l_genl_family_ref(family);
> +static struct genl_parent *family_alloc_parent(struct l_genl *genl,
> +							const char *name)
> +{
> +	struct genl_parent *parent =3D l_new(struct genl_parent, 1);
> +
> +	parent->genl =3D genl;
> +	strncpy(parent->name, name, GENL_NAMSIZ);
> +
> +	parent->op_list =3D l_queue_new();
> +	parent->mcast_list =3D l_queue_new();
> +	parent->children =3D l_queue_new();
> +
> +	return parent;
>   }
>   =

>   static void op_free(void *data)
> @@ -191,16 +211,63 @@ static void mcast_free(void *data, void *user_data)
>   	l_free(mcast);
>   }
>   =

> -static void family_free(void *data)
> +static bool request_match_gid(const void *a, const void *b)
>   {
> -	struct l_genl_family *family =3D data;
> +	const struct genl_request *request =3D a;
> +	unsigned int gid =3D L_PTR_TO_UINT(b);
> +
> +	if (request->gid =3D=3D gid)
> +		return true;
> +
> +	return false;
> +}
> +
> +static void cancel_all_requests(struct l_genl_family *child)
> +{
> +	struct l_genl *genl =3D child->parent->genl;
> +	struct genl_request *request;
> +
> +	/* genl has already been cleaned up */
> +	if (!genl->request_queue)
> +		return;
> +
> +	while ((request =3D l_queue_find(genl->request_queue, request_match_gid,
> +					L_UINT_TO_PTR(child->gid))))
> +		l_genl_family_cancel(child, request->id);

This seems like an N^2 operation.  Can't we use l_queue_remove_all or =

something?

> +}
> +
> +static void child_free(void *data)
> +{
> +	struct l_genl_family *child =3D data;
> +
> +	cancel_all_requests(child);
> +
> +	if (child->parent->id > 0 && child->watch_vanished)
> +		child->watch_vanished(child->watch_data);
> +
> +	if (child->watch_destroy)
> +		child->watch_destroy(child->watch_data);
> +

Okay, now I understand why you need the list of children.  So when you =

destroy the parent, you forcefully destroy all the children.  Yikes :)

Personally I think this was always a weird area.  The whole =

watch_vanished and watch_appeared stuff was badly implemented I think. =

family_appeared is really 'family was queried successfully and it =

exists' callback.  And 'family_vanished' was meant as 'this family =

really doesn't exist'.

The other issue is that l_genl_family_ref/unref had weird semantics.  We =

have a weird situation where family_free uses l_genl_family_unref.  But =

if someone actually took a ref of l_genl_family and the underlying genl =

object gets destroyed, the family is still around.  But can't send =

anything...

So now you're going from one extreme to the other, where every user of =

l_genl_family has to set a watch to make sure that the object isn't =

destroyed from under them.  And there's not much they can do about it. =

Not sure this is better or useful?

Perhaps we should have each parent take a ref of genl?

Then we can simplify the whole l_genl_family_new to two functions:

void l_genl_get_family_async(genl, name, callback, user, destroy);

Where family_vanished / family_appeared / set_watches is replaced by the =

callback.

And maybe a shorthand for when we know the family exists / was already =

queried:
struct l_genl_family *l_genl_get_family(genl, name);

And I would simply drop l_genl_family_ref/unref as they make no sense now.

> +
> +	l_free(child);
> +}
> +
> +static void parent_free(void *data)
> +{
> +	struct genl_parent *parent =3D data;
> +
> +	l_queue_destroy(parent->children, child_free);
> +
> +	l_queue_destroy(parent->op_list, op_free);
>   =

> -	family->genl =3D NULL;
> +	l_queue_foreach(parent->mcast_list, mcast_free, parent->genl);
> +	l_queue_destroy(parent->mcast_list, NULL);
> +	parent->mcast_list =3D NULL;
>   =

> -	l_genl_family_unref(family);
> +	l_free(parent);

Can we just keep the 'parent' object always around once queried?

Or alternatively, why don't we destroy it when all instances of =

l_genl_family with this parent have been destroyed.  E.g. have each =

l_genl_family take a ref of 'parent'.

>   }
>   =

> -static void family_add_op(struct l_genl_family *family, uint32_t id,
> +static void family_add_op(struct genl_parent *parent, uint32_t id,
>   							uint32_t flags)
>   {
>   	struct genl_op *op;

Regards,
-Denis

--===============7709652926949143647==--

