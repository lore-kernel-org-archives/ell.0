Content-Type: multipart/mixed; boundary="===============6634147360807291265=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v3 4/9] gvariant: Fix empty structure/array parsing and
 error check
Date: Fri, 22 Apr 2016 12:30:45 +0200
Message-ID: <CAOq732+JQReatBfaZ2Xd9vszWQO88MBfpOCNGWOU+9Vo_XOPdA@mail.gmail.com>
In-Reply-To: <57198D26.20402@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6634147360807291265==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 22 April 2016 at 04:32, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
>>>
>>>
>>> So I have a nagging bad feeling about this one.  The code of this
>>> function
>>> was copied from _gvariant_valid_signature.  So changing this strongly
>>> implies changing _gvariant_valid_signature as well...
>>
>>
>> So _gvariant_valid_signature is used in two places in ell, one is
>> _gvariant_builder_enter_struct where we want to check for a sequence
>> of dbus types like in a message signature, so yes, it should accept an
>> empty string.  The other place is unit/test-gvariant-util.c where
>> we're trying to validate a single data type signature so the current
>> logic is ok.  I'll change the unit test to do "valid =3D
>> (_gvariant_num_children(test->signature) =3D=3D 1)" instead, and add a
>> struct unit test...
>>
>
> This reminds me.  DBus classic does not accept empty structures.  This is=
 a
> kdbus invention.  Refer to DBus specification:
> "Empty structures are not allowed; there must be at least one type code
> between the parentheses."
>
> I have never been able to come up with a practical utility for empty
> structures for kdbus.  Nevertheless, the signature logic in gvariant-util=
 is
> subtly different from dbus-util.

I see now.  It seems that other than the struct enclosing the gvariant
message body we will never see empty structs, but we need to be able
to parse and build them for this one use case and for completness.
I'll add explicit checks for empty signature before the
_gvariant_valid_signature and _gvariant_num_children calls used with
structs.

Best regards

--===============6634147360807291265==--

