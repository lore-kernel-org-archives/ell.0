Content-Type: multipart/mixed; boundary="===============7404585358949601608=="
MIME-Version: 1.0
From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Fri, 13 Feb 2015 17:38:36 +0200
Message-ID: <CABBYNZ+TsZYKNE54-BT7UKDAcwwcZUyoSpHfmuZyeDs3VAGoTw@mail.gmail.com>
In-Reply-To: <54DCE90A.7030102@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7404585358949601608==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis, Jukka,

On Thu, Feb 12, 2015 at 7:55 PM, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Jukka,
>
> On 02/12/2015 01:25 AM, Jukka Rissanen wrote:
>>
>> On ke, 2015-02-11 at 08:06 -0600, Denis Kenzior wrote:
>>>
>>> Hi Patrik,
>>>
>>
>>>>
>>>> glib also crashed with this pattern. Or usually worked ok, as the
>>>> removed/added item wasn't always the item used in foreach or the next
>>>> item. Fixing this to allow any API call successfully work at any time
>>>> requires quite some more work to be done, the above patch by Jukka was
>>>> approximately the minimum needed for a remove to work at any one time.
>>>>
>>>
>>> If you find a good way to fix this in the data structure, great.  But
>>> the current fix is not acceptable.  We will not be iterating over the
>>> _entire_ data structure twice.  The foreach operation is already
>>> expensive and too tempting to abuse.
>>
>>
>> The patch would iterate the data structure twice only if user did modify
>> the hash in the callback func. That is probably not very common case
>> anyway.
>>
>
> Does not matter. An operation that you expect to take O(n) suddenly becom=
es
> O(2n).  That's just not acceptable.  Remember, we're running on low-power
> devices, so our data structures will be optimized for speed. Programmer
> convenience is a secondary concern.
>
> Anyway, I pushed a documentation clarification to ell/hashmap.c explaining
> that the hashmap must be invariant during an ongoing l_hashmap_foreach
> operation.
>
> So you need to find an alternate approach.  Think through your data
> structures carefully.

Ive solved a similar problem with queues in BlueZ, it is very similar
to ell queues, the code looks like this now:

http://fpaste.org/185237/14238402/

So it basically protects the entries by taking a reference before
calling the callback, and also the queue itself before starting
iterating, and it just need a single loop. While it can still be
vulnerable to bad usage I still think it worth doing because this case
of callback removing the entry itself it very common, there is
actually 3 cases that we want to allow queue_remove(entry),
queue_remove_all and queue_unref by the callback so we added unit
tests to emulate these 3 scenarios.

> Regards,
> -Denis
>
>
> _______________________________________________
> ell mailing list
> ell(a)lists.01.org
> https://lists.01.org/mailman/listinfo/ell



-- =

Luiz Augusto von Dentz

--===============7404585358949601608==--

