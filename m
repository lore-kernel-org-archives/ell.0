Received: from mohas.pair.com (mohas.pair.com [209.68.5.112])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 955235B20C
	for <ell@lists.linux.dev>; Wed, 13 Dec 2023 21:40:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=nuovations.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=nuovations.com
Received: from mohas.pair.com (localhost [127.0.0.1])
	by mohas.pair.com (Postfix) with ESMTP id 9F63A7311A;
	Wed, 13 Dec 2023 16:40:17 -0500 (EST)
Received: from [IPv6:2601:647:5a00:15c1:d509:f6cb:5b35:810f] (unknown [IPv6:2601:647:5a00:15c1:d509:f6cb:5b35:810f])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mohas.pair.com (Postfix) with ESMTPSA id 5946B7312C;
	Wed, 13 Dec 2023 16:40:17 -0500 (EST)
Content-Type: text/plain;
	charset=us-ascii
Precedence: bulk
X-Mailing-List: ell@lists.linux.dev
List-Id: <ell.lists.linux.dev>
List-Subscribe: <mailto:ell+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:ell+unsubscribe@lists.linux.dev>
Mime-Version: 1.0 (Mac OS X Mail 13.4 \(3608.120.23.2.4\))
Subject: Re: [RFC] edit: Add basic support for input line editing
From: Grant Erickson <gerickson@nuovations.com>
In-Reply-To: <20231213212320.35741-1-marcel@holtmann.org>
Date: Wed, 13 Dec 2023 13:40:16 -0800
Cc: ell@lists.linux.dev
Content-Transfer-Encoding: quoted-printable
Message-Id: <433C931E-7C34-4EAF-BEEB-F604D7C7C14B@nuovations.com>
References: <20231213212320.35741-1-marcel@holtmann.org>
To: Marcel Holtmann <marcel@holtmann.org>
X-Mailer: Apple Mail (2.3608.120.23.2.4)
X-Scanned-By: mailmunge 3.11 on 209.68.5.112

On Dec 13, 2023, at 1:23 PM, Marcel Holtmann <marcel@holtmann.org> =
wrote:
> This allows for simple line editing with history capabilities. On
> purpose this has no concept of terminal input or terminal output and
> just allows manipulation of an internal wide character string.
>=20
> The history storing and loading is currently missing, but would be =
easy
> to add. The other two items are missing completion and hints handling.
>=20
> This feature is not yet complete, but good enough for a first review =
and
> a sample application using it in a curses environment will follow.
>=20
> The debug option is something that might need to be removed or at =
least
> changed a little bit, but right now it is nice to see the internal
> states.

Marcel,

Any reason not to build on / improve linenoise or to put a neutralizing =
wrapper around libedit / readline as ntp did / does?

Each have their deficiencies, of course. However, it seems like, at =
least linenoise and libedit are close enough where a delta would be =
smaller than a rewrite-from-scratch.

Best,

Grant

--=20
Principal
Nuovations

gerickson@nuovations.com
http://www.nuovations.com/
