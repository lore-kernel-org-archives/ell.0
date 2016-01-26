Content-Type: multipart/mixed; boundary="===============7225307533967915964=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [RFC PATCH 2/8] dbus: Separate interface registration from
 instantiation
Date: Wed, 27 Jan 2016 00:40:10 +0100
Message-ID: <CAOq732JZau7d9XN9OqGxjeN7GdRdZTWta8Mq502qPqN7UY0xDA@mail.gmail.com>
In-Reply-To: <56A7E196.70501@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7225307533967915964==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

  w
 cuHi Denis,

On 26 January 2016 at 22:13, Denis Kenzior <denkenz@gmail.com> wrote:
> On 01/22/2016 08:59 PM, Andrew Zaborowski wrote:
>> One thing that may be unclear is that as a side effect
>> _dbus_object_tree_prune_node takes not only the reference to the node
>> being pruned but also to the object tree and a path to the object.  The
>> latter two are needed because when the function is walking the tree
>> upwards to free any intermediate nodes that no longer have any
>> dbus-visible objects in their subtree, the function needs to be able to
>> check if these nodes are visible on dbus (i.e. are in tree->objects).  I
>> found that currently if you've got a tree with objects /a and /a/b in
>> it, and remove all interfaces from /a first, then from /a/b, the
>> _dbus_object_tree_prune_node call will free /a without removing it from
>> tree->objects.  The node reference parameter is no longer needed except
>> for the unit/test-dbus-service to be able to test adding and removing
>> intermediate nodes from the tree.
>
>
> If we register object on '/a', then register object on '/a/b'.  We have t=
wo
> objects in the tree->objects hashmap.  If we unregister object '/a' first,
> then tree->objects will no longer contain '/a'.

_dbus_object_tree_unregister currently does:

    if (l_queue_isempty(node->instances) && !node->children) {
       l_hashmap_remove(tree->objects, path);
       _dbus_object_tree_prune_node(node);
    }

So since /a's node->chlidren is not empty,
l_hashmap_remove(tree->objects, path); will not happen.  Both /a and
/a/b will remain in the hashmap.

> Then unregistering '/a/b'
> will prune the tree upwards.

Right, at that point /a will be removed from the tree but not from
tree->objects.

On a second thought, I think the current code can be fixed by doing two thi=
ngs:

    if (l_queue_isempty(node->instances)) {
       l_hashmap_remove(tree->objects, path);
       if (!node->children)
           _dbus_object_tree_prune_node(node);
    }

...and adding a check in _dbus_object_tree_prune_node to make sure we
don't remove nodes that still have nonempty node->instances.

>
> Tree pruning is intended to be fully separate from the object hash, so I'm
> really not following.
>
> Perhaps you're conflating unregistering all interfaces vs unregistering t=
he
> object?  But then you mention that your semantics of not removing the obj=
ect
> from the tree if all interfaces are removed is intentional in the next
> paragraph.
>
>
>>
>> Note that while the client doesn't need to call l_dbus_register_object,
>> they still need to call l_dbus_unregister_object to free the object
>> because it's not freed automatically when the last interface gets
>> removed.  But they can skip the l_dbus_remove_interface calls
>> because the interfaces will be removed either way.
>> ---
>>   ell/dbus-private.h       |  20 ++++-
>>   ell/dbus-service.c       | 224
>> +++++++++++++++++++++++++++++++++++------------
>>   ell/dbus.c               |  91 +++++++++++++++++--
>>   ell/dbus.h               |  19 ++--
>>   examples/dbus-service.c  |  13 ++-
>>   unit/test-dbus-service.c |  17 ++--
>>   unit/test-kdbus.c        |   9 +-
>>   7 files changed, 311 insertions(+), 82 deletions(-)
>>
>> diff --git a/ell/dbus-private.h b/ell/dbus-private.h
>> index e60d09e..fc26aa2 100644
>> --- a/ell/dbus-private.h
>> +++ b/ell/dbus-private.h
>> @@ -167,13 +167,27 @@ struct object_node
>> *_dbus_object_tree_makepath(struct _dbus_object_tree *tree,
>>                                                 const char *path);
>>   struct object_node *_dbus_object_tree_lookup(struct _dbus_object_tree
>> *tree,
>>                                                 const char *path);
>> -void _dbus_object_tree_prune_node(struct object_node *node);
>> +
>> +struct object_node *_dbus_object_tree_new_object(struct _dbus_object_tr=
ee
>> *tree,
>> +                                               const char *path,
>> +                                               void *user_data,
>> +                                               void (*destroy) (void *)=
);
>> +bool _dbus_object_tree_prune_node(struct _dbus_object_tree *tree,
>> +                                       struct object_node *node,
>> +                                       const char *path);
>>
>>   bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
>> -                               const char *path, const char *interface,
>> +                               const char *interface,
>>                                 void (*setup_func)(struct l_dbus_interfa=
ce
>> *),
>> -                               void *user_data, void (*destroy) (void
>> *));
>> +                               void (*destroy) (void *),
>> +                               bool old_style_properties);
>
>
> Should this be called _dbus_object_tree_register_interface now?  Since it
> only deals with interfaces and not object paths?

Yes, let me rename it.

>
>>   bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
>> +                               const char *interface);
>> +
>
>
> Similarly, should this be _dbus_object_tree_unregister_interface?

Yes.

>
>
>> +bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
>> +                                       const char *path, const char
>> *interface,
>> +                                       void *user_data);
>> +bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
>>                                         const char *path,
>>                                         const char *interface);
>>
>> diff --git a/ell/dbus-service.c b/ell/dbus-service.c
>> index 77310c6..d37989e 100644
>> --- a/ell/dbus-service.c
>> +++ b/ell/dbus-service.c
>> @@ -72,6 +72,9 @@ struct l_dbus_interface {
>>         struct l_queue *methods;
>>         struct l_queue *signals;
>>         struct l_queue *properties;
>> +       bool handle_old_style_properties;
>> +       void (*setup_func)(struct l_dbus_interface *);
>> +       void (*instance_destroy)(void *);
>>         char name[];
>>   };
>>
>> @@ -84,13 +87,14 @@ struct child_node {
>>   struct interface_instance {
>>         struct l_dbus_interface *interface;
>>         void *user_data;
>> -       void (*user_destroy) (void *);
>>   };
>>
>>   struct object_node {
>>         struct object_node *parent;
>>         struct l_queue *instances;
>>         struct child_node *children;
>> +       void *user_data;
>> +       void (*destroy) (void *);
>>   };
>>
>>   struct _dbus_object_tree {
>> @@ -489,8 +493,8 @@ struct _dbus_property
>> *_dbus_interface_find_property(struct l_dbus_interface *i,
>>
>>   static void interface_instance_free(struct interface_instance *instanc=
e)
>>   {
>> -       if (instance->user_destroy)
>> -               instance->user_destroy(instance->user_data);
>> +       if (instance->interface->instance_destroy)
>> +
>> instance->interface->instance_destroy(instance->user_data);
>>
>>         l_free(instance);
>>   }
>> @@ -539,6 +543,9 @@ static void subtree_free(struct object_node *node)
>>         l_queue_destroy(node->instances,
>>                         (l_queue_destroy_func_t) interface_instance_free=
);
>>
>> +       if (node->destroy)
>> +               node->destroy(node->user_data);
>> +
>>         l_free(node);
>>   }
>>
>> @@ -626,81 +633,197 @@ struct object_node *_dbus_object_tree_lookup(stru=
ct
>> _dbus_object_tree *tree,
>>         return lookup_recurse(tree->root, path);
>>   }
>>
>> -void _dbus_object_tree_prune_node(struct object_node *node)
>> +struct object_node *_dbus_object_tree_new_object(struct _dbus_object_tr=
ee
>> *tree,
>> +                                               const char *path,
>> +                                               void *user_data,
>> +                                               void (*destroy) (void *))
>> +{
>> +       struct object_node *node;
>> +
>> +       if (!_dbus_valid_object_path(path))
>> +               return NULL;
>> +
>> +       if (l_hashmap_lookup(tree->objects, path))
>> +               return NULL;
>> +
>> +       node =3D _dbus_object_tree_makepath(tree, path);
>> +       node->user_data =3D user_data;
>> +       node->destroy =3D destroy;
>> +
>> +       l_hashmap_insert(tree->objects, path, node);
>> +
>> +       return node;
>> +}
>> +
>> +bool _dbus_object_tree_prune_node(struct _dbus_object_tree *tree,
>> +                                       struct object_node *node,
>> +                                       const char *path)
>
>
> This part sounds like it really belongs in a separate patch...

Do you mean both of _dbus_object_tree_new_object and
_dbus_object_tree_prune_node?
>
>
>>   {
>> -       struct object_node *parent =3D node->parent;
>> -       struct child_node *p =3D NULL, *c;
>> +       struct object_node *parent;
>> +       struct child_node *p, *c;
>> +       struct interface_instance *instance;
>> +       char parentpath[strlen(path) + 1];
>> +
>> +       if (!node) {
>> +               node =3D l_hashmap_remove(tree->objects, path);
>> +               if (!node)
>> +                       return false;
>> +       }
>> +
>> +       while ((instance =3D l_queue_pop_head(node->instances)))
>> +               interface_instance_free(instance);
>> +
>> +       if (node->destroy) {
>> +               node->destroy(node->user_data);
>>
>> -       while (parent) {
>> -               for (c =3D parent->children, p =3D NULL; c; p =3D c, c =
=3D
>> c->next) {
>> -                       if (c->node !=3D node)
>> -                               continue;
>> +               node->destroy =3D NULL;
>> +       }
>>
>> -                       if (p)
>> -                               p->next =3D c->next;
>> -                       else
>> -                               parent->children =3D c->next;
>> +       if (node->children || !node->parent)
>> +               return true;
>>
>> -                       subtree_free(c->node);
>> -                       l_free(c);
>> +       /*
>> +        * Walk up the tree until a node that either has more than one
>> +        * child, is the root or is in the objects hashmap.
>> +        */
>> +       strcpy(parentpath, path);
>>
>> +       while (true) {
>> +               parent =3D node->parent;
>> +
>> +               if (parent =3D=3D tree->root)
>> +                       break;
>> +
>> +               if (parent->children->next)
>>                         break;
>> -               }
>>
>> -               if (parent->children !=3D NULL)
>> -                       return;
>> +               /* Parent's path */
>> +               parentpath[strlen(parentpath) -
>> +                       strlen(parent->children->subpath) - 1] =3D '\0';
>> +
>> +               if (l_hashmap_lookup(tree->objects, parentpath))
>> +                       break;
>>
>>                 node =3D parent;
>> -               parent =3D node->parent;
>>         }
>> +
>> +       for (c =3D parent->children, p =3D NULL; c; p =3D c, c =3D c->ne=
xt)
>> +               if (c->node =3D=3D node)
>> +                       break;
>> +
>> +       if (p)
>> +               p->next =3D c->next;
>> +       else
>> +               parent->children =3D c->next;
>> +
>> +       l_free(c);
>> +       subtree_free(node);
>> +
>> +       return true;
>>   }
>>
>>   bool _dbus_object_tree_register(struct _dbus_object_tree *tree,
>> -                               const char *path, const char *interface,
>> +                               const char *interface,
>>                                 void (*setup_func)(struct l_dbus_interfa=
ce
>> *),
>> -                               void *user_data, void (*destroy) (void *=
))
>> +                               void (*destroy) (void *),
>> +                               bool old_style_properties)
>>   {
>> -       struct object_node *object;
>>         struct l_dbus_interface *dbi;
>> -       const struct l_queue_entry *entry;
>> -       struct interface_instance *instance;
>>
>>         if (!_dbus_valid_interface(interface))
>>                 return false;
>>
>> -       if (!_dbus_valid_object_path(path))
>> +       /*
>> +        * Check to make sure we do not have this interface already
>> +        * registered
>> +        */
>> +       dbi =3D l_hashmap_lookup(tree->interfaces, interface);
>> +       if (dbi)
>> +               return false;
>> +
>> +       dbi =3D _dbus_interface_new(interface);
>> +       dbi->instance_destroy =3D destroy;
>> +       dbi->setup_func =3D setup_func;
>
>
> Can't we just call this right away and not wait for first use?  Let the
> programmer decide when to instantiate the interface.

Ok.

>
>
>> +       dbi->handle_old_style_properties =3D old_style_properties;
>> +
>> +       l_hashmap_insert(tree->interfaces, dbi->name, dbi);
>> +
>> +       return true;
>> +}
>> +
>> +struct interface_check {
>> +       const char *interface;
>> +       bool result;
>> +};
>> +
>> +static void check_interface_used(const void *key, void *value, void
>> *user_data)
>> +{
>> +       struct object_node *node =3D value;
>> +       struct interface_check *state =3D user_data;
>> +
>> +       if (l_queue_find(node->instances, match_interface_instance,
>> +                               (char *) state->interface))
>> +               state->result =3D true;
>> +}
>> +
>> +bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
>> +                                       const char *interface_name)
>> +{
>> +       struct l_dbus_interface *interface;
>> +       struct interface_check state =3D { interface_name, false };
>> +
>> +       interface =3D l_hashmap_lookup(tree->interfaces, interface_name);
>> +       if (!interface)
>> +               return false;
>> +
>> +       /* Check that the interface is not in use */
>> +       l_hashmap_foreach(tree->objects, check_interface_used, &state);
>> +       if (state.result)
>> +               return false;
>
>
> I'm not sure this is useful in its current form.  If we want to have this,
> then we probably need to distinguish between telling the programmer that
> "you're trying to unregister an unknown interface" vs "you're trying to
> unregister a interface that is still being used".  As an alternative, you
> can keep a reference count on the interface itself and keep the object
> around until all instances have been destroyed, and this function would
> always succeed...
>
> However, I would keep it simple and just let the programmer control this.
> If they try to remove an interface that is still being used, things will
> crash spectacularly and valgrind/gdb will find it very fast.  Remember our
> motto, "crash early, crash often" :)

Yes, good point.  Or we can remove the interface and remove all of its
instances which is in a way logical.
>
>
>> +
>> +       l_hashmap_remove(tree->interfaces, interface_name);
>> +
>> +       _dbus_interface_free(interface);
>> +
>> +       return true;
>> +}
>> +
>> +bool _dbus_object_tree_add_interface(struct _dbus_object_tree *tree,
>> +                                       const char *path, const char
>> *interface,
>> +                                       void *user_data)
>> +{
>> +       struct object_node *object;
>> +       struct l_dbus_interface *dbi;
>> +       struct interface_instance *instance;
>> +
>> +       dbi =3D l_hashmap_lookup(tree->interfaces, interface);
>> +       if (!dbi)
>>                 return false;
>>
>>         object =3D l_hashmap_lookup(tree->objects, path);
>>         if (!object) {
>> -               object =3D _dbus_object_tree_makepath(tree, path);
>> -               l_hashmap_insert(tree->objects, path, object);
>> +               object =3D _dbus_object_tree_new_object(tree, path, NULL,
>> NULL);
>> +
>> +               if (!object)
>> +                       return false;
>>         }
>>
>>         /*
>>          * Check to make sure we do not have this interface already
>>          * registered for this object
>>          */
>> -       entry =3D l_queue_get_entries(object->instances);
>> -       while (entry) {
>> -               instance =3D entry->data;
>> -
>> -               if (!strcmp(instance->interface->name, interface))
>> -                       return false;
>> +       if (l_queue_find(object->instances, match_interface_instance,
>> +                               (char *) interface))
>> +               return false;
>>
>> -               entry =3D entry->next;
>> -       }
>> +       if (dbi->setup_func) {
>> +               dbi->setup_func(dbi);
>>
>
> See my comments above...
>
>
>> -       dbi =3D l_hashmap_lookup(tree->interfaces, interface);
>> -       if (!dbi) {
>> -               dbi =3D _dbus_interface_new(interface);
>> -               setup_func(dbi);
>> -               l_hashmap_insert(tree->interfaces, dbi->name, dbi);
>> +               dbi->setup_func =3D NULL;
>>         }
>>
>>         instance =3D l_new(struct interface_instance, 1);
>>         instance->interface =3D dbi;
>> -       instance->user_destroy =3D destroy;
>>         instance->user_data =3D user_data;
>>
>>         if (!object->instances)
>> @@ -711,13 +834,12 @@ bool _dbus_object_tree_register(struct
>> _dbus_object_tree *tree,
>>         return true;
>>   }
>>
>> -bool _dbus_object_tree_unregister(struct _dbus_object_tree *tree,
>> +bool _dbus_object_tree_remove_interface(struct _dbus_object_tree *tree,
>>                                         const char *path,
>>                                         const char *interface)
>>   {
>>         struct object_node *node;
>>         struct interface_instance *instance;
>> -       bool r;
>>
>>         node =3D l_hashmap_lookup(tree->objects, path);
>>         if (!node)
>> @@ -725,18 +847,12 @@ bool _dbus_object_tree_unregister(struct
>> _dbus_object_tree *tree,
>>
>>         instance =3D l_queue_remove_if(node->instances,
>>                         match_interface_instance, (char *) interface);
>> +       if (!instance)
>> +               return false;
>>
>> -       r =3D instance ? true : false;
>> -
>> -       if (instance)
>> -               interface_instance_free(instance);
>> -
>> -       if (l_queue_isempty(node->instances) && !node->children) {
>> -               l_hashmap_remove(tree->objects, path);
>> -               _dbus_object_tree_prune_node(node);
>> -       }
>> +       interface_instance_free(instance);
>>
>> -       return r;
>> +       return true;
>>   }
>>
>>   static void generate_interface_instance(void *data, void *user)
>> diff --git a/ell/dbus.c b/ell/dbus.c
>> index 1d9aed5..a9bb314 100644
>> --- a/ell/dbus.c
>> +++ b/ell/dbus.c
>
>
> <snip>
>
>> +
>> +LIB_EXPORT bool l_dbus_register_object(struct l_dbus *dbus, const char
>> *path,
>> +                                       void *user_data,
>> +                                       l_dbus_destroy_func_t destroy,
>> ...)
>> +{
>
>
> We've talked about this before, but this one really needs a documentation
> blurb or an additional example of the expected syntax.
>
> e.g. l_dbus_register_object(dbus, "/foo", object, destroy_object,
> "FooInterface", foo_data, "BarInterface", bar_data, NULL);

Ok, I will try to add some doc comments across the dbus api.

>
>
>> +       va_list args;
>> +       const char *interface;
>> +       void *if_user_data;
>> +       bool r =3D true;;
>> +
>> +       if (unlikely(!dbus))
>> +               return false;
>> +
>> +       if (unlikely(!dbus->tree))
>> +               return false;
>> +
>> +       if (!_dbus_object_tree_new_object(dbus->tree, path, user_data,
>> destroy))
>> +               return false;
>> +
>> +       va_start(args, destroy);
>> +       while ((interface =3D va_arg(args, const char *))) {
>> +               if_user_data =3D va_arg(args, void *);
>> +
>> +               if (!_dbus_object_tree_add_interface(dbus->tree, path,
>> +                                                       interface,
>> +                                                       if_user_data)) {
>> +                       _dbus_object_tree_prune_node(dbus->tree, NULL,
>> path);
>> +                       r =3D false;
>> +
>> +                       break;
>> +               }
>> +       }
>> +       va_end(args);
>> +
>> +       return r;
>> +}
>> +
>
>
> <snip>
>
>
>> diff --git a/unit/test-dbus-service.c b/unit/test-dbus-service.c
>> index d0bf174..16fc00e 100644
>> --- a/unit/test-dbus-service.c
>> +++ b/unit/test-dbus-service.c
>> @@ -205,16 +205,16 @@ static void test_dbus_object_tree(const void
>> *test_data)
>>
>>         tmp =3D _dbus_object_tree_lookup(tree, "/foo/bee");
>>         assert(tmp);
>> -       _dbus_object_tree_prune_node(leaf3);
>> +       _dbus_object_tree_prune_node(tree, leaf3, "/foo/bee/boo");
>>         tmp =3D _dbus_object_tree_lookup(tree, "/foo/bee");
>>         assert(!tmp);
>>
>>         tmp =3D _dbus_object_tree_lookup(tree, "/foo/bar");
>>         assert(tmp);
>> -       _dbus_object_tree_prune_node(leaf2);
>> +       _dbus_object_tree_prune_node(tree, leaf2, "/foo/bar/ble");
>>         tmp =3D _dbus_object_tree_lookup(tree, "/foo/bar");
>>         assert(tmp);
>> -       _dbus_object_tree_prune_node(leaf1);
>> +       _dbus_object_tree_prune_node(tree, leaf1, "/foo/bar/baz");
>>         tmp =3D _dbus_object_tree_lookup(tree, "/foo/bar");
>>         assert(!tmp);
>>         tmp =3D _dbus_object_tree_lookup(tree, "/foo");
>> @@ -276,9 +276,10 @@ static void test_dbus_object_tree_introspection(con=
st
>> void *test_data)
>>
>>         tree =3D _dbus_object_tree_new();
>>
>> -       _dbus_object_tree_register(tree, "/", "org.ofono.Manager",
>> +       _dbus_object_tree_register(tree, "org.ofono.Manager",
>>                                         build_manager_interface,
>> -                                       NULL, NULL);
>> +                                       NULL, false);
>> +       _dbus_object_tree_add_interface(tree, "/", "org.ofono.Manager",
>> NULL);
>>
>>         _dbus_object_tree_makepath(tree, "/phonesim");
>>
>> @@ -298,9 +299,11 @@ static void test_dbus_object_tree_dispatch(const vo=
id
>> *test_data)
>>
>>         tree =3D _dbus_object_tree_new();
>>
>> -       _dbus_object_tree_register(tree, "/", "org.ofono.Manager",
>> +       _dbus_object_tree_register(tree, "org.ofono.Manager",
>>                                         build_manager_interface,
>> -                                       dummy_data, NULL);
>> +                                       NULL, false);
>> +       _dbus_object_tree_add_interface(tree, "/", "org.ofono.Manager",
>> +                                       dummy_data);
>>
>>         message =3D _dbus_message_new_method_call(1, "org.ofono", "/",
>>                                                 "org.ofono.Manager",
>
>
> <snip>
>
> By the way, applying this patch makes unit tests fail:
> denkenz(a)new-host-2 ~/ell $ unit/test-dbus-service
> TEST: Test Frobate Introspection
> TEST: Test Bazify Introspection
> TEST: Test Mogrify Introspection
> TEST: Test Changed Introspection
> TEST: Test Bar Property Introspection
> test-dbus-service: unit/test-dbus-service.c:157: test_introspect_property:
> Assertion `!strcmp(test->expected_xml, xml)' failed.
> Aborted

I see why, I'll fix patch 1/8 to avoid this.

Best regards

--===============7225307533967915964==--

