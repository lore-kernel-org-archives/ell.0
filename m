Content-Type: multipart/mixed; boundary="===============0328797723820653270=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 4/4] genl: Fix termination of name strings
Date: Tue, 26 Sep 2017 12:30:51 -0700
Message-ID: <alpine.OSX.2.21.1709261135320.17660@blarson-mobl.amr.corp.intel.com>
In-Reply-To: <f023badd-cfa8-6309-c1fb-0fd60995855a@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0328797723820653270==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


On Mon, 25 Sep 2017, Denis Kenzior wrote:

> Hi Mat,
>
>>>> -=C2=A0=C2=A0=C2=A0 strncpy(family->name, name, GENL_NAMSIZ); >>> + =

>>>> l_strlcpy(family->name, name, GENL_NAMSIZ);
>>> =

>>> It would seem that l_genl_family_new should sanitize the name.  There's=
 no =

>>> point in truncating a name silently and trying to use it afterwards jus=
t =

>>> to fail spectacularly anyway.
>> =

>> How about checking for truncation here in family_alloc using the return =

>> value of l_strlcpy? family_alloc could return NULL, and l_genl_family_ne=
w =

>> already knows what to do with that.
>> =

>
> But then we're allocating a family object, memsetting it, etc unnecessari=
ly, =

> no?

Yes, in the very rare case of a programmer error during development. Are =

we that worried about the microsecond-level efficiency of a very rarely =

executed error path?

If family_alloc uses strcpy, then you depend on reviewers giving =

family_alloc the same level of scrutiny they do strcpy. You can't depend =

on static analysis to catch it in the future after flagging it as "ok" =

now.

If family_alloc uses l_strlcpy, then the common case gets an extra call to =

strlen.

>>>
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 family->op_list =3D l_queue=
_new();
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 family->mcast_list =3D l_queue_new();
>>>> @@ -232,7 +232,7 @@ static void family_add_mcast(struct l_genl_family =

>>>> *family, const char *name,
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mcast =3D l_new(struct genl=
_mcast, 1);
>>>> =C2=A0 -=C2=A0=C2=A0=C2=A0 strncpy(mcast->name, name, GENL_NAMSIZ);
>>>> +=C2=A0=C2=A0=C2=A0 l_strlcpy(mcast->name, name, GENL_NAMSIZ);
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mcast->id =3D id;
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mcast->users =3D 0;
>>>> =C2=A0 @@ -1047,7 +1047,7 @@ static void get_family_callback(struct l_=
genl_msg =

>>>> *msg, void *user_data)
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 family->id =3D *((uint16_t *) data);
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 break;
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 case CTRL_ATTR_=
FAMILY_NAME:
>>>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 st=
rncpy(family->name, data, GENL_NAMSIZ);
>>>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 l_=
strlcpy(family->name, data, GENL_NAMSIZ);
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 break;
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 case CTRL_ATTR_=
VERSION:
>>>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 family->version =3D *((uint32_t *) data);
>>>> =

>>> =

>>> The other two are not called with user input but get their values from =
the =

>>> kernel, no?
>> =

>> Mostly (one use of family_add_mcast uses a hard-coded string). The curre=
nt =

>> use of strncpy is incorrect no matter where the name comes from.
>> =

>
> why is it incorrect?  We're getting the name from the kernel and copying =
it =

> into our own data structure.  If the kernel uses GENL_NAMSIZ max-size =

> buffers, then using strncpy is just fine, no?

It's incorrect because you aren't guaranteed a null-terminated destination =

buffer. It would be correct to use strncpy with GENL_NAMSIZ-1 and write a =

'\0' to to the end of the buffer if it's not known to be zeroed.

>
> At least I don't see how strlcpy is saving you here.  If you want to be =

> paranoid, you'd be taking the tlv length value into account as well.

It's making the current code work as intended.

strlcpy guarantees two things: that you don't write past the end of your =

destination buffer (corrupting other data) while copying, and that the =

destination buffer is null-terminated after the copy. strncpy does the =

former, but not the latter.

--
Mat Martineau
Intel OTC

--===============0328797723820653270==--

