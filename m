Content-Type: multipart/mixed; boundary="===============3360582072508326313=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC PATCH 2/8] dbus: Separate interface registration from
 instantiation
Date: Tue, 26 Jan 2016 18:16:26 -0600
Message-ID: <56A80C5A.4040103@gmail.com>
In-Reply-To: <CAOq732JZau7d9XN9OqGxjeN7GdRdZTWta8Mq502qPqN7UY0xDA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3360582072508326313==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 >>
>> If we register object on '/a', then register object on '/a/b'.  We have =
two
>> objects in the tree->objects hashmap.  If we unregister object '/a' firs=
t,
>> then tree->objects will no longer contain '/a'.
>
> _dbus_object_tree_unregister currently does:
>
>      if (l_queue_isempty(node->instances) && !node->children) {
>         l_hashmap_remove(tree->objects, path);
>         _dbus_object_tree_prune_node(node);
>      }
>
> So since /a's node->chlidren is not empty,
> l_hashmap_remove(tree->objects, path); will not happen.  Both /a and
> /a/b will remain in the hashmap.

Aha, okay I was wrong on that.

>
>> Then unregistering '/a/b'
>> will prune the tree upwards.
>
> Right, at that point /a will be removed from the tree but not from
> tree->objects.
>
> On a second thought, I think the current code can be fixed by doing two t=
hings:
>
>      if (l_queue_isempty(node->instances)) {
>         l_hashmap_remove(tree->objects, path);
>         if (!node->children)
>             _dbus_object_tree_prune_node(node);
>      }
>

Yes, I think this is the right fix.  I think I even intended it to be =

this way but somehow this got screwed up.  Guess we never tested =

removing the parent before the children.  A good candidate for a unit test.

> ...and adding a check in _dbus_object_tree_prune_node to make sure we
> don't remove nodes that still have nonempty node->instances.
>

You might want to check all uses of it to see if this is really needed.

>>> +bool _dbus_object_tree_prune_node(struct _dbus_object_tree *tree,
>>> +                                       struct object_node *node,
>>> +                                       const char *path)
>>
>>
>> This part sounds like it really belongs in a separate patch...
>
> Do you mean both of _dbus_object_tree_new_object and
> _dbus_object_tree_prune_node?

I only meant the prune_node fix.  It probably needs a separate patch and =

can go in right away.

>> I'm not sure this is useful in its current form.  If we want to have thi=
s,
>> then we probably need to distinguish between telling the programmer that
>> "you're trying to unregister an unknown interface" vs "you're trying to
>> unregister a interface that is still being used".  As an alternative, you
>> can keep a reference count on the interface itself and keep the object
>> around until all instances have been destroyed, and this function would
>> always succeed...
>>
>> However, I would keep it simple and just let the programmer control this.
>> If they try to remove an interface that is still being used, things will
>> crash spectacularly and valgrind/gdb will find it very fast.  Remember o=
ur
>> motto, "crash early, crash often" :)
>
> Yes, good point.  Or we can remove the interface and remove all of its
> instances which is in a way logical.

Or could do that.  I let you decide.

>
> I see why, I'll fix patch 1/8 to avoid this.

Okay, thanks.

Regards,
-Denis

--===============3360582072508326313==--

