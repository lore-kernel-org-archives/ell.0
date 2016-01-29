Content-Type: multipart/mixed; boundary="===============1369137613126852427=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC PATCH 8/8] dbus: Implement org.freedesktop.DBus.ObjectManager
Date: Fri, 29 Jan 2016 13:19:32 -0600
Message-ID: <56ABBB44.9020607@gmail.com>
In-Reply-To: <CAOq732JEM5cPEpb6Dw5DzoAm3G0CTWsBz49xS-afcjVdJvcesA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1369137613126852427==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/29/2016 12:53 PM, Andrzej Zaborowski wrote:
> Hi Denis,
>
> On 29 January 2016 at 18:44, Denis Kenzior <denkenz@gmail.com> wrote:
>> Sort of.  We have the interfaces hanging off the tree object.  I think t=
hey
>> might belong on a global data structure and shared between multiple obje=
ct
>> trees.
>
> That is something I have considered too.  The code change would
> probably be small so could also be done in a separate step, what do
> you think?

Whichever works and is easier for you.

>
> Note that if two pieces in a modular application have separate dbus
> trees and use the same interfaces, when registering them they'd have
> to check the error code and ignore the error if it says the interface
> is already registered.
>

I'm just thinking of a case where we have dbus + kdbus active or dbus + =

custom bus.  Probably unlikely, but the discussed structure makes sense =

anyway.

Don't think we'd have multiple interface registrations in our apps. =

Lets see if this will actually affect us.  Worst case we change the =

return value to int and return -EALREADY.

>>
>>>> We have to be pretty careful here.  What if the object is removed while
>>>> we're generating the reply?  Do we need to rethink having async getter=
s?
>>>
>>>
>>> That's a good point, and I also haven't yet added any code to forget
>>> about the running getters and setters calls when a dbus connection is
>>> shut down. But I don't think we can avoid async getters and setters.
>>> In this case it should be sufficient to check that the path and the
>>> instance are still present just before making the call.
>>
>>
>> Setters are not the problem.  Those can be async.
>>
>> I'm now not convinced that getters can be async given the complexity of =
the
>> resulting code.  See what you can come up with, but we might need to thi=
nk
>> carefully about this some more.
>
> I'm not sure synchronous getters are possible for all clients, and I
> think the code can be made a little cleaner.  Let me submit one more
> version and see if it's okay.
>

Sure.  But FYI the gdbus getters are all synchronous.  So it might be =

something we have to live with.

>>
>>>>
>>>>
>>>> Yikes.  Is there a way to be a bit smarter here and walk the tree inst=
ead
>>>> of
>>>> using the very expensive hashmap_foreach?
>>>
>>>
>>> We can do either, but it doesn't seem like l_hashmap_foreach is that
>>> expensive.  It is going to make some useless iterations while there
>>> are empty buckets, later it's just as fast as a list.  The tree on the
>>> other hand has more nodes we're not interested in.
>>
>>
>> Not sure I agree.  If we have an object manager on a subpath, then there=
's
>> no point walking the entire hashmap.  Walking through the children of the
>> node would be faster in this case and eliminates some strcmps.
>>
>> For the root ObjectManager, this call is also pointless since we know all
>> the objects will be included.
>
> Well, it depends on how the tree looks and how the code gets compiled
> but in terms of all loop iterations, if you had long paths with a
> single leaf each then walking the full tree may be more a lot longer
> than walking a balanced hashmap with 128 buckets.

True, but how likely is that? :)  Our trees tend to have lots of objects =

hanging off / and then some nested objects.  E.g. oFono operators, gprs =

contexts, sms messages or iwd networks.  So lets optimize for those cases.

>
>> Anyway, I think we have more important things
>> to consider, but keep this one in mind.
>
> I'll try doing this the way you suggest as it should be a simple
> change and for non-root object managers it makes more sense.
>

Sounds good.

Regards,
-Denis


--===============1369137613126852427==--

