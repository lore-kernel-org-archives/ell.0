Content-Type: multipart/mixed; boundary="===============1346223650826233218=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Warn-to-error on -Werror=cast-align
Date: Tue, 07 Jan 2020 08:26:05 +0100
Message-ID: <48272766-78EE-4DBA-A8C0-8C6C68959005@holtmann.org>
In-Reply-To: <16492c82999ed2dcc5a03e9af15137970edc3faa.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1346223650826233218==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

>>> (...)
>>> ell/util.h:40:3: error: cast increases required alignment of target typ=
e [-Werror=3Dcast-align]
>>>   (type *)((char *) __mptr - offsetof(type, member)); \
>>>   ^
>>> ell/dbus.c:582:3: note: in expansion of macro =E2=80=98l_container_of=
=E2=80=99
>>>   l_container_of(dbus, struct l_dbus_classic, super);
>>>   ^~~~~~~~~~~~~~
>> =

>> FWIW, I've encountered that on iMX.6 as well. I've fixed that with:
>> =

>> diff --git a/ell/util.h b/ell/util.h
>> index 4f20ef0..fe7c7e2 100644
>> --- a/ell/util.h
>> +++ b/ell/util.h
>> @@ -37,7 +37,7 @@ extern "C" {
>> =

>> #define l_container_of(ptr, type, member) ({                           \
>>                const __typeof__(((type *) 0)->member) *__mptr =3D (ptr);=
 \
>> -               (type *)((char *) __mptr - offsetof(type, member));     \
>> +               (type *)(void *)((char *) __mptr - offsetof(type, member=
));     \
>>        })
> =

> =

> Any opinion on this change?  It is causing us build fails on some platfor=
ms (including Raspberry PI 4).
> =

> I have not yet had a chance to run the battery of unit tests with this ch=
ange in ELL, and am not even really
> sure of the if this warning means that there could be some unforseen impa=
ct.
> =

> Otherwise, perhaps we should just create an ELL patch that makes clears u=
p these warnings (Micha=C5=82?).
> =

> If this is done, we should make sure it gets all of them, and not just th=
e dbus.c instances.

I am fine with this patch, but I am also not the expert in memory layout of=
 structs for different architectures. So if we do not encounter issues on x=
86 and ARM (I will test PowerPC later) then I am fine with changing this.

Regards

Marcel

--===============1346223650826233218==--

