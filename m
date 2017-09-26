Content-Type: multipart/mixed; boundary="===============1334449801182778901=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 4/4] genl: Fix termination of name strings
Date: Tue, 26 Sep 2017 15:08:13 -0500
Message-ID: <d09a4ac1-d7d8-7268-acff-0580f19237df@gmail.com>
In-Reply-To: <alpine.OSX.2.21.1709261135320.17660@blarson-mobl.amr.corp.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1334449801182778901==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,
> =

> Yes, in the very rare case of a programmer error during development. Are =

> we that worried about the microsecond-level efficiency of a very rarely =

> executed error path?

Not really about performance, no.  But readability wise its far easier =

to just error out early than tear things down.

In this particular case it doesn't matter much.  And by the way =

family_alloc result isn't checked inside l_genl_new...

> =

> If family_alloc uses strcpy, then you depend on reviewers giving =

> family_alloc the same level of scrutiny they do strcpy. You can't depend =

> on static analysis to catch it in the future after flagging it as "ok" no=
w.
> =

> If family_alloc uses l_strlcpy, then the common case gets an extra call =

> to strlen.

Fundamentally this feels like a hammer seeking a nail.  Can we make the =

tool work for us and not the other way around?  If the tool can't figure =

out that the string length has been sanitized previously, what good is it?

>>
>> why is it incorrect?=C2=A0 We're getting the name from the kernel and =

>> copying it into our own data structure.=C2=A0 If the kernel uses =

>> GENL_NAMSIZ max-size buffers, then using strncpy is just fine, no?
> =

> It's incorrect because you aren't guaranteed a null-terminated =

> destination buffer. It would be correct to use strncpy with =

> GENL_NAMSIZ-1 and write a '\0' to to the end of the buffer if it's not =

> known to be zeroed.
> =


So the kernel is misbehaving...

>>
>> At least I don't see how strlcpy is saving you here.=C2=A0 If you want t=
o =

>> be paranoid, you'd be taking the tlv length value into account as well.
> =

> It's making the current code work as intended.
> =


If you don't trust the kernel and we really want to be paranoid, we =

should use the length value returned by l_genl_attr_next and check that =

its <=3D GENL_NAMESIZ, etc.

Regards,
-Denis

--===============1334449801182778901==--

