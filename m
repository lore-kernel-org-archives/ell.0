Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id D8D02282D6
	for <ell@lists.linux.dev>; Wed, 13 Dec 2023 22:26:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p5b3d29b7.dip0.t-ipconnect.de [91.61.41.183])
	by mail.holtmann.org (Postfix) with ESMTPSA id 5056DCECD5;
	Wed, 13 Dec 2023 23:26:11 +0100 (CET)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.300.61.1.2\))
Subject: Re: [RFC] edit: Add basic support for input line editing
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <E458F85E-4986-418F-B9D2-43ABF2F3A1E9@nuovations.com>
Date: Wed, 13 Dec 2023 23:26:00 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <A56099C8-1232-4459-BEF9-D2B15381AC97@holtmann.org>
References: <20231213212320.35741-1-marcel@holtmann.org>
 <433C931E-7C34-4EAF-BEEB-F604D7C7C14B@nuovations.com>
 <E458F85E-4986-418F-B9D2-43ABF2F3A1E9@nuovations.com>
To: Grant Erickson <gerickson@nuovations.com>
X-Mailer: Apple Mail (2.3774.300.61.1.2)

Hi Grant,

>>> This allows for simple line editing with history capabilities. On
>>> purpose this has no concept of terminal input or terminal output and
>>> just allows manipulation of an internal wide character string.
>>>=20
>>> The history storing and loading is currently missing, but would be =
easy
>>> to add. The other two items are missing completion and hints =
handling.
>>>=20
>>> This feature is not yet complete, but good enough for a first review =
and
>>> a sample application using it in a curses environment will follow.
>>>=20
>>> The debug option is something that might need to be removed or at =
least
>>> changed a little bit, but right now it is nice to see the internal
>>> states.
>>=20
>> Marcel,
>>=20
>> Any reason not to build on / improve linenoise or to put a =
neutralizing wrapper around libedit / readline as ntp did / does?
>>=20
>> Each have their deficiencies, of course. However, it seems like, at =
least linenoise and libedit are close enough where a delta would be =
smaller than a rewrite-from-scratch.
>=20
> I should have added, the four most important features for the use =
cases I have are:
>=20
>    1. Run loop integration / non-blocking on input (libcurl and =
libcares have reasonable APIs for this that make them well adaptable to =
just about any run loop infrastructure, including glib or =
CoreFoundation).
>    2. Initial input buffer population.
>    3. Dynamic prompt generation (basically, there=E2=80=99s a function =
call every time the prompt is refreshed or displayed=E2=80=94the =
implementer can decide whether to return a static string or =
on-the-fly-composed buffer).
>    4. Passphrase mode (generate asterisks, spaces, nulls, or bullets =
on input of confidential information).
>=20
> TUI / CLI-based network setup motivates most of the above, for =
example:
>=20
>    Running networking setup=E2=80=A6
>        Setting up Ethernet...
>            Checking Ethernet availability...
>                Ethernet is available.
>                Enabling Ethernet networking by default...
>        Setting up Wi-Fi...
>            Checking Wi-Fi availability=E2=80=A6
>                Wi-Fi is available.
>            Enable Wi-Fi networking (0|N-No, 1|Y-Yes) [Y]? Y
>            Already connected to Wi-Fi network =E2=80=9CNorthern =
Gaze=E2=80=9D.
>                Add to, replace, or use the Wi-Fi network =E2=80=9CNorthe=
rn Gaze=E2=80=9D (A-Add, R-Replace, U-Use) [U]? A
>=20
>    [ =E2=80=A6 ]
>=20
>                        Enter the passphrase for "Robust Ground": =
**********
>                            Associating with the "Robust Ground" Wi-Fi =
access point...done.
>                            Configuring IP addresses...done.
>                            Confirming Internet reachability...done.
>                        Successfully connected to Wi-Fi network "Robust =
Debt".
>=20
> The custom, on-the-fly prompts are "Enable Wi-Fi networking (0|N-No, =
1|Y-Yes) [Y]?=E2=80=9D, "Add to, replace, or use the Wi-Fi network =
=E2=80=9CNorthern Gaze=E2=80=9D (A-Add, R-Replace, U-Use) [U]?=E2=80=9D, =
and =E2=80=9CEnter the passphrase for "Robust Debt":". The =
pre-populated, editable input buffers are =E2=80=9CY=E2=80=9D and =
=E2=80=9CA=E2=80=9D, respectively. The passphrase mode is =
=E2=80=9C**********=E2=80=9D.
>=20
> libedit makes (2) and (3) very easy. linenoise makes (1) easy and (4) =
partially achievable. Neither can do all of those, at least easily.

I really need to clean up my Curses demo to show you how I envision =
this. I can easily add 2) actually. I left it out since I couldn=E2=80=99t=
 find a use for it, but fair enough. And 3) and 4) really belong into =
the caller. Especially if you go fancy with colors or other attributes. =
It is so much easier for the the caller to get right than for the line =
editing.

What you missed is a 5) that restricts the input to a certain length. =
And I am still debating if a minimal length is useful as well, but then =
I really need to implement the hints support first.

Regards

Marcel

