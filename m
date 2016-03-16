Content-Type: multipart/mixed; boundary="===============3247838031142185618=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH v2 3/3] main: Safely free watch_data structures
Date: Wed, 16 Mar 2016 15:10:15 -0700
Message-ID: <alpine.OSX.2.20.1603161315580.13595@mjmartin-mac01.local>
In-Reply-To: <56E9BE4A.5030905@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3247838031142185618==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Wed, 16 Mar 2016, Denis Kenzior wrote:

> Hi Mat,
>
> On 03/16/2016 03:01 PM, Mat Martineau wrote:
>> The race condition test in test-main exposed a case where the events
>> array returned by epoll_wait could have a stale watch_data
>> pointer. This triggered a use-after-free error that was reported by
>> the address sanitizer (./configure --enable-asan).
>> =

>> When the event loop is running, watch_remove now queues the watch_data
>> structure to be freed later. The watch_data callback is modified so
>> that a safe function is executed if the event loop attempts a callback
>> on a pending removed watch. Any queued watch_data structures are freed
>> at the end of each event loop iteration.
>> ---
>>   ell/main.c | 28 +++++++++++++++++++++++++++-
>>   1 file changed, 27 insertions(+), 1 deletion(-)
>> =

>> diff --git a/ell/main.c b/ell/main.c
>> index f8fa4ac..135a6da 100644
>> --- a/ell/main.c
>> +++ b/ell/main.c
>> @@ -56,6 +56,7 @@ static int idle_id;
>>   static int exit_status =3D EXIT_FAILURE;
>>
>>   static struct l_queue *idle_list;
>> +static struct l_queue *watch_free_list;
>>
>>   struct watch_data {
>>   	int fd;
>> @@ -101,6 +102,10 @@ static inline bool __attribute__ ((always_inline)) =

>> create_epoll(void)
>>
>>   	idle_id =3D 0;
>> =

>> +	watch_free_list =3D l_queue_new();
>
> l_queue_new cannot fail.

Ok. I will remove the similar check for idle_list just above this (before =

the patch context) in a separate patch.

>
>> +	if (!watch_free_list)
>> +		goto free_idle_list;
>> +
>>   	watch_entries =3D DEFAULT_WATCH_ENTRIES;
>>
>>   	for (i =3D 0; i < watch_entries; i++)
>> @@ -108,6 +113,10 @@ static inline bool __attribute__ ((always_inline)) =

>> create_epoll(void)
>>
>>   	return true;
>> =

>> +free_idle_list:
>> +	l_queue_destroy(idle_list, NULL);
>> +	idle_list =3D NULL;
>> +
>>   free_watch_list:
>>   	free(watch_list);
>>   	watch_list =3D NULL;
>> @@ -190,6 +199,11 @@ int watch_modify(int fd, uint32_t events, bool forc=
e)
>>   	return 0;
>>   }
>> =

>> +static void watch_nop_callback(int fd, uint32_t events, void *user_data)
>> +{
>> +	return;
>> +}
>> +
>>   int watch_remove(int fd)
>>   {
>>   	struct watch_data *data;
>> @@ -212,7 +226,15 @@ int watch_remove(int fd)
>>   	if (data->destroy)
>>   		data->destroy(data->user_data);
>> =

>> -	l_free(data);
>> +	if (epoll_running) {
>> +		/* The epoll events array may point to the same memory as
>> +		 * 'data', so let the event loop free it later
>> +		 */
>> +		data->callback =3D watch_nop_callback;
>> +		l_queue_push_tail(watch_free_list, data);
>
> Why don't we do this exactly how the idle events are handled.  E.g. set a =

> DESTROYED flag and prune the event list after the epoll processing is =

> complete.
>

In typical use, the idle_list linked list is short or empty and all =

entries are cleaned up on each event loop iteration -- otherwise you're at =

100% CPU. The DESTROYED flag fits well with this, since you plan on =

visiting every entry in the list anyway.

The assumptions around watch_list are the opposite: big list, infrequent =

cleanup. watch_list is an array with 128 entries, and you'd have to check =

all 128 entries on every iteration of the event loop. This could be =

optimized (use a bitmap to flag which ones to free), but there's another =

problem: watch_list is indexed by an fd which was likely closed by the =

data->destroy() callback. It's possible for the fd to get re-used and a =

new watch to be created on that fd even before the data->destroy callback =

returns.


Another proposal: have watch_remove set a global flag that breaks out of =

the inner "for (n =3D 0; n < nfds; n++)" loop if watch_remove was called, =

and retries the epoll_wait() without processing idle_list. While it's =

pretty simple to implement, there are drawbacks:

1. Could change the event handler sequence depending on how epoll_wait() =

handles event ordering between calls. There don't seem to be any =

guarantees by the syscall with regard to ordering in the returned array. =

The current implementation will handle all existing events before calling =

epoll_wait() again, so there's no chance that events created due to =

actions in one iteration of the event loop will get handled ahead of older =

events. This seems like a useful property to preserve since it prevents =

starvation.

2. The epoll_wait call isn't cheap either, but would only be called one =

extra time for each event involving a watch_remove. The current patch has =

the overhead of one malloc/free pair per removed watch.


Which approach sounds better@this point? Or is there another flavor of =

flag-and-prune that would be workable?

>> +	} else {
>> +		l_free(data);
>> +	}
>>
>>   	return err;
>>   }
>> @@ -352,6 +374,7 @@ LIB_EXPORT int l_main_run(void)
>>
>>   		l_queue_foreach(idle_list, idle_dispatch, NULL);
>>   		l_queue_foreach_remove(idle_list, idle_prune, NULL);
>> +		l_queue_clear(watch_free_list, l_free);
>>   	}
>>
>>   	for (i =3D 0; i < watch_entries; i++) {
>> @@ -378,6 +401,9 @@ LIB_EXPORT int l_main_run(void)
>>   	l_queue_destroy(idle_list, idle_destroy);
>>   	idle_list =3D NULL;
>> =

>> +	l_queue_destroy(watch_free_list, l_free);
>> +	watch_free_list =3D NULL;
>> +
>>   	epoll_running =3D false;
>>
>>   	close(epoll_fd);
>>


--
Mat Martineau
Intel OTC


--===============3247838031142185618==--

