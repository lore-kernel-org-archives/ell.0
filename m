Content-Type: multipart/mixed; boundary="===============2090521990379449280=="
MIME-Version: 1.0
From: Patrik Flykt <Patrik.Flykt@linux.intel.com>
Subject: Re: [PATCH 3/9] hashmap: Call user supplied value free function in
 insert
Date: Wed, 11 Feb 2015 11:27:49 +0200
Message-ID: <1423646869.5906.137.camel@linux.intel.com>
In-Reply-To: <54DA598C.6030402@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2090521990379449280==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-02-10 at 13:18 -0600, Denis Kenzior wrote:
> With the current implementation, the item inserted first is =

> returned.  I don't think enforcement of unique keys is required at the
> hashmap_insert level.

As long as there is no function to read out more than one of the values
from the hashmap, the hashmap should definitely require keys to be
unique. It's way much simpler to require unique keys as the opposite
situation with multiple values per key  as it is really uncommon and
shows that the upper level data structure needs a rethought.


Cheers,

	Patrik




--===============2090521990379449280==--

