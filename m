Content-Type: multipart/mixed; boundary="===============4669314531630873699=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] dbus: Fix subpath comparisons in object tree walk
Date: Thu, 16 Aug 2018 03:12:00 +0200
Message-ID: <CAOq732+uFUVoOAreEQGVRaMemqohC=ytTsBzf6wXOox02CNkXw@mail.gmail.com>
In-Reply-To: <b5937d5d-94aa-a665-fbe8-8cc3685255ab@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4669314531630873699==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 15 August 2018 at 22:44, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
> On 08/15/2018 02:22 PM, Andrew Zaborowski wrote:
>> On 15 August 2018 at 18:55, Denis Kenzior <denkenz@gmail.com> wrote:
>>> Also can we have a unit test please?
>>
>> It's unlikely that this problem comes back in the exact same form, but
>> ok, let's add a test that registers thousands of objects with random
>> paths including prefixes of existing paths etc.
>>
>
> Not sure that random paths are good.  We need something that is
> repeatable...

Yes, I was thinking of hardcoding the seed for the random sequence
using srandom+random -- although it's not clear to me that it's
guaranteed to generate the same sequence across all implementations,
srand48+lrand48 on the other hand does seem to guarantee this.

>
>>>
>>>> ---
>>>>    ell/dbus-service.c | 6 ++++--
>>>>    1 file changed, 4 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/ell/dbus-service.c b/ell/dbus-service.c
>>>> index 43c7a5c..cd9d402 100644
>>>> --- a/ell/dbus-service.c
>>>> +++ b/ell/dbus-service.c
>>>> @@ -649,7 +649,8 @@ static struct object_node *makepath_recurse(struct
>>>> object_node *node,
>>>>          child =3D node->children;
>>>>          while (child) {
>>>> -               if (!strncmp(child->subpath, path, end - path))
>>>> +               if (!memcmp(child->subpath, path, end - path) &&
>>>> +                               child->subpath[end - path] =3D=3D '\0')
>>>
>>>
>>>
>>> Hmm, is memcmp safe here?  What if child->subpath is smaller than end -
>>> path
>>> bytes?  Might be a good idea to make a unit test specifically for this
>>> and
>>> make sure ASAN/valgrind are happy.
>>
>>
>> If child->subpath is shorter the memcmp will stop at the \0 character
>> because "path" will have a different character at the same position
>> but I'll make sure valgrind is happy with the test.
>>
>
> FYI, I don't think memcmp works this way:
>
> #include <stdio.h>
> #include <string.h>
>
> int main(int argc, char **argv)
> {
>         char *str1 =3D "foo";
>         char *str2 =3D "foobar";
>
>         return memcmp(str1, str2, strlen(str2));
> }
>
> gcc -O3 -fsanitize=3Dundefined -fsanitize=3Daddress -o foo foo.c
>
> denkenz(a)localhost ~ $ ./foo
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> =3D=3D2423=3D=3DERROR: AddressSanitizer: global-buffer-overflow on address
> 0x557ae18f2aa4 at pc 0x7f8fb0838cc4 bp 0x7ffc3b8f5e40 sp 0x7ffc3b8f55e8
> READ of size 6 at 0x557ae18f2aa4 thread T0
>     #0 0x7f8fb0838cc3
> (/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/libasan.so.4+0xafcc3)
>     #1 0x7f8faf6c3ed9 in __libc_start_main (/lib64/libc.so.6+0x20ed9)
>     #2 0x557ae18f28c9 in _start (/home/denkenz/foo+0x8c9)

Ok, then let me go back to strncmp although a simple local
implementation of memcmp might be faster here.

I wasn't able to run the unit tests with ASAN so far and valgrind had
no complaints.

Best regards

--===============4669314531630873699==--

