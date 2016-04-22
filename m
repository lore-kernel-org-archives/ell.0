Content-Type: multipart/mixed; boundary="===============7446965791373403043=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 4/9] gvariant: Fix empty structure/array parsing and
 error check
Date: Thu, 21 Apr 2016 21:06:42 -0500
Message-ID: <57198732.8090102@gmail.com>
In-Reply-To: <CAOq732+8sMxpAz6TrSAxUWCz142HZB7Y7jc7Bf3ShQSmXEfMag@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7446965791373403043==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Andrew,

 >>> So I have a nagging bad feeling about this one.  The code of this =

function
>>> was copied from _gvariant_valid_signature.  So changing this strongly
>>> implies changing _gvariant_valid_signature as well...
>>
>> So _gvariant_valid_signature is used in two places in ell, one is
>> _gvariant_builder_enter_struct where we want to check for a sequence
>> of dbus types like in a message signature, so yes, it should accept an
>> empty string.  The other place is unit/test-gvariant-util.c where
>> we're trying to validate a single data type signature so the current
>> logic is ok.  I'll change the unit test to do "valid =3D
>> (_gvariant_num_children(test->signature) =3D=3D 1)" instead, and add a
>> struct unit test...
>
> I was wrong here, apparently the unit test also tests for "message
> signature" type of signatures.  Why are we then treating "" as
> invalid?
>

In theory treating "" as invalid is intended behavior.  See how =

_dbus_valid_signature is used.  However, I don't think we ever tested =

empty structs, so feel free to change this.

Regards,
-Denis

--===============7446965791373403043==--

