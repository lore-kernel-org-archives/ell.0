Content-Type: multipart/mixed; boundary="===============4150568902027237068=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 8/9] hashmap: Add support to finding an element from hash
Date: Thu, 12 Feb 2015 18:19:03 -0600
Message-ID: <54DD42F7.5030102@gmail.com>
In-Reply-To: <1423730142.4196.14.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4150568902027237068==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/12/2015 02:35 AM, Jukka Rissanen wrote:
> Hi Denis,
>
> On ti, 2015-02-10 at 16:42 +0200, Jukka Rissanen wrote:
>> Add new function l_hashmap_find() which is similar to foreach.
>> The find will start to call a user supplied function for every
>> entry in hashmap. If user function returns true, then the find
>> will return and not call remaining hash elements.
>> ---
>
> Just wanted to ask are you ok with func? At the moment there is no
> function to traverse the hash, other than the foreach variant and it is
> very sub-optimal as it will traverse the whole hash even if such a thing
> is not needed by the caller. Even better option would be to change the
> return parameter of foreach callback to return bool so we could do with
> only one traversing function.
>

I'm not totally against it, so I might be convinced this is useful. =

However, I really have to wonder why a hashmap is being used as a
glorified linked list?  Whats the target use case?

<snip>

>>   							void *user_data);
>> +typedef bool (*l_hashmap_find_func_t) (const void *key, void *value,
>> +							void *user_data);
>>   typedef void (*l_hashmap_destroy_func_t) (void *value);
>>   typedef unsigned int (*l_hashmap_hash_func_t) (const void *p);
>>   typedef int (*l_hashmap_compare_func_t) (const void *a, const void *b);
>> @@ -70,6 +72,9 @@ void *l_hashmap_lookup(struct l_hashmap *hashmap, cons=
t void *key);
>>   void l_hashmap_foreach(struct l_hashmap *hashmap,
>>   			l_hashmap_foreach_func_t function, void *user_data);
>>
>> +void l_hashmap_find(struct l_hashmap *hashmap,
>> +			l_hashmap_find_func_t function, void *user_data);
>> +

If we're going to do this, then the signature should mimic =

l_hashmap_lookup.  e.g.

void *l_hashmap_find(struct l_hashmap *hashmap,
			l_hashmap_find_func_t function,
			void *user_data);

Regards,
-Denis

--===============4150568902027237068==--

