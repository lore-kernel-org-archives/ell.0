Received: from mohas.pair.com (mohas.pair.com [209.68.5.112])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19A9612E40
	for <ell@lists.linux.dev>; Fri, 15 Dec 2023 06:41:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Received: from mohas.pair.com (localhost [127.0.0.1])
	by mohas.pair.com (Postfix) with ESMTP id F0BD07310B;
	Fri, 15 Dec 2023 01:41:49 -0500 (EST)
Received: from [IPv6:2601:647:5a00:15c1:b068:f747:ef15:95c3] (unknown [IPv6:2601:647:5a00:15c1:b068:f747:ef15:95c3])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mohas.pair.com (Postfix) with ESMTPSA id A96A473123;
	Fri, 15 Dec 2023 01:41:49 -0500 (EST)
Content-Type: text/plain;
	charset=utf-8
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 13.4 \(3608.120.23.2.4\))
Subject: Re: [RFC v3] edit: Add basic support for input line editing
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <20231214232804.34777-1-marcel@holtmann.org>
Date: Thu, 14 Dec 2023 22:41:48 -0800
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <47CEE175-7E58-4730-8AF6-4B6B56A8CB7A@nuovations.com>
References: <20231214232804.34777-1-marcel@holtmann.org>
To: Marcel Holtmann <marcel@holtmann.org>
X-Mailer: Apple Mail (2.3608.120.23.2.4)
X-Scanned-By: mailmunge 3.11 on 209.68.5.112

On Dec 14, 2023, at 3:28 PM, Marcel Holtmann <marcel@holtmann.org> =
wrote:
> This allows for simple line editing with history capabilities. On
> purpose this has no concept of terminal input or terminal output and
> just allows manipulation of an internal wide character string.
>=20
> The debug option is something that might need to be removed or at =
least
> changed a little bit, but right now it is nice to see the internal
> states.
>=20
> Following features are missing:
>=20
> 1) Work with words (delete, move etc.)
> 2) Tab completion
> 3) Hints system
>=20
> Following features are left to the user:
>=20
> 1) Showing the prompt
> 2) Switching to masked input
>=20
> The demo-edit is just for demonstration purposes and requires Curses =
to
> be available without any autoconf magic.

Marcel,

This looks like it is coming along nicely; the =E2=80=98demo-edit=E2=80=99=
 is very helpful for demonstrating the functionality. On that front, I =
am surprised that in =E2=80=99stdin_callback=E2=80=99 that the =E2=80=98io=
=E2=80=99 parameter does not appear to be used.

Beyond that, as with linenoise and libedit, do you anticipate wrapper =
APIs for working with UTF-8?

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
http://www.nuovations.com/

