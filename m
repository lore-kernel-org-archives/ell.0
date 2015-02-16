Content-Type: multipart/mixed; boundary="===============2283678339250274604=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Mon, 16 Feb 2015 11:03:42 -0800
Message-ID: <C9C4AA4F-D920-42E6-9519-5121D2FE7691@holtmann.org>
In-Reply-To: <CABBYNZ+kjhv1coqopMtSOT8a1Hc_UmL1pktv3XKNKruSUMkq7Q@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2283678339250274604==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Luiz,

>>>>>>>>> glib also crashed with this pattern. Or usually worked ok, as the
>>>>>>>>> removed/added item wasn't always the item used in foreach or the =
next
>>>>>>>>> item. Fixing this to allow any API call successfully work at any =
time
>>>>>>>>> requires quite some more work to be done, the above patch by Jukk=
a was
>>>>>>>>> approximately the minimum needed for a remove to work at any one =
time.
>>>>>>>>> =

>>>>>>>> =

>>>>>>>> If you find a good way to fix this in the data structure, great. B=
ut
>>>>>>>> the current fix is not acceptable.  We will not be iterating over =
the
>>>>>>>> _entire_ data structure twice.  The foreach operation is already
>>>>>>>> expensive and too tempting to abuse.
>>>>>>> =

>>>>>>> =

>>>>>>> The patch would iterate the data structure twice only if user did m=
odify
>>>>>>> the hash in the callback func. That is probably not very common case
>>>>>>> anyway.
>>>>>>> =

>>>>>> =

>>>>>> Does not matter. An operation that you expect to take O(n) suddenly =
becomes
>>>>>> O(2n).  That's just not acceptable.  Remember, we're running on low-=
power
>>>>>> devices, so our data structures will be optimized for speed. Program=
mer
>>>>>> convenience is a secondary concern.
>>>>>> =

>>>>>> Anyway, I pushed a documentation clarification to ell/hashmap.c expl=
aining
>>>>>> that the hashmap must be invariant during an ongoing l_hashmap_forea=
ch
>>>>>> operation.
>>>>>> =

>>>>>> So you need to find an alternate approach.  Think through your data
>>>>>> structures carefully.
>>>>> =

>>>>> Ive solved a similar problem with queues in BlueZ, it is very similar
>>>>> to ell queues, the code looks like this now:
>>>>> =

>>>>> http://fpaste.org/185237/14238402/
>>>>> =

>>>>> So it basically protects the entries by taking a reference before
>>>>> calling the callback, and also the queue itself before starting
>>>>> iterating, and it just need a single loop. While it can still be
>>>>> vulnerable to bad usage I still think it worth doing because this case
>>>>> of callback removing the entry itself it very common, there is
>>>>> actually 3 cases that we want to allow queue_remove(entry),
>>>>> queue_remove_all and queue_unref by the callback so we added unit
>>>>> tests to emulate these 3 scenarios.
>>>> =

>>>> and this is most likely code that we have to take out again. And rever=
t all users to handle this by themselves. It is not in line with the goals =
of ELL. And I did warn about that. The reference counting for each entry is=
 pretty wasteful from a memory point of view. Especially if we are running =
on a system where every single byte of memory usage counts.
>>>> =

>>>> The goal for BlueZ is to eventually be able to run on top of ELL. This=
 means that we have to be really cautious about what we provide and how. EL=
L is not just another GLib. It is not a dumping ground. We are looking at r=
eally memory restraint systems. There is a high chance that we have to make=
 ELL even modular and provide an option to compile it without certain modul=
es like D-Bus or netlink.
>>>> =

>>>> I am just mentioning this here so that everybody understands what our =
goals here. We might be utilizing systems where the userspace is small and =
really limited. What ELL needs to do is provide common functionality for it=
s users, but it does not have to solve world hunger for its users.
>>> =

>>> Sorry but I cannot understand this motive, the reference counting will
>>> happen anyway since it is most common way to protect against callbacks
>>> destroying the very entry, if you don't do in ell the user code will
>>> do it and memory will be consumed whether you like it or not. So you
>>> talk about memory restraint system but your solution may actually
>>> cause more memory to be consumed, outside of ell.
>> =

>> so adding an int ref_count to each queue entry is adding substantive ove=
rhead for every single user. Meaning that every single queue entry we have =
to store has an extra sizeof(int) allocated.
> =

> That if we use an int, we could use uint8_t which is equivalent to
> bool, the reference is just for internal use anyway it does not get
> more than 2 ever.
> =

>> Compare this with a single sizeof(bool) for something like in_notify as =
we used in some of our code. So the more elements you store in the queue, t=
he more data you are using. And on top of that it is more data for every si=
ngle user. No matter if it requires the queue to re-entrancy safe or not.
> =

> Not quite, actually there was 4 flags to track this properly in the
> mgmt code, see for yourself:
> https://git.kernel.org/cgit/bluetooth/bluez.git/commit/?id=3Db72dee02b2e5=
dec9fbcf6ce97848fb08363a035d

you are not comparing the right pieces here.

One is the struct queue and the other struct queue_entry. If you add anythi=
ng to struct queue_entry you are punishing every single data block. It is n=
ot a one-time penalty. It is for every user. So if some user wants to store=
 100 entries in the queue, then they get 100 * sizeof(int) extra overhead.

And as I explained for that exact reason, the queue_entry is single linked =
list. This means that queue_pop_tail is not a favorable operation and we do=
 not support it. When we started ELL and discussed these details, I ended u=
p going through GLib users and see how much this operation would be needed =
and what it is used for. The result was we do not want that.

I prefer having 4 constant flags in the queue user compared to punishing ev=
ery single queue entry with any extra overhead.

>> You might have realized that our queue entry struct has on purpose only =
a next pointer. We decided really early that we want the queue to be a sing=
le list. And we accepted that because of that corner-case operations will b=
e highly expensive. This means that while queues are useful for a lot of ca=
ses, they will not be useful for all.
>> =

>> We really do not want the massive bloat GLib repeated. The user of the E=
LL data structures has to know what they are doing. The queue data structur=
e is not one fits all use case.
> =

> Im not even considering GLib as a good example, it actually surfer
> from the very same problem, as you can see there are a lot of corner
> cases and we end up with O(2n) situation Denis was complaining about
> Jukka's changes, anyway all this code seems to be inspired in at_chat
> from oFono which has the very same O(2n) pattern, so perhaps we need a
> specialized notification list? One that doesn't bloat the caller at
> very least.

There will be cases where a dedicated data structure just makes more sense =
and is more efficient. That is totally acceptable and encouraged.

This essentially goes back to the original argument that Denis made. ELL is=
 not something that can solve all your problems. If the caller/user of the =
data structures is behaving stupid, then the only thing ELL can do is abort=
. Which is a behavior we want since then we can collect traces of the fault=
y behavior.

Regards

Marcel


--===============2283678339250274604==--

