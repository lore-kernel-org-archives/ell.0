Received: from mohas.pair.com (mohas.pair.com [209.68.5.112])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E7B897FBBA
	for <ell@lists.linux.dev>; Wed, 13 Dec 2023 21:57:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Received: from mohas.pair.com (localhost [127.0.0.1])
	by mohas.pair.com (Postfix) with ESMTP id E440B73106;
	Wed, 13 Dec 2023 16:57:10 -0500 (EST)
Received: from [IPv6:2601:647:5a00:15c1:d509:f6cb:5b35:810f] (unknown [IPv6:2601:647:5a00:15c1:d509:f6cb:5b35:810f])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mohas.pair.com (Postfix) with ESMTPSA id A35F773120;
	Wed, 13 Dec 2023 16:57:10 -0500 (EST)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 13.4 \(3608.120.23.2.4\))
Subject: Re: [RFC] edit: Add basic support for input line editing
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <433C931E-7C34-4EAF-BEEB-F604D7C7C14B@nuovations.com>
Date: Wed, 13 Dec 2023 13:57:09 -0800
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <E458F85E-4986-418F-B9D2-43ABF2F3A1E9@nuovations.com>
References: <20231213212320.35741-1-marcel@holtmann.org>
 <433C931E-7C34-4EAF-BEEB-F604D7C7C14B@nuovations.com>
To: Marcel Holtmann <marcel@holtmann.org>
X-Mailer: Apple Mail (2.3608.120.23.2.4)
X-Scanned-By: mailmunge 3.11 on 209.68.5.112

On Dec 13, 2023, at 1:40 PM, Grant Erickson <gerickson@nuovations.com> =
wrote:
> On Dec 13, 2023, at 1:23 PM, Marcel Holtmann <marcel@holtmann.org> =
wrote:
>> This allows for simple line editing with history capabilities. On
>> purpose this has no concept of terminal input or terminal output and
>> just allows manipulation of an internal wide character string.
>>=20
>> The history storing and loading is currently missing, but would be =
easy
>> to add. The other two items are missing completion and hints =
handling.
>>=20
>> This feature is not yet complete, but good enough for a first review =
and
>> a sample application using it in a curses environment will follow.
>>=20
>> The debug option is something that might need to be removed or at =
least
>> changed a little bit, but right now it is nice to see the internal
>> states.
>=20
> Marcel,
>=20
> Any reason not to build on / improve linenoise or to put a =
neutralizing wrapper around libedit / readline as ntp did / does?
>=20
> Each have their deficiencies, of course. However, it seems like, at =
least linenoise and libedit are close enough where a delta would be =
smaller than a rewrite-from-scratch.

I should have added, the four most important features for the use cases =
I have are:

    1. Run loop integration / non-blocking on input (libcurl and =
libcares have reasonable APIs for this that make them well adaptable to =
just about any run loop infrastructure, including glib or =
CoreFoundation).
    2. Initial input buffer population.
    3. Dynamic prompt generation (basically, there=E2=80=99s a function =
call every time the prompt is refreshed or displayed=E2=80=94the =
implementer can decide whether to return a static string or =
on-the-fly-composed buffer).
    4. Passphrase mode (generate asterisks, spaces, nulls, or bullets on =
input of confidential information).

TUI / CLI-based network setup motivates most of the above, for example:

    Running networking setup=E2=80=A6
        Setting up Ethernet...
            Checking Ethernet availability...
                Ethernet is available.
                Enabling Ethernet networking by default...
        Setting up Wi-Fi...
            Checking Wi-Fi availability=E2=80=A6
                Wi-Fi is available.
            Enable Wi-Fi networking (0|N-No, 1|Y-Yes) [Y]? Y
            Already connected to Wi-Fi network =E2=80=9CNorthern =
Gaze=E2=80=9D.
                Add to, replace, or use the Wi-Fi network =E2=80=9CNorther=
n Gaze=E2=80=9D (A-Add, R-Replace, U-Use) [U]? A

    [ =E2=80=A6 ]

                        Enter the passphrase for "Robust Ground": =
**********
                            Associating with the "Robust Ground" Wi-Fi =
access point...done.
                            Configuring IP addresses...done.
                            Confirming Internet reachability...done.
                        Successfully connected to Wi-Fi network "Robust =
Debt".

The custom, on-the-fly prompts are "Enable Wi-Fi networking (0|N-No, =
1|Y-Yes) [Y]?=E2=80=9D, "Add to, replace, or use the Wi-Fi network =
=E2=80=9CNorthern Gaze=E2=80=9D (A-Add, R-Replace, U-Use) [U]?=E2=80=9D, =
and =E2=80=9CEnter the passphrase for "Robust Debt":". The =
pre-populated, editable input buffers are =E2=80=9CY=E2=80=9D and =
=E2=80=9CA=E2=80=9D, respectively. The passphrase mode is =
=E2=80=9C**********=E2=80=9D.

libedit makes (2) and (3) very easy. linenoise makes (1) easy and (4) =
partially achievable. Neither can do all of those, at least easily.

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
http://www.nuovations.com/

