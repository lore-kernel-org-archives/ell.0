Content-Type: multipart/mixed; boundary="===============2723611815578939116=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 4/9] gvariant: Fix empty structure/array parsing and
 error check
Date: Thu, 21 Apr 2016 21:32:06 -0500
Message-ID: <57198D26.20402@gmail.com>
In-Reply-To: <CAOq732JELK48Gcw-OEQxzzLXBnkKLDNkuNhMAXoi7R4==+EVnw@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2723611815578939116==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

 >>
>> So I have a nagging bad feeling about this one.  The code of this functi=
on
>> was copied from _gvariant_valid_signature.  So changing this strongly
>> implies changing _gvariant_valid_signature as well...
>
> So _gvariant_valid_signature is used in two places in ell, one is
> _gvariant_builder_enter_struct where we want to check for a sequence
> of dbus types like in a message signature, so yes, it should accept an
> empty string.  The other place is unit/test-gvariant-util.c where
> we're trying to validate a single data type signature so the current
> logic is ok.  I'll change the unit test to do "valid =3D
> (_gvariant_num_children(test->signature) =3D=3D 1)" instead, and add a
> struct unit test...
>

This reminds me.  DBus classic does not accept empty structures.  This =

is a kdbus invention.  Refer to DBus specification:
"Empty structures are not allowed; there must be at least one type code =

between the parentheses."

I have never been able to come up with a practical utility for empty =

structures for kdbus.  Nevertheless, the signature logic in =

gvariant-util is subtly different from dbus-util.

>>
>> So why would we be allocating a zero-sized array?  Do we need to special
>> case this somehow?
>
> The 0-sized malloc doesn't hurt and lets us avoid a few conditional
> blocks, so probably it's ok?
>

Generally I find that weird, but lets see how it looks.

Regards,
-Denis


--===============2723611815578939116==--

