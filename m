Content-Type: multipart/mixed; boundary="===============9129522162547303851=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v4 1/5] ecc: moved ecc from IWD into ell
Date: Mon, 10 Dec 2018 12:19:05 +0100
Message-ID: <FAE891F7-EA35-4A4E-B6E3-9AD9BB029057@holtmann.org>
In-Reply-To: <2047423e-94cb-296a-571a-ea3eec738568@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============9129522162547303851==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

>> so I am not a big fan of these nested directory structures in the first =
place and especially not a big fan of the 3rdparty thing.
>> If we modify the source files to make them compile or use our internal d=
efinitions, then it is no longer external code. If it is code that purely e=
xternal, we can do ell/ecc-external.[ch] or something like that. We can do =
the same as we do in ell/siphash.c where we take the code as ELL code and a=
cknowledge the original code and its origin.
> =

> So I'd like to separate as much as possible the original 3rd party code f=
rom what we ended up adding (which was quite a bit) to it in order to suppo=
rt EAP-PWD/SAE/OWE.  I want to make it easier to update this file from exte=
rnal sources if we need to (e.g. as vulnerabilities / bugs are potentially =
discovered and fixed.)  In iwd we created this hodge-podge of the original =
3rdparty code + our additions and I don't think that was a good idea.
> =

> If you want to keep it in ecc-external.c, that would be fine.  3rdparty s=
ubdirectory seems clearer, but whichever accomplishes the above is fine.

so I have a test tree that uses the latest micro-ecc repository as base. If=
 we want to have an easy path to pull in updates from upstream, then this n=
eeds to be uECC.[ch] and friends. However I need to send patches to micro-e=
cc since it will not build as simple as their README might indicate. Minor =
details, but they didn=E2=80=99t really test it enough.

>> Lets go back one step and tell me what this is based on? Is this the old=
 BlueZ code or is this the micro-ecc?
> =

> The code was from BlueZ's version of ecc with slight modifications.  And =
that is another issue.  The goal of this is to standardize this across the =
projects.

That is what I thought. And that code is an old snapshot with only P-256 cu=
rve in mind.

>> Do we need such a rich API? Can we start with a smaller one for things w=
e actually need from it.
> =

> This is about as minimal as we can get for what iwd needs for SAE/OWE/PWD.

Do we want the ECC curve really as struct? Or are we going to have an enum =
or have them as pre-defined exported symbols. It kind seems pointless have =
the curves allocated.

Regards

Marcel


--===============9129522162547303851==--

