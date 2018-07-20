Content-Type: multipart/mixed; boundary="===============3835352678943055576=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2] fswatch: Add fswatch API
Date: Fri, 20 Jul 2018 11:21:26 -0500
Message-ID: <d3087679-7d5a-b968-3d9e-1876fbe3c40b@gmail.com>
In-Reply-To: <CAOq732KSQ4CLx4xF9rnhuyw4_EPPgK6+MCGh1BUKr60y5OmtDA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3835352678943055576==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

>>> +LIB_EXPORT bool l_fswatch_destroy(struct l_fswatch *watch)
>>
>>
>> I still don't see why this returns bool, what can the caller do if the c=
all
>> fails?
> =

> Not much, but we can't do much either.  We can free the memeory, yes,
> but should we hide the error?

There's no point returning an error out to the user if they can't do =

anything about it, especially if it leaves them powerless from =

reclaiming memory allocated to the watch.

So yes, it is probably better to return void (and maybe print an =

l_error) than to return an error here.

>>> +typedef void (*l_fswatch_destroy_cb_t) (struct l_fswatch *watch,
>>> +                                       void *user_data);
>>
>>
>> Why would this destroy callback signature be different from all others? =
It
>> also precludes us from doing something like:
>>
>> l_fswatch_new("/foo/bar", cb, u, (l_fswatch_destroy_cb_t) l_free);
> =

> Ok, thought it might be useful to pass the watch pointer, it doesn't
> cost us anything and could simplify things for some users.
> =


This is useful for callbacks, but almost never happens for destroy =

callbacks.  In too many cases the destroy callback is just l_free or =

some_structure_destroy(struct some_structure).  So having to come up =

with another function just to have the correct signature is wasteful. =

For the 1-5% usecase where this might be useful, the caller can carry =

the fswatch pointer in the userdata structure itself.

Regards,
-Denis

--===============3835352678943055576==--

