Content-Type: multipart/mixed; boundary="===============3184866552037617416=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Thu, 12 Feb 2015 11:55:22 -0600
Message-ID: <54DCE90A.7030102@gmail.com>
In-Reply-To: <1423725932.4196.8.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3184866552037617416==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/12/2015 01:25 AM, Jukka Rissanen wrote:
> On ke, 2015-02-11 at 08:06 -0600, Denis Kenzior wrote:
>> Hi Patrik,
>>
>
>>>
>>> glib also crashed with this pattern. Or usually worked ok, as the
>>> removed/added item wasn't always the item used in foreach or the next
>>> item. Fixing this to allow any API call successfully work at any time
>>> requires quite some more work to be done, the above patch by Jukka was
>>> approximately the minimum needed for a remove to work at any one time.
>>>
>>
>> If you find a good way to fix this in the data structure, great.  But
>> the current fix is not acceptable.  We will not be iterating over the
>> _entire_ data structure twice.  The foreach operation is already
>> expensive and too tempting to abuse.
>
> The patch would iterate the data structure twice only if user did modify
> the hash in the callback func. That is probably not very common case
> anyway.
>

Does not matter. An operation that you expect to take O(n) suddenly =

becomes O(2n).  That's just not acceptable.  Remember, we're running on =

low-power devices, so our data structures will be optimized for speed. =

Programmer convenience is a secondary concern.

Anyway, I pushed a documentation clarification to ell/hashmap.c =

explaining that the hashmap must be invariant during an ongoing =

l_hashmap_foreach operation.

So you need to find an alternate approach.  Think through your data =

structures carefully.

Regards,
-Denis


--===============3184866552037617416==--

