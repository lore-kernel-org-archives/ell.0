Content-Type: multipart/mixed; boundary="===============6284479365107923883=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: Re: [PATCH 3/9] hashmap: Call user supplied value free function in
 insert
Date: Wed, 11 Feb 2015 13:04:59 +0200
Message-ID: <54DB375B.1000506@linux.intel.com>
In-Reply-To: <1423646869.5906.137.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6284479365107923883==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Guys,

> On Tue, 2015-02-10 at 13:18 -0600, Denis Kenzior wrote:
>> With the current implementation, the item inserted first is
>> returned.  I don't think enforcement of unique keys is required at the
>> hashmap_insert level.
> As long as there is no function to read out more than one of the values
> from the hashmap, the hashmap should definitely require keys to be
> unique. It's way much simpler to require unique keys as the opposite
> situation with multiple values per key  as it is really uncommon and
> shows that the upper level data structure needs a rethought.

Actually, looking at the implementation in addition of Patrik's comment, =

it just looks as a bug. Nothing else.
What it tries to handle is collisions the classical way, and insert it =

here buggy as it does not check if the key is indeed unique.

The hash and/or bucket place might provoke a collision because of the =

hash function itself, not because the key is the same,
thus why it is possible to link entries to each other.
Thus why remove does check the key against each entries (if there are =

more than one) to retrieve the right one.
There were no point of "handling multiple identical keys" there, or then =

as Patrik said: the API would provide means to play with it.

insert _should_ return false if the key is already present.

So now: either we add a replace, or we let the dev to handle a lookup =

(and necessary remove) before doing any inserts.
But insert has to be fixed.

Br,

Tomasz

--===============6284479365107923883==--

