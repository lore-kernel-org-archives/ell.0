Content-Type: multipart/mixed; boundary="===============1612817043738983449=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH v2 1/3] watchlist: added watchlist functionality
Date: Wed, 31 Oct 2018 22:21:00 +0100
Message-ID: <5AC3415C-148D-45D4-9251-9B96AEACB267@holtmann.org>
In-Reply-To: <224aed54a774b0a667477d3178e92a83d4334eb7.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1612817043738983449==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

>>> +
>>> +void __watchlist_prune_stale(struct l_watchlist *watchlist);
>> =

>> Should this be in the public header?
> =

> Yeah.. I meant to inquire about this. Its needed for the macros below
> so it does need to be available as a public API, but its not meant to
> be called directly. Not sure if ELL has anything else like this. Any
> suggestions?

you need to create a watchlist-private.h for these.

Regards

Marcel


--===============1612817043738983449==--

