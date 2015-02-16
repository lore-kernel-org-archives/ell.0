Content-Type: multipart/mixed; boundary="===============9153593027013568926=="
MIME-Version: 1.0
From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Mon, 16 Feb 2015 11:44:46 +0200
Message-ID: <CABBYNZ+DaMfCbno+yxhj30d-=4Eo6CRrd88K=8wSO-Fr3QCZhQ@mail.gmail.com>
In-Reply-To: <B8BC2303-DDA8-48EC-876D-D4820A23541A@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9153593027013568926==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel, Denis,

On Fri, Feb 13, 2015 at 7:36 PM, Marcel Holtmann <marcel@holtmann.org> wr=
ote:
> Hi Luiz,
>
>>>>>> glib also crashed with this pattern. Or usually worked ok, as the
>>>>>> removed/added item wasn't always the item used in foreach or the next
>>>>>> item. Fixing this to allow any API call successfully work at any time
>>>>>> requires quite some more work to be done, the above patch by Jukka w=
as
>>>>>> approximately the minimum needed for a remove to work at any one tim=
e.
>>>>>>
>>>>>
>>>>> If you find a good way to fix this in the data structure, great.  But
>>>>> the current fix is not acceptable.  We will not be iterating over the
>>>>> _entire_ data structure twice.  The foreach operation is already
>>>>> expensive and too tempting to abuse.
>>>>
>>>>
>>>> The patch would iterate the data structure twice only if user did modi=
fy
>>>> the hash in the callback func. That is probably not very common case
>>>> anyway.
>>>>
>>>
>>> Does not matter. An operation that you expect to take O(n) suddenly bec=
omes
>>> O(2n).  That's just not acceptable.  Remember, we're running on low-pow=
er
>>> devices, so our data structures will be optimized for speed. Programmer
>>> convenience is a secondary concern.
>>>
>>> Anyway, I pushed a documentation clarification to ell/hashmap.c explain=
ing
>>> that the hashmap must be invariant during an ongoing l_hashmap_foreach
>>> operation.
>>>
>>> So you need to find an alternate approach.  Think through your data
>>> structures carefully.
>>
>> Ive solved a similar problem with queues in BlueZ, it is very similar
>> to ell queues, the code looks like this now:
>>
>> http://fpaste.org/185237/14238402/
>>
>> So it basically protects the entries by taking a reference before
>> calling the callback, and also the queue itself before starting
>> iterating, and it just need a single loop. While it can still be
>> vulnerable to bad usage I still think it worth doing because this case
>> of callback removing the entry itself it very common, there is
>> actually 3 cases that we want to allow queue_remove(entry),
>> queue_remove_all and queue_unref by the callback so we added unit
>> tests to emulate these 3 scenarios.
>
> and this is most likely code that we have to take out again. And revert a=
ll users to handle this by themselves. It is not in line with the goals of =
ELL. And I did warn about that. The reference counting for each entry is pr=
etty wasteful from a memory point of view. Especially if we are running on =
a system where every single byte of memory usage counts.
>
> The goal for BlueZ is to eventually be able to run on top of ELL. This me=
ans that we have to be really cautious about what we provide and how. ELL i=
s not just another GLib. It is not a dumping ground. We are looking at real=
ly memory restraint systems. There is a high chance that we have to make EL=
L even modular and provide an option to compile it without certain modules =
like D-Bus or netlink.
>
> I am just mentioning this here so that everybody understands what our goa=
ls here. We might be utilizing systems where the userspace is small and rea=
lly limited. What ELL needs to do is provide common functionality for its u=
sers, but it does not have to solve world hunger for its users.

Sorry but I cannot understand this motive, the reference counting will
happen anyway since it is most common way to protect against callbacks
destroying the very entry, if you don't do in ell the user code will
do it and memory will be consumed whether you like it or not. So you
talk about memory restraint system but your solution may actually
cause more memory to be consumed, outside of ell.

-- =

Luiz Augusto von Dentz

--===============9153593027013568926==--

