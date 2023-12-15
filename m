Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 8FE197470
	for <ell@lists.linux.dev>; Fri, 15 Dec 2023 08:19:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p5b3d29b7.dip0.t-ipconnect.de [91.61.41.183])
	by mail.holtmann.org (Postfix) with ESMTPSA id ECE0ECECC3;
	Fri, 15 Dec 2023 09:19:35 +0100 (CET)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.300.61.1.2\))
Subject: Re: [RFC v3] edit: Add basic support for input line editing
From: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <47CEE175-7E58-4730-8AF6-4B6B56A8CB7A@nuovations.com>
Date: Fri, 15 Dec 2023 09:19:25 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <1429748D-230C-4D7F-B48C-87B311E847F9@holtmann.org>
References: <20231214232804.34777-1-marcel@holtmann.org>
 <47CEE175-7E58-4730-8AF6-4B6B56A8CB7A@nuovations.com>
To: Grant Erickson <gerickson@nuovations.com>
X-Mailer: Apple Mail (2.3774.300.61.1.2)

Hi Grant,

>> This allows for simple line editing with history capabilities. On
>> purpose this has no concept of terminal input or terminal output and
>> just allows manipulation of an internal wide character string.
>>=20
>> The debug option is something that might need to be removed or at =
least
>> changed a little bit, but right now it is nice to see the internal
>> states.
>>=20
>> Following features are missing:
>>=20
>> 1) Work with words (delete, move etc.)
>> 2) Tab completion
>> 3) Hints system
>>=20
>> Following features are left to the user:
>>=20
>> 1) Showing the prompt
>> 2) Switching to masked input
>>=20
>> The demo-edit is just for demonstration purposes and requires Curses =
to
>> be available without any autoconf magic.
>=20
>=20
> This looks like it is coming along nicely; the =E2=80=98demo-edit=E2=80=99=
 is very helpful for demonstrating the functionality. On that front, I =
am surprised that in =E2=80=99stdin_callback=E2=80=99 that the =E2=80=98io=
=E2=80=99 parameter does not appear to be used.

while that looks odd, it is normal. The stdin_io is watching for key =
input from stdin and we have wget_wch() that is doing the reading. That =
is Curses specific and does all the ANSI handing for you. If you would =
be doing this in a terminal without Curses, you would be using stdin_io =
and do the ANSI handling by yourself. I have code for that and need to =
provide a demo that just acts like a shell. But frankly my goal is to =
get it integrated with Curses first since that is the tricky part.

ANSI terminals are fun and getting that right is fun as well. =
Problematic is really that linenoise and others are half-baked in that =
area. So at minimum you need to understand ESC, SS2, SS3 and CSI escapes =
to make it work correctly. And I did that initially (and that state =
machine is larger than you think), but then I switched to a design to =
provide the key input character as wint_t and have key codes done via =
descriptive API calls. So pushing that problem to the user of l_edit. =
Which has the additional advantage that you could do key mappings and =
don=E2=80=99t have to do it all in l_edit. And it worked out nicely.

Maybe I am doing some l_ansi or helpers so that in simpler apps you =
don=E2=80=99t have to care too much and it does all the mappings and =
lifting for you. We could have a l_shell or l_cli thing that behaves =
like our current iwctl etc. tools.

Don=E2=80=99t get me wrong, the overblown terminal info stuff that =
Curses is built on top of is insane. That is from ancient days with =
funny Unix derivates where wchar_t might also be 8-bit or at most =
16-bit. Nothing of this is usable in modern systems where you have =
non-ASCII characters as default.

> Beyond that, as with linenoise and libedit, do you anticipate wrapper =
APIs for working with UTF-8?

The l_edit_enter and l_edit_reset APIs take a char * which is using the =
locale which is most likely always UTF-8. So that just works and you =
don=E2=80=99t have to worry about anything. Only the display_handler =
provides wchar_t * and in addition with the length to print. That is an =
optimization since we have nice wchar_t helper in Curses.

With that you can do simple stuff like this:

	wmove(main_win, cur_y, 0);
	waddstr(main_win, prompt_str);
	waddnwstr(main_win, wstr, wlen);
	wclrtoeol(main_win);

And you are fundamentally done for starters.

My goal is always to avoid unneeded memcpy or conversions that are not =
used anywhere or would just duplicate behavior that is native to other =
parts of the system.

The question is if l_edit should offer a converter from wide character =
to multibyte or if that should be left to the caller. I would need to =
see how often that is used. It is clearly doable and easy to add, but if =
you can print wide characters natively, then that should be preferred.

Leaving the prompt printing and masked input handling out of it, is the =
big win actually. It makes things so much easier and lets you customize =
your experience better. And for users of l_edit it is dead simple to do, =
but it took me a while to realize that this doesn=E2=80=99t belong in =
the line editing at all. Most likely because everybody was adding it =
there.

The same applies to the cursor handling. You get the position and need =
to deal with placing the cursor there or emulating one. The demo-shell =
actually by default emulates a cursor by changing the color attribute. =
You could also underline or do some other fancy stuff.

Right now I need to figure out on how to best do tab completion. And =
maybe for the hardcore programmers a reverse-i-search like CCLI is =
doing.

Regards

Marcel

