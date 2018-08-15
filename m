Content-Type: multipart/mixed; boundary="===============3575936694206261975=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: Fix subpath comparisons in object tree walk
Date: Wed, 15 Aug 2018 15:44:03 -0500
Message-ID: <b5937d5d-94aa-a665-fbe8-8cc3685255ab@gmail.com>
In-Reply-To: <CAOq732+fDABoA8f-zG8YL85WrEMGv-krKRUQfOnfGrBua5aedA@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3575936694206261975==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/15/2018 02:22 PM, Andrew Zaborowski wrote:
> Hi Denis,
> =

> On 15 August 2018 at 18:55, Denis Kenzior <denkenz@gmail.com> wrote:
>> On 08/14/2018 11:02 PM, Andrew Zaborowski wrote:
>>> By only using strncmp(child->subpath, path, len) we'd only check that
>>> child->subpath had path as its prefix in makepath_recurse.  As a
>>> result, if an object at /ab was added first and at /a second, the
>>> second object would not get a new node created and strangely none of
>>> our tests or users have caught this.
>>
>>
>> Funny.  How'd you catch this?
> =

> I think we didn't see this in IWD because our adapters and devices are
> registered with numerical paths in growing order, and networks have
> one of the _open, _psk, _8021x suffixes.  Now that we have known
> networks and adapters at the same level in the tree registering
> /6f322d574c414e3639_psk followed by /6 would cause problems.
> =


Right.  So we might need to hot-fix this soon.

>>
>> Also can we have a unit test please?
> =

> It's unlikely that this problem comes back in the exact same form, but
> ok, let's add a test that registers thousands of objects with random
> paths including prefixes of existing paths etc.
> =


Not sure that random paths are good.  We need something that is =

repeatable...

>>
>>> ---
>>>    ell/dbus-service.c | 6 ++++--
>>>    1 file changed, 4 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/ell/dbus-service.c b/ell/dbus-service.c
>>> index 43c7a5c..cd9d402 100644
>>> --- a/ell/dbus-service.c
>>> +++ b/ell/dbus-service.c
>>> @@ -649,7 +649,8 @@ static struct object_node *makepath_recurse(struct
>>> object_node *node,
>>>          child =3D node->children;
>>>          while (child) {
>>> -               if (!strncmp(child->subpath, path, end - path))
>>> +               if (!memcmp(child->subpath, path, end - path) &&
>>> +                               child->subpath[end - path] =3D=3D '\0')
>>
>>
>> Hmm, is memcmp safe here?  What if child->subpath is smaller than end - =
path
>> bytes?  Might be a good idea to make a unit test specifically for this a=
nd
>> make sure ASAN/valgrind are happy.
> =

> If child->subpath is shorter the memcmp will stop at the \0 character
> because "path" will have a different character at the same position
> but I'll make sure valgrind is happy with the test.
> =


FYI, I don't think memcmp works this way:

#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
         char *str1 =3D "foo";
         char *str2 =3D "foobar";

         return memcmp(str1, str2, strlen(str2));
}

gcc -O3 -fsanitize=3Dundefined -fsanitize=3Daddress -o foo foo.c

denkenz(a)localhost ~ $ ./foo
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=3D=3D2423=3D=3DERROR: AddressSanitizer: global-buffer-overflow on address =

0x557ae18f2aa4 at pc 0x7f8fb0838cc4 bp 0x7ffc3b8f5e40 sp 0x7ffc3b8f55e8
READ of size 6 at 0x557ae18f2aa4 thread T0
     #0 0x7f8fb0838cc3 =

(/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/libasan.so.4+0xafcc3)
     #1 0x7f8faf6c3ed9 in __libc_start_main (/lib64/libc.so.6+0x20ed9)
     #2 0x557ae18f28c9 in _start (/home/denkenz/foo+0x8c9)

0x557ae18f2aa4 is located 0 bytes to the right of global variable =

'*.LC1' defined in 'foo.c' (0x557ae18f2aa0) of size 4
   '*.LC1' is ascii string 'foo'
SUMMARY: AddressSanitizer: global-buffer-overflow =

(/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/libasan.so.4+0xafcc3)
Shadow bytes around the buggy address:
   0x0aafdc316500: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
   0x0aafdc316510: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
   0x0aafdc316520: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
   0x0aafdc316530: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
   0x0aafdc316540: 00 00 00 00 00 00 00 00 00 00 00 00 07 f9 f9 f9
=3D>0x0aafdc316550: f9 f9 f9 f9[04]f9 f9 f9 f9 f9 f9 f9 00 00 00 00
   0x0aafdc316560: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
   0x0aafdc316570: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
   0x0aafdc316580: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
   0x0aafdc316590: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
   0x0aafdc3165a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
Shadow byte legend (one shadow byte represents 8 application bytes):
   Addressable:           00
   Partially addressable: 01 02 03 04 05 06 07
   Heap left redzone:       fa
   Freed heap region:       fd
   Stack left redzone:      f1
   Stack mid redzone:       f2
   Stack right redzone:     f3
   Stack after return:      f5
   Stack use after scope:   f8
   Global redzone:          f9
   Global init order:       f6
   Poisoned by user:        f7
   Container overflow:      fc
   Array cookie:            ac
   Intra object redzone:    bb
   ASan internal:           fe
   Left alloca redzone:     ca
   Right alloca redzone:    cb
=3D=3D2423=3D=3DABORTING

Regards,
-Denis

--===============3575936694206261975==--

