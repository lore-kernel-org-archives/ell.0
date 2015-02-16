Content-Type: multipart/mixed; boundary="===============2790263041737495163=="
MIME-Version: 1.0
From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Mon, 16 Feb 2015 20:27:45 +0200
Message-ID: <CABBYNZ+kjhv1coqopMtSOT8a1Hc_UmL1pktv3XKNKruSUMkq7Q@mail.gmail.com>
In-Reply-To: <FC3E51D9-9CD5-4507-94DF-C4F1B069806F@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2790263041737495163==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

On Mon, Feb 16, 2015 at 6:18 PM, Marcel Holtmann <marcel@holtmann.org> wr=
ote:
> Hi Luiz,
>
>>>>>>>> glib also crashed with this pattern. Or usually worked ok, as the
>>>>>>>> removed/added item wasn't always the item used in foreach or the n=
ext
>>>>>>>> item. Fixing this to allow any API call successfully work at any t=
ime
>>>>>>>> requires quite some more work to be done, the above patch by Jukka=
 was
>>>>>>>> approximately the minimum needed for a remove to work at any one t=
ime.
>>>>>>>>
>>>>>>>
>>>>>>> If you find a good way to fix this in the data structure, great.  B=
ut
>>>>>>> the current fix is not acceptable.  We will not be iterating over t=
he
>>>>>>> _entire_ data structure twice.  The foreach operation is already
>>>>>>> expensive and too tempting to abuse.
>>>>>>
>>>>>>
>>>>>> The patch would iterate the data structure twice only if user did mo=
dify
>>>>>> the hash in the callback func. That is probably not very common case
>>>>>> anyway.
>>>>>>
>>>>>
>>>>> Does not matter. An operation that you expect to take O(n) suddenly b=
ecomes
>>>>> O(2n).  That's just not acceptable.  Remember, we're running on low-p=
ower
>>>>> devices, so our data structures will be optimized for speed. Programm=
er
>>>>> convenience is a secondary concern.
>>>>>
>>>>> Anyway, I pushed a documentation clarification to ell/hashmap.c expla=
ining
>>>>> that the hashmap must be invariant during an ongoing l_hashmap_foreach
>>>>> operation.
>>>>>
>>>>> So you need to find an alternate approach.  Think through your data
>>>>> structures carefully.
>>>>
>>>> Ive solved a similar problem with queues in BlueZ, it is very similar
>>>> to ell queues, the code looks like this now:
>>>>
>>>> http://fpaste.org/185237/14238402/
>>>>
>>>> So it basically protects the entries by taking a reference before
>>>> calling the callback, and also the queue itself before starting
>>>> iterating, and it just need a single loop. While it can still be
>>>> vulnerable to bad usage I still think it worth doing because this case
>>>> of callback removing the entry itself it very common, there is
>>>> actually 3 cases that we want to allow queue_remove(entry),
>>>> queue_remove_all and queue_unref by the callback so we added unit
>>>> tests to emulate these 3 scenarios.
>>>
>>> and this is most likely code that we have to take out again. And revert=
 all users to handle this by themselves. It is not in line with the goals o=
f ELL. And I did warn about that. The reference counting for each entry is =
pretty wasteful from a memory point of view. Especially if we are running o=
n a system where every single byte of memory usage counts.
>>>
>>> The goal for BlueZ is to eventually be able to run on top of ELL. This =
means that we have to be really cautious about what we provide and how. ELL=
 is not just another GLib. It is not a dumping ground. We are looking at re=
ally memory restraint systems. There is a high chance that we have to make =
ELL even modular and provide an option to compile it without certain module=
s like D-Bus or netlink.
>>>
>>> I am just mentioning this here so that everybody understands what our g=
oals here. We might be utilizing systems where the userspace is small and r=
eally limited. What ELL needs to do is provide common functionality for its=
 users, but it does not have to solve world hunger for its users.
>>
>> Sorry but I cannot understand this motive, the reference counting will
>> happen anyway since it is most common way to protect against callbacks
>> destroying the very entry, if you don't do in ell the user code will
>> do it and memory will be consumed whether you like it or not. So you
>> talk about memory restraint system but your solution may actually
>> cause more memory to be consumed, outside of ell.
>
> so adding an int ref_count to each queue entry is adding substantive over=
head for every single user. Meaning that every single queue entry we have t=
o store has an extra sizeof(int) allocated.

That if we use an int, we could use uint8_t which is equivalent to
bool, the reference is just for internal use anyway it does not get
more than 2 ever.

> Compare this with a single sizeof(bool) for something like in_notify as w=
e used in some of our code. So the more elements you store in the queue, th=
e more data you are using. And on top of that it is more data for every sin=
gle user. No matter if it requires the queue to re-entrancy safe or not.

Not quite, actually there was 4 flags to track this properly in the
mgmt code, see for yourself:
https://git.kernel.org/cgit/bluetooth/bluez.git/commit/?id=3Db72dee02b2e5de=
c9fbcf6ce97848fb08363a035d

> You might have realized that our queue entry struct has on purpose only a=
 next pointer. We decided really early that we want the queue to be a singl=
e list. And we accepted that because of that corner-case operations will be=
 highly expensive. This means that while queues are useful for a lot of cas=
es, they will not be useful for all.
>
> We really do not want the massive bloat GLib repeated. The user of the EL=
L data structures has to know what they are doing. The queue data structure=
 is not one fits all use case.

Im not even considering GLib as a good example, it actually surfer
from the very same problem, as you can see there are a lot of corner
cases and we end up with O(2n) situation Denis was complaining about
Jukka's changes, anyway all this code seems to be inspired in at_chat
from oFono which has the very same O(2n) pattern, so perhaps we need a
specialized notification list? One that doesn't bloat the caller at
very least.


-- =

Luiz Augusto von Dentz

--===============2790263041737495163==--

