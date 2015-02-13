Content-Type: multipart/mixed; boundary="===============1990628897695331432=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Fri, 13 Feb 2015 09:36:36 -0800
Message-ID: <B8BC2303-DDA8-48EC-876D-D4820A23541A@holtmann.org>
In-Reply-To: <CABBYNZ+TsZYKNE54-BT7UKDAcwwcZUyoSpHfmuZyeDs3VAGoTw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1990628897695331432==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Luiz,

>>>>> glib also crashed with this pattern. Or usually worked ok, as the
>>>>> removed/added item wasn't always the item used in foreach or the next
>>>>> item. Fixing this to allow any API call successfully work at any time
>>>>> requires quite some more work to be done, the above patch by Jukka was
>>>>> approximately the minimum needed for a remove to work at any one time.
>>>>> =

>>>> =

>>>> If you find a good way to fix this in the data structure, great.  But
>>>> the current fix is not acceptable.  We will not be iterating over the
>>>> _entire_ data structure twice.  The foreach operation is already
>>>> expensive and too tempting to abuse.
>>> =

>>> =

>>> The patch would iterate the data structure twice only if user did modify
>>> the hash in the callback func. That is probably not very common case
>>> anyway.
>>> =

>> =

>> Does not matter. An operation that you expect to take O(n) suddenly beco=
mes
>> O(2n).  That's just not acceptable.  Remember, we're running on low-power
>> devices, so our data structures will be optimized for speed. Programmer
>> convenience is a secondary concern.
>> =

>> Anyway, I pushed a documentation clarification to ell/hashmap.c explaini=
ng
>> that the hashmap must be invariant during an ongoing l_hashmap_foreach
>> operation.
>> =

>> So you need to find an alternate approach.  Think through your data
>> structures carefully.
> =

> Ive solved a similar problem with queues in BlueZ, it is very similar
> to ell queues, the code looks like this now:
> =

> http://fpaste.org/185237/14238402/
> =

> So it basically protects the entries by taking a reference before
> calling the callback, and also the queue itself before starting
> iterating, and it just need a single loop. While it can still be
> vulnerable to bad usage I still think it worth doing because this case
> of callback removing the entry itself it very common, there is
> actually 3 cases that we want to allow queue_remove(entry),
> queue_remove_all and queue_unref by the callback so we added unit
> tests to emulate these 3 scenarios.

and this is most likely code that we have to take out again. And revert all=
 users to handle this by themselves. It is not in line with the goals of EL=
L. And I did warn about that. The reference counting for each entry is pret=
ty wasteful from a memory point of view. Especially if we are running on a =
system where every single byte of memory usage counts.

The goal for BlueZ is to eventually be able to run on top of ELL. This mean=
s that we have to be really cautious about what we provide and how. ELL is =
not just another GLib. It is not a dumping ground. We are looking at really=
 memory restraint systems. There is a high chance that we have to make ELL =
even modular and provide an option to compile it without certain modules li=
ke D-Bus or netlink.

I am just mentioning this here so that everybody understands what our goals=
 here. We might be utilizing systems where the userspace is small and reall=
y limited. What ELL needs to do is provide common functionality for its use=
rs, but it does not have to solve world hunger for its users.

Regards

Marcel


--===============1990628897695331432==--

