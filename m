Content-Type: multipart/mixed; boundary="===============3833834664142621667=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/2] fswatch: Add fswatch API
Date: Fri, 20 Jul 2018 18:29:53 +0200
Message-ID: <CAOq732L7RuTJmVJLbi7YpX80JH9ijraVviRWy=2hJAjwhwK2Eg@mail.gmail.com>
In-Reply-To: <d3087679-7d5a-b968-3d9e-1876fbe3c40b@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3833834664142621667==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 20 July 2018 at 18:21, Denis Kenzior <denkenz@gmail.com> wrote:
>>>> +LIB_EXPORT bool l_fswatch_destroy(struct l_fswatch *watch)
>>>
>>> I still don't see why this returns bool, what can the caller do if the
>>> call
>>> fails?
>>
>> Not much, but we can't do much either.  We can free the memeory, yes,
>> but should we hide the error?
>
>
> There's no point returning an error out to the user if they can't do
> anything about it, especially if it leaves them powerless from reclaiming
> memory allocated to the watch.
>
> So yes, it is probably better to return void (and maybe print an l_error)
> than to return an error here.

Ok.

>
>>>> +typedef void (*l_fswatch_destroy_cb_t) (struct l_fswatch *watch,
>>>> +                                       void *user_data);
>>>
>>>
>>>
>>> Why would this destroy callback signature be different from all others?
>>> It
>>> also precludes us from doing something like:
>>>
>>> l_fswatch_new("/foo/bar", cb, u, (l_fswatch_destroy_cb_t) l_free);
>>
>>
>> Ok, thought it might be useful to pass the watch pointer, it doesn't
>> cost us anything and could simplify things for some users.
>>
>
> This is useful for callbacks, but almost never happens for destroy
> callbacks.  In too many cases the destroy callback is just l_free or
> some_structure_destroy(struct some_structure).  So having to come up with
> another function just to have the correct signature is wasteful. For the
> 1-5% usecase where this might be useful, the caller can carry the fswatch
> pointer in the userdata structure itself.

Fair enough although I was specifically thinking about simplifying
cases where there's no userdata and the watch pointer is enough to
identify the watch... but then you can also just have multiple destroy
callbacks.

BTW I looked at the for loop in the man page and it seems it's
actually not initialising 'event' before first use so I won't be
following that pattern.

Cheers

--===============3833834664142621667==--

