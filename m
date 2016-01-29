Content-Type: multipart/mixed; boundary="===============6358382275249304411=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC PATCH 8/8] dbus: Implement org.freedesktop.DBus.ObjectManager
Date: Fri, 29 Jan 2016 11:44:50 -0600
Message-ID: <56ABA512.8000801@gmail.com>
In-Reply-To: <CAOq732+Y8bTARJvYzhcfgXzqaa42xmVLj6quG5Uo1j-ciyCJ7A@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6358382275249304411==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/29/2016 10:47 AM, Andrzej Zaborowski wrote:
> Hi Denis,
>
> On 29 January 2016 at 04:35, Denis Kenzior <denkenz@gmail.com> wrote:
>> I think the way we want to do this is to model things something along th=
ese
>> lines:
>>
>> register_interface -> registers global interface object, e.g.
>> l_dbus_interface
>> add_interface -> adds an instance of the interface to the tree, e.g.
>> interface_instance
>>
>> Each dbus bus instance would have a 1:1 relationship to the object tree.
>
> So far that is what we have in this patch series, right?

Sort of.  We have the interfaces hanging off the tree object.  I think =

they might belong on a global data structure and shared between multiple =

object trees.

>> We have to be pretty careful here.  What if the object is removed while
>> we're generating the reply?  Do we need to rethink having async getters?
>
> That's a good point, and I also haven't yet added any code to forget
> about the running getters and setters calls when a dbus connection is
> shut down. But I don't think we can avoid async getters and setters.
> In this case it should be sufficient to check that the path and the
> instance are still present just before making the call.

Setters are not the problem.  Those can be async.

I'm now not convinced that getters can be async given the complexity of =

the resulting code.  See what you can come up with, but we might need to =

think carefully about this some more.

>>
>>
>> Yikes.  Is there a way to be a bit smarter here and walk the tree instea=
d of
>> using the very expensive hashmap_foreach?
>
> We can do either, but it doesn't seem like l_hashmap_foreach is that
> expensive.  It is going to make some useless iterations while there
> are empty buckets, later it's just as fast as a list.  The tree on the
> other hand has more nodes we're not interested in.

Not sure I agree.  If we have an object manager on a subpath, then =

there's no point walking the entire hashmap.  Walking through the =

children of the node would be faster in this case and eliminates some =

strcmps.

For the root ObjectManager, this call is also pointless since we know =

all the objects will be included.  Anyway, I think we have more =

important things to consider, but keep this one in mind.

Regards,
-Denis

--===============6358382275249304411==--

