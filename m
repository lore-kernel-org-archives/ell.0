Content-Type: multipart/mixed; boundary="===============4102805834338782181=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/4] genl: Fix termination of name strings
Date: Mon, 25 Sep 2017 18:25:46 -0500
Message-ID: <f023badd-cfa8-6309-c1fb-0fd60995855a@gmail.com>
In-Reply-To: <alpine.OSX.2.21.1709251527000.10397@mjmartin-mac01.sea.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4102805834338782181==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

>>> -=C2=A0=C2=A0=C2=A0 strncpy(family->name, name, GENL_NAMSIZ); >>> +=C2=
=A0=C2=A0=C2=A0 l_strlcpy(family->name, name, GENL_NAMSIZ);
>>
>> It would seem that l_genl_family_new should sanitize the name.  =

>> There's no point in truncating a name silently and trying to use it =

>> afterwards just to fail spectacularly anyway.
> =

> How about checking for truncation here in family_alloc using the return =

> value of l_strlcpy? family_alloc could return NULL, and =

> l_genl_family_new already knows what to do with that.
> =


But then we're allocating a family object, memsetting it, etc =

unnecessarily, no?

>>
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 family->op_list =3D l_queue_=
new();
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 family->mcast_list =3D l_queue_new();
>>> @@ -232,7 +232,7 @@ static void family_add_mcast(struct l_genl_family =

>>> *family, const char *name,
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mcast =3D l_new(struct genl_=
mcast, 1);
>>> =C2=A0 -=C2=A0=C2=A0=C2=A0 strncpy(mcast->name, name, GENL_NAMSIZ);
>>> +=C2=A0=C2=A0=C2=A0 l_strlcpy(mcast->name, name, GENL_NAMSIZ);
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mcast->id =3D id;
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mcast->users =3D 0;
>>> =C2=A0 @@ -1047,7 +1047,7 @@ static void get_family_callback(struct =

>>> l_genl_msg *msg, void *user_data)
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 family->id =3D *((uint16_t *) data);
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 break;
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 case CTRL_ATTR_F=
AMILY_NAME:
>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 str=
ncpy(family->name, data, GENL_NAMSIZ);
>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 l_s=
trlcpy(family->name, data, GENL_NAMSIZ);
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 break;
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 case CTRL_ATTR_V=
ERSION:
>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 family->version =3D *((uint32_t *) data);
>>>
>>
>> The other two are not called with user input but get their values from =

>> the kernel, no?
> =

> Mostly (one use of family_add_mcast uses a hard-coded string). The =

> current use of strncpy is incorrect no matter where the name comes from.
> =


why is it incorrect?  We're getting the name from the kernel and copying =

it into our own data structure.  If the kernel uses GENL_NAMSIZ max-size =

buffers, then using strncpy is just fine, no?

At least I don't see how strlcpy is saving you here.  If you want to be =

paranoid, you'd be taking the tlv length value into account as well.

Regards,
-Denis

--===============4102805834338782181==--

