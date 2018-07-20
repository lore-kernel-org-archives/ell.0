Content-Type: multipart/mixed; boundary="===============0520904318992781902=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] fswatch: Add fswatch API
Date: Fri, 20 Jul 2018 10:55:33 -0500
Message-ID: <d2278849-46f8-d01a-43af-6d0fb30f54df@gmail.com>
In-Reply-To: <20180720011519.10210-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0520904318992781902==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

> +static bool inotify_read_cb(struct l_io *io, void *user_data)
> +{
> +	uint8_t buf[sizeof(struct inotify_event) + NAME_MAX + 1];
> +	const struct inotify_event *event;
> +	ssize_t len;
> +	enum l_fswatch_event event_type;
> +
> +	len =3D read(l_io_get_fd(io), buf, sizeof(buf));

This might need a TEMP_FAILURE_RETRY()

> +	if (unlikely(len <=3D 0))
> +		return true;
> +
> +	event =3D (struct inotify_event *) buf;
> +
> +	if (event->mask & IN_CREATE)
> +		event_type =3D L_FSWATCH_EVENT_CREATE;
> +	else if (event->mask & (IN_DELETE | IN_DELETE_SELF))
> +		event_type =3D L_FSWATCH_EVENT_DELETE;
> +	else if (event->mask & (IN_MOVE | IN_MOVE_SELF))
> +		event_type =3D L_FSWATCH_EVENT_MOVE;
> +	else
> +		event_type =3D L_FSWATCH_EVENT_MODIFY;

Why is this outside the while loop below?  It sounds like there may be =

multiple inotify events during a single read and each one would have a =

different mask, no?

In fact, this might be better written as a for loop, similar to how the =

manpage does it.

> +
> +	in_notify =3D true;
> +
> +	while ((size_t) len >=3D sizeof(struct inotify_event) + event->len) {
> +		const struct l_queue_entry *entry;
> +		const uint8_t *next_ptr;
> +		const char *name =3D NULL;
> +
> +		if (event->len)
> +			name =3D event->name;
> +
> +		for (entry =3D l_queue_get_entries(watches); entry;
> +				entry =3D entry->next) {
> +			struct l_fswatch *watch =3D entry->data;
> +
> +			if (watch->id !=3D event->wd)
> +				continue;
> +
> +			if ((event->mask & EVENT_MASK) && watch->cb)
> +				watch->cb(watch, name, event_type,
> +						watch->user_data);
> +
> +			if (event->mask & IN_IGNORED) {
> +				stale_items =3D true;
> +				watch->cb =3D NULL;
> +			}
> +		}
> +
> +		len -=3D sizeof(struct inotify_event) + event->len;
> +		/* event->len is supposed to include alignment */
> +		next_ptr =3D (const uint8_t *) (event + 1) + event->len;
> +		event =3D (struct inotify_event *) next_ptr;
> +	}
> +
> +	in_notify =3D false;
> +
> +	if (stale_items) {
> +		struct l_fswatch *watch;
> +
> +		while ((watch =3D l_queue_remove_if(watches,
> +						l_fswatch_remove_func, NULL)))
> +			l_fswatch_free(watch);
> +
> +		stale_items =3D false;
> +
> +		if (l_queue_isempty(watches))
> +			l_fswatch_shutdown();
> +	}
> +
> +	return true;
> +}
> +

<snip>

> +
> +LIB_EXPORT bool l_fswatch_destroy(struct l_fswatch *watch)

I still don't see why this returns bool, what can the caller do if the =

call fails?

> +{
> +	const struct l_queue_entry *entry;
> +	int id;
> +
> +	if (unlikely(!inotify_io || !watch))
> +		return false;

This can just as easily be void

> +
> +	id =3D watch->id;
> +
> +	/* Check if we have any other watch with the same inotify ID */
> +	for (entry =3D l_queue_get_entries(watches); entry;
> +			entry =3D entry->next) {
> +		struct l_fswatch *watch2 =3D entry->data;
> +
> +		if (watch2 !=3D watch && watch2->id =3D=3D id)
> +			break;
> +	}
> +
> +	if (!entry && id !=3D -1)
> +		if (inotify_rm_watch(l_io_get_fd(inotify_io), id) < 0)
> +			return false;

So how do we delete the struct l_fswatch *watch memory here?

> +
> +	if (in_notify) {
> +		watch->cb =3D NULL;
> +		stale_items =3D true;
> +		return true;
> +	}
> +
> +	l_queue_remove(watches, watch);
> +	l_fswatch_free(watch);
> +
> +	if (l_queue_isempty(watches))
> +		l_fswatch_shutdown();
> +
> +	return true;
> +}

<snip>

> +typedef void (*l_fswatch_destroy_cb_t) (struct l_fswatch *watch,
> +					void *user_data);

Why would this destroy callback signature be different from all others? =

It also precludes us from doing something like:

l_fswatch_new("/foo/bar", cb, u, (l_fswatch_destroy_cb_t) l_free);

Regards,
-Denis

--===============0520904318992781902==--

