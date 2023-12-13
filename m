Received: from mail.holtmann.org (coyote.holtmann.net [212.227.132.17])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id B0B117FBB0
	for <ell@lists.linux.dev>; Wed, 13 Dec 2023 22:03:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=holtmann.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=holtmann.org
Received: from smtpclient.apple (p5b3d29b7.dip0.t-ipconnect.de [91.61.41.183])
	by mail.holtmann.org (Postfix) with ESMTPSA id 68B7ACECD5;
	Wed, 13 Dec 2023 23:03:55 +0100 (CET)
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
In-Reply-To: <433C931E-7C34-4EAF-BEEB-F604D7C7C14B@nuovations.com>
Date: Wed, 13 Dec 2023 23:03:44 +0100
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <7A5C6FBE-B018-41C4-8444-D529FBBAF584@holtmann.org>
References: <20231213212320.35741-1-marcel@holtmann.org>
 <433C931E-7C34-4EAF-BEEB-F604D7C7C14B@nuovations.com>
To: Grant Erickson <gerickson@nuovations.com>
X-Mailer: Apple Mail (2.3774.300.61.1.2)

Hi Grant,

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
>=20
> Any reason not to build on / improve linenoise or to put a =
neutralizing wrapper around libedit / readline as ntp did / does?
>=20
> Each have their deficiencies, of course. However, it seems like, at =
least linenoise and libedit are close enough where a delta would be =
smaller than a rewrite-from-scratch.

so funny that you asked. I actually started with linenoise and was going =
to just use that. While it looked promising, it did not work out. I have =
written a whole integration with it and was initially really happy. =
However the problem is that linenoise (and others like ccli etc.) are =
based on the concept of direct access to the TTY and sending/parsing =
ANSI sequences. That is all good and golden, but doesn=E2=80=99t fly if =
you want to work in a Curses application. I learned the hard way that =
Curses and ANSI sequences don=E2=80=99t go together at all. And with the =
Curses idea, the direct access to stdout from linenoise is also not =
functional. I worked out a few things and still thought that I just =
extend linenoise until I started to play with umlauts and Unicode and =
then I hit a really hard brick wall.

This caused me to re-evaluate the basic idea on how all line editing =
libraries are done right now. So l_edit has no direct input/output =
capabilities. That is up to the caller. I removed prompt handling on =
purpose since the caller can do that better than the line editing =
library. And I also removed masked support (which I had initially) since =
the caller again can do that way better.

I do have a Curses based demo that will show this, but it is too messy =
at the moment to publish. I will clean that up and then maybe this =
becomes a bit clearer why this approach is better.

While doing this, I also found new respect for readline, but that thing =
has to go since its insistence on GPLv3 is just causing long term =
problems.

Regards

Marcel

