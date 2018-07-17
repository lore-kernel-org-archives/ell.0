Content-Type: multipart/mixed; boundary="===============6362228373112542237=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/2] fswatch: Add fswatch API
Date: Wed, 18 Jul 2018 01:15:15 +0200
Message-ID: <CAOq732KqNOvOS1Mz8ECL_jHSP3vp0d9GvtLHqtVArLWBk1Eoug@mail.gmail.com>
In-Reply-To: <d1af5b77-a792-0d26-0571-9a9c61c7c56e@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6362228373112542237==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 17 July 2018 at 21:33, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
> <snip>
>
>> +static struct l_io *inotify_io;
>> +static struct l_queue *watches;
>> +static bool in_notify;
>> +static bool stale_items;
>> +
>> +struct l_fswatch {
>> +       char *path;
>
>
> Why do we store the path?  It isn't used anywhere.

True, I was thinking about having an accessor similar to l_io_get_fd
but we would first need to figure out how to update the path on the
IN_MOVE_SELF event.

>
>> +       int id;
>> +       l_fswatch_cb_t cb;
>> +       void *user_data;
>> +};
>> +
>> +#define EVENT_MASK     (IN_CREATE | IN_DELETE | IN_DELETE_SELF | \
>> +                               IN_MODIFY | IN_MOVE | IN_MOVE_SELF)
>
>
> Should we expose some of this info?  Wouldn't it be useful to know what
> exactly changed for a given path?

It might be useful, I can add an enum with values such as
L_FSWATCH_EVENT_CREATE / MOVE / MODIFY / DELETE.

However relying on this info is seemingly discouraged by inotify(7)
because there's no race-free way to use it.  For our iwd use case we
probably want to always reload the affected files and having this
information isn't of any help.

>
>> +
>> +typedef void (*l_fswatch_cb_t) (struct l_fswatch *watch, const char
>> *filename,
>> +                               void *user_data);
>> +
>> +static void l_fswatch_destroy(void *data)
>> +{
>> +       struct l_fswatch *watch =3D data;
>> +
>> +       l_free(watch->path);
>> +       l_free(watch);
>> +}
>> +
>> +static void l_fswatch_shutdown(void)
>> +{
>> +       if (!inotify_io)
>> +               return;
>> +
>> +       l_io_destroy(inotify_io);
>> +       inotify_io =3D NULL;
>> +
>> +       l_queue_destroy(watches, l_fswatch_destroy);
>> +       watches =3D NULL;
>
>
> Every time this function is called the watches queue is empty.  It might =
be
> better to just hang the watches queue off of the inotify_io and provide a
> proper destroy callback.

We will still need a global variable for the queue because we need to
access it when adding or removing watches.

> That was the queue will be destroyed whenever the
> inotify_io is destroyed.  This probably also buys you auto-destruct at ex=
it
> as well.

Ok, yep, it makes sense to move this part to the inotify_io's read
destroy callback.

>
>
>> +}
>> +
>> +static bool l_fswatch_remove_func(void *data, void *user_data)
>> +{
>> +       struct l_fswatch *watch =3D data;
>> +
>> +       if (watch->cb)
>> +               return false;
>> +
>> +       l_fswatch_destroy(watch);
>> +
>> +       return true;
>> +}
>> +
>> +static bool inotify_read_cb(struct l_io *io, void *user_data)
>> +{
>> +       uint8_t buf[sizeof(struct inotify_event) + NAME_MAX + 1];
>> +       const struct inotify_event *event;
>> +       ssize_t len;
>> +
>> +       len =3D read(l_io_get_fd(io), buf, sizeof(buf));
>> +       if (unlikely(len <=3D 0))
>> +               return true;
>> +
>> +       event =3D (struct inotify_event *) buf;
>> +       in_notify =3D true;
>> +
>> +       while ((size_t) len >=3D sizeof(struct inotify_event) + event->l=
en)
>> {
>> +               const struct l_queue_entry *entry;
>> +               const uint8_t *next_ptr;
>> +               const char *name =3D NULL;
>> +
>> +               if (event->len)
>> +                       name =3D event->name;
>> +
>> +               for (entry =3D l_queue_get_entries(watches); entry;
>> +                               entry =3D entry->next) {
>> +                       struct l_fswatch *watch =3D entry->data;
>> +
>> +                       if (watch->id !=3D event->wd)
>> +                               continue;
>> +
>> +                       if (event->mask & IN_IGNORED)
>> +                               watch->id =3D -1; > +
>> +                       if ((event->mask & EVENT_MASK) && watch->cb)
>> +                               watch->cb(watch, name, watch->user_data);
>
>
> This implies that watch->cb can be NULL?  See discussion below
>
>> +               }
>> +
>> +               len -=3D sizeof(struct inotify_event) + event->len;
>> +               /* event->len is supposed to include alignment */
>> +               next_ptr =3D (const uint8_t *) (event + 1) + event->len;
>> +               event =3D (struct inotify_event *) next_ptr;
>> +       }
>> +
>> +       in_notify =3D false;
>> +
>> +       if (stale_items) {
>> +               l_queue_foreach_remove(watches, l_fswatch_remove_func,
>> NULL);
>> +               stale_items =3D false;
>> +
>> +               if (l_queue_isempty(watches))
>> +                       l_fswatch_shutdown();
>> +       }
>> +
>> +       return true;
>> +}
>> +
>> +LIB_EXPORT struct l_fswatch *l_fswatch_new(const char *path,
>> l_fswatch_cb_t cb,
>> +                                               void *user_data)
>
>
> We really need a destroy callback here as well

Ok, then I guess I can actually free the watches for which the kernel
sends us IN_IGNORED events and call the destroy callbacks, rather than
just set watch->id to -1.

>
>> +{
>> +       struct l_fswatch *watch;
>> +       int id;
>> +
>> +       if (!inotify_io) {
>> +               int inotify_fd =3D inotify_init1(IN_CLOEXEC);
>> +
>> +               if (unlikely(inotify_fd < 0))
>> +                       return NULL;
>> +
>> +               inotify_io =3D l_io_new(inotify_fd);
>> +               if (unlikely(!inotify_io)) {
>> +                       close(inotify_fd);
>> +                       return NULL;
>> +               }
>> +
>> +               l_io_set_close_on_destroy(inotify_io, true);
>> +
>> +               if (unlikely(!l_io_set_read_handler(inotify_io,
>> inotify_read_cb,
>> +                                                       NULL, NULL))) {
>> +                       l_io_destroy(inotify_io);
>> +                       return NULL;
>> +               }
>
>
> Can we split this out into a separate function?  Most of these
> lazy-initialization details are irrelevant to l_fswatch_new, and if we ev=
er
> move to a non-lazy initialization implementation, the changes will be
> compartmentalized better.

Ok.

>
>
>> +       }
>> +
>> +       /*
>> +        * inotify_watch_add already checks if the path is already being
>> +        * watched and will return the old watch ID so we're fine.
>> +        */
>> +       id =3D inotify_add_watch(l_io_get_fd(inotify_io), path,
>> +                                               EVENT_MASK |
>> IN_EXCL_UNLINK);
>> +       if (unlikely(id < 0)) {
>> +               if (l_queue_isempty(watches))
>> +                       l_fswatch_shutdown();
>> +
>> +               return NULL;
>> +       }
>> +
>> +       watch =3D l_new(struct l_fswatch, 1);
>> +       watch->path =3D l_strdup(path);
>> +       watch->id =3D id;
>> +       watch->cb =3D cb;
>> +       watch->user_data =3D user_data;
>> +
>> +       if (!watches)
>> +               watches =3D l_queue_new();
>> +
>> +       l_queue_push_tail(watches, watch);
>> +
>> +       return watch;
>> +}
>> +
>> +LIB_EXPORT bool l_fswatch_remove(struct l_fswatch *watch)
>
>
> Not sure why half of our APIs use _remove and the other half uses _destro=
y.
> But why would this return a bool?  That seems wrong, it should be void.

It's simliar to l_queue_remove and it may fail (in this case also
because of IO) although it's different from l_queue_remove in that it
also frees the object so I can rename it to _destroy.

>
>
>> +{
>> +       const struct l_queue_entry *entry;
>> +       int id;
>> +
>> +       if (unlikely(!inotify_io || !watch))
>> +               return false;
>> +
>> +       id =3D watch->id;
>> +
>> +       /* Check if we have any other watch with the same inotify ID */
>> +       for (entry =3D l_queue_get_entries(watches); entry;
>> +                       entry =3D entry->next) {
>> +               struct l_fswatch *watch2 =3D entry->data;
>> +
>> +               if (watch2 !=3D watch && watch2->id =3D=3D id)
>> +                       break;
>> +       }
>> +
>> +       if (!entry && id !=3D -1)
>> +               if (inotify_rm_watch(l_io_get_fd(inotify_io), id) < 0)
>> +                       return false;
>> +
>> +       if (in_notify) {
>> +               watch->cb =3D NULL;
>> +               stale_items =3D false;
>
>
> should this be true actually?

Oops, yes it should.

I was actually testing this code path in the unit test but changed the
test before running it through valgrind.

> Also, you're not checking that cb is non-null
> in l_fswatch_new.  So we should either introduce a different guard variab=
le
> or ensure that cb isn't NULL at first.

Ok.

Best regards

--===============6362228373112542237==--

