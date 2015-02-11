Content-Type: multipart/mixed; boundary="===============3683271187199591465=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 6/9] hashmap: Add re-entrancy support to foreach function
Date: Wed, 11 Feb 2015 08:06:59 -0600
Message-ID: <54DB6203.3070107@gmail.com>
In-Reply-To: <1423646474.5906.133.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3683271187199591465==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Patrik,

On 02/11/2015 03:21 AM, Patrik Flykt wrote:
> On Tue, 2015-02-10 at 13:47 -0600, Denis Kenzior wrote:
>> Can you tell me why this is needed?  This sounds like abuse of
>> hashmap_foreach and an alternate data structure might be in order.
>
> One should not be able to crash the library by (mis)using the provided
> API. The implementation needs to work all the time or politely tell that
> the API function call did not complete at this time.
>

Are you serious?  I've yet to see any library that I can't crash by =

deliberately misusing the API; even the best can't do what you're =

describing.  Ell's job is not to hand-hold the programmer.

>>> So foreach logic is changed so that if user tries to remove
>>> an entry from the hash while inside foreach callback, the
>>> entry is not yet removed from hash but marked as removable.
>>> After foreach has finished calling the callback function,
>>> it checks what elements it needs to remove from the hash.
>>>
>>
>> So let me politely say: "No way are we doing this" ;)
>
> Then the only alternative is to return false for any functionality that
> otherwise causes the implementation to crash. For example when
> inserting/removing items from the hash while an foreach is ongoing.

No, the alternative is to crash.  Crashing is pretty much the best way =

to tell the programmer he's doing something stupid.

>
> glib also crashed with this pattern. Or usually worked ok, as the
> removed/added item wasn't always the item used in foreach or the next
> item. Fixing this to allow any API call successfully work at any time
> requires quite some more work to be done, the above patch by Jukka was
> approximately the minimum needed for a remove to work at any one time.
>

If you find a good way to fix this in the data structure, great.  But =

the current fix is not acceptable.  We will not be iterating over the =

_entire_ data structure twice.  The foreach operation is already =

expensive and too tempting to abuse.

> With that the insert part is still left, but it might be easier if the
> one and only foreach iterator next element is remembered by the hash
> data structure and the insert/remove operation move the next position
> when needed. In addition, also the foreach operation needs to guard
> against itself...

I look forward to your patch :)

Regards,
-Denis


--===============3683271187199591465==--

