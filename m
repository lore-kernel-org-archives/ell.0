Content-Type: multipart/mixed; boundary="===============7699238871099967202=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH] dbus: Fix subpath comparisons in object tree walk
Date: Wed, 15 Aug 2018 21:22:54 +0200
Message-ID: <CAOq732+fDABoA8f-zG8YL85WrEMGv-krKRUQfOnfGrBua5aedA@mail.gmail.com>
In-Reply-To: <9c14ea71-94ed-70cc-3ff1-73c39bbec2de@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7699238871099967202==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 15 August 2018 at 18:55, Denis Kenzior <denkenz@gmail.com> wrote:
> On 08/14/2018 11:02 PM, Andrew Zaborowski wrote:
>> By only using strncmp(child->subpath, path, len) we'd only check that
>> child->subpath had path as its prefix in makepath_recurse.  As a
>> result, if an object at /ab was added first and at /a second, the
>> second object would not get a new node created and strangely none of
>> our tests or users have caught this.
>
>
> Funny.  How'd you catch this?

I think we didn't see this in IWD because our adapters and devices are
registered with numerical paths in growing order, and networks have
one of the _open, _psk, _8021x suffixes.  Now that we have known
networks and adapters at the same level in the tree registering
/6f322d574c414e3639_psk followed by /6 would cause problems.

>
> Also can we have a unit test please?

It's unlikely that this problem comes back in the exact same form, but
ok, let's add a test that registers thousands of objects with random
paths including prefixes of existing paths etc.

>
>> ---
>>   ell/dbus-service.c | 6 ++++--
>>   1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/ell/dbus-service.c b/ell/dbus-service.c
>> index 43c7a5c..cd9d402 100644
>> --- a/ell/dbus-service.c
>> +++ b/ell/dbus-service.c
>> @@ -649,7 +649,8 @@ static struct object_node *makepath_recurse(struct
>> object_node *node,
>>         child =3D node->children;
>>         while (child) {
>> -               if (!strncmp(child->subpath, path, end - path))
>> +               if (!memcmp(child->subpath, path, end - path) &&
>> +                               child->subpath[end - path] =3D=3D '\0')
>
>
> Hmm, is memcmp safe here?  What if child->subpath is smaller than end - p=
ath
> bytes?  Might be a good idea to make a unit test specifically for this and
> make sure ASAN/valgrind are happy.

If child->subpath is shorter the memcmp will stop at the \0 character
because "path" will have a different character at the same position
but I'll make sure valgrind is happy with the test.

Best regards

--===============7699238871099967202==--

