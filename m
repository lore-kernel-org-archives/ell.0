Content-Type: multipart/mixed; boundary="===============2609798048263569846=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v2 3/3] main: Safely free watch_data structures
Date: Wed, 16 Mar 2016 16:24:29 -0700
Message-ID: <alpine.OSX.2.20.1603161550420.19388@mjmartin-mac01.wa.intel.com>
In-Reply-To: <56E9E0D6.3080902@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2609798048263569846==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Wed, 16 Mar 2016, Denis Kenzior wrote:

<snip>

>>>> -    l_free(data);
>>>> +    if (epoll_running) {
>>>> +        /* The epoll events array may point to the same memory as
>>>> +         * 'data', so let the event loop free it later
>>>> +         */
>>>> +        data->callback =3D watch_nop_callback;
>>>> +        l_queue_push_tail(watch_free_list, data);
>>> =

>>> Why don't we do this exactly how the idle events are handled.  E.g.
>>> set a DESTROYED flag and prune the event list after the epoll
>>> processing is complete.
>>> =

>> =

>> In typical use, the idle_list linked list is short or empty and all
>> entries are cleaned up on each event loop iteration -- otherwise you're
>> at 100% CPU. The DESTROYED flag fits well with this, since you plan on
>> visiting every entry in the list anyway.
>> =

>> The assumptions around watch_list are the opposite: big list, infrequent
>> cleanup. watch_list is an array with 128 entries, and you'd have to
>> check all 128 entries on every iteration of the event loop. This could
>
> I'm not sure than walking a 128-entry array would be any slower than call=
ing =

> malloc/free.  I bet it would be faster.  Would be fun to find out.

Ok, I'm getting out my profiler to have some fun.

>
>> be optimized (use a bitmap to flag which ones to free), but there's
>> another problem: watch_list is indexed by an fd which was likely closed
>> by the data->destroy() callback. It's possible for the fd to get re-used
>> and a new watch to be created on that fd even before the data->destroy
>> callback returns.
>
> But then won't you be calling the watch's callback erroneously anyway? If =

> this is a concern, then all new watches need to be postponed until after =
the =

> epoll processing has been completed.
>

No, the stale data is a pointer to watch_data not an fd value. By =

deferring the free we can make sure the event loop is calling something =

valid. The contents of watch_data can be reset however we need to. The =

problem is with pointer values stored in watch_list getting clobbered =

before they get used to free memory.

Thinking about this some more, you could work around the issue by keeping =

the fd open, and postpone both the close() and free(). I don't like that =

idea since the application can reasonably need their file/socket/whatever =

to be closed immediately.

All we're searching for is a way to keep a list of pointers until the =

current event loop iteration is done. Either we defer close() and use the =

existing watch_list, or use some low-overhead growable list. I'm assuming =

we don't want to throw an extra 1k of RAM at it to have a static =

watch_cleanup_list.

>> =

>> =

>> Another proposal: have watch_remove set a global flag that breaks out of
>> the inner "for (n =3D 0; n < nfds; n++)" loop if watch_remove was called,
>> and retries the epoll_wait() without processing idle_list. While it's
>> pretty simple to implement, there are drawbacks:
>
> Lets not do this unless there is no better way.  Re-trapping to the kerne=
l is =

> way more expensive than anything else we're discussing here.

I agree

--
Mat Martineau
Intel OTC


--===============2609798048263569846==--

