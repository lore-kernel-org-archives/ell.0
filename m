Content-Type: multipart/mixed; boundary="===============5631088636679839646=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v3 4/9] gvariant: Fix empty structure/array parsing and
 error check
Date: Fri, 22 Apr 2016 02:01:01 +0200
Message-ID: <CAOq732JELK48Gcw-OEQxzzLXBnkKLDNkuNhMAXoi7R4==+EVnw@mail.gmail.com>
In-Reply-To: <5715380C.8030604@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5631088636679839646==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 18 April 2016 at 21:39, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/14/2016 07:33 PM, Andrew Zaborowski wrote:
>> Allow empty signatures in _gvariant_num_children and check the return
>> value for errors or we might crash.
>> ---
>>   ell/gvariant-util.c | 9 ++++++---
>>   1 file changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/ell/gvariant-util.c b/ell/gvariant-util.c
>> index e07bd2f..791fc41 100644
>> --- a/ell/gvariant-util.c
>> +++ b/ell/gvariant-util.c
>> @@ -201,14 +201,14 @@ int _gvariant_num_children(const char *sig)
>>         if (strlen(sig) > 255)
>>                 return false;
>>
>> -       do {
>> +       while (*s) {
>>                 s =3D validate_next_type(s, &a);
>>
>>                 if (!s)
>>                         return -1;
>>
>>                 num_children +=3D 1;
>> -       } while (*s);
>> +       }
>>
>
> So I have a nagging bad feeling about this one.  The code of this function
> was copied from _gvariant_valid_signature.  So changing this strongly
> implies changing _gvariant_valid_signature as well...

So _gvariant_valid_signature is used in two places in ell, one is
_gvariant_builder_enter_struct where we want to check for a sequence
of dbus types like in a message signature, so yes, it should accept an
empty string.  The other place is unit/test-gvariant-util.c where
we're trying to validate a single data type signature so the current
logic is ok.  I'll change the unit test to do "valid =3D
(_gvariant_num_children(test->signature) =3D=3D 1)" instead, and add a
struct unit test...

>
> Passing in "" won't crash this function, so where do we crash?

The crash referred to the lack of error check.  This function returns
-1 and we assign it to an unsigned variable below, then use the value
to allocate memory and as a loop limit.

>
>>         return num_children;
>>   }
>> @@ -374,7 +374,7 @@ static bool gvariant_iter_init_internal(struct
>> l_dbus_message_iter *iter,
>>                 unsigned int alignment : 4;
>>                 size_t end;             /* Index past the end of the type
>> */
>>         } *children;
>> -       uint8_t n_children;
>> +       int n_children;
>>
>>         if (sig_end) {
>>                 size_t len =3D sig_end - sig_start;
>> @@ -392,6 +392,9 @@ static bool gvariant_iter_init_internal(struct
>> l_dbus_message_iter *iter,
>>         iter->pos =3D 0;
>>
>>         n_children =3D _gvariant_num_children(subsig);
>> +       if (n_children < 0)
>> +               return false;
>> +
>>         children =3D l_new(struct gvariant_type_info, n_children);
>
>
> So why would we be allocating a zero-sized array?  Do we need to special
> case this somehow?

The 0-sized malloc doesn't hurt and lets us avoid a few conditional
blocks, so probably it's ok?

>
> Can I get some unit test data to play with?

Ok, good idea.

Best regards

--===============5631088636679839646==--

